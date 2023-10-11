#Requires AutoHotkey v2.0+
;____________________________________________________________
;//////////////[Def variables]///////////////
BetterClipboardVersion := "0.3"
global BCHistoryArray := Array()

global BCClipHistorySectionName := "ClipboardHistory"
global BCHistorySettingsSectionName := "HistorySettings"

;____________________________________________________________
;//////////////[Gui]///////////////
BetterClipboardLoadTab()
{
    ClipboardHistoryFile := AppPluginsFolder "/BetterClipboard" "/ClipboardHistory.ini"

    Tab.UseTab("BetterClipboard")
    global BCRecordCliboard := CheckBox1 := myGui.Add("CheckBox", "x8 y32 w145 h23 +Checked", "Record Clipboard History")
    global BCSkipDupes := myGui.Add("CheckBox", "x160 y32 w100 h23", "Skip Duplicates")
    global BCDropDownList1 := myGui.Add("DropDownList", "x270 y32 w120", ["Check last one", "Check all"])
    BCDropDownList1.Choose(1)
    global ogcListBox := myGui.Add("ListBox", "x8 y64 w627 h264") ;+Multi
    ogcButtonRevertlist := myGui.Add("Button", "x640 y64 w80 h23 +Disabled", "Revert list")
    ogcButtonRevertlist.OnEvent("Click",RevertHistory.Bind("Default"))

    myGui.Add("Text", "x648 y32 w120 h23 +0x200", "Win + C: paste selected")
    myGui.Add("Text", "x24 y424 w120 h23 +0x200", "Test:")
    Edit1 := myGui.Add("Edit", "x24 y456 w401 h21", '"Adventure in life is good; consistency in coffee even better." - Justina Chen')
    Edit2 := myGui.Add("Edit", "x24 y488 w402 h21", '"Coffee is a hug in a mug." - Unknown')

    ;Load history
    local HistoryCount := Integer(IniRead(ClipboardHistoryFile,BCHistorySettingsSectionName,"Count",0))
    loop HistoryCount
    {
        local IsMultiline := IniRead(ClipboardHistoryFile,BCClipHistorySectionName,A_Index "IsMultiline",false)

        if(IsMultiline)
        {
            local MultilineCount := IniRead(ClipboardHistoryFile,BCClipHistorySectionName,A_Index ".Count",1)
            local Text := ""
            loop MultilineCount
            {
                local CurrentText := IniRead(ClipboardHistoryFile,BCClipHistorySectionName,A_Index ".Count",1)
                if(A_Index == 1)
                    Text := CurrentText
                else
                    Text := Text "`n" CurrentText
            }
            BCAddToLocalHistory(Text)
        }
        else
        {
            local Text := IniRead(ClipboardHistoryFile,BCClipHistorySectionName,A_Index,"")
            BCAddToLocalHistory(Text)
        }
    }
}
;____________________________________________________________
;//////////////[Hotkeys]///////////////
$^c::
{
    if(BCRecordCliboard.Value == 1)
    {
        ClipboardHistoryFile := AppPluginsFolder "/BetterClipboard" "/ClipboardHistory.ini"

        DirCreate(AppPluginsFolder "/BetterClipboard")

        OldClip := A_Clipboard
        A_Clipboard := ""
        Send("^c")
        ClipWait(1)

        if(BCSkipDupes.Value == 1)
        {
            if(BCDropDownList1.Value == 1)
            {
                if(OldClip != A_Clipboard)
                    BCAddToHistory(A_Clipboard)
            }
            else
            {
                local DupeFound := false
                try{
                    loop BCHistoryArray.Length
                    {
                        if(BCHistoryArray[A_Index] == A_Clipboard)
                            DupeFound := true
                    }
                    if(!DupeFound)
                        BCAddToHistory(A_Clipboard)
                }
                catch{
                    BCAddToHistory(A_Clipboard)
                }
            }
        }
        else
        {
            BCAddToHistory(A_Clipboard)
        }
    }
    else
    {
        Send("^c")
    }
}
$#C::
{
    BCCurrentClip := A_Clipboard

    A_Clipboard := ogcListBox.text
    ClipWait(2)
    Send("^v")

    sleep 100

    A_Clipboard := BCCurrentClip
}
;____________________________________________________________
;//////////////[Functions]///////////////
/**
 * Saves and adds text to gui and file
**/
BCAddToHistory(Text, tProfile := "ClipboardHistory")
{
    ;Vars
    CustomProfile := tProfile ".ini"
    ClipboardHistoryFile := AppPluginsFolder "/BetterClipboard" "/" CustomProfile
    local IsMultiline := false

    ;load count
    local HistoryCount := Integer(IniRead(ClipboardHistoryFile,BCHistorySettingsSectionName,"Count",0))
    HistoryCount++

    ;Save if its multiline
    if(InStr(A_Clipboard,"`n"))
        IsMultiline := true
    IniWrite(IsMultiline,ClipboardHistoryFile,BCClipHistorySectionName,HistoryCount "IsMultiline")

    ;add to gui and array
    BCAddToLocalHistory(Text)

    if(IsMultiline)
    {
        ;Save multiline
        StrReplace(Text,"`n","`n",true,&MultilineCount)
        MultilineCount++
        TextArray := StrSplit(Text,"`n")
        loop MultilineCount
        {
            IniWrite(TextArray[A_Index],ClipboardHistoryFile,BCClipHistorySectionName,HistoryCount "." A_Index)
        }
        ;Save how many lines
        IniWrite(MultilineCount,ClipboardHistoryFile,BCClipHistorySectionName,HistoryCount ".Count")
    }
    else
    {
        IniWrite(Text,ClipboardHistoryFile,BCClipHistorySectionName,HistoryCount)
    }

    ;update history count
    IniWrite(HistoryCount,ClipboardHistoryFile,BCHistorySettingsSectionName,"Count")
}
/**
 * Adds to array and listbox
**/
BCAddToLocalHistory(Text)
{
    ogcListBox.add([Text])
    BCHistoryArray.Push(Text)
}
RevertHistory(*)
{
    global BCHistoryArray

    RevertedList := Array()
    ogcListBox.delete()
    ArraySize := BCHistoryArray.Length

    for x in BCHistoryArray
    {
        CurrentIndex := ArraySize - A_Index + 1

        NewItem := BCHistoryArray[CurrentIndex]

        RevertedList.Push(NewItem)
        ogcListBox.add([NewItem])
    }
    BCHistoryArray := RevertedList
}