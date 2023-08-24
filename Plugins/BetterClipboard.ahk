#Requires AutoHotkey v2.0+
BetterClipboardVersion := "0.2"
global BCHistoryArray := Array()
BetterClipboardLoadTab()
{
    Tab.UseTab("BetterClipboard")
    global BCRecordCliboard := CheckBox1 := myGui.Add("CheckBox", "x8 y32 w145 h23 +Checked", "Record Clipboard History")
    global BCSkipDupes := myGui.Add("CheckBox", "x160 y32 w100 h23", "Skip Duplicates")
    global BCDropDownList1 := myGui.Add("DropDownList", "x270 y32 w120", ["Check last one", "Check all"])
    BCDropDownList1.Choose(1)
    global ogcListBox := myGui.Add("ListBox", "x8 y64 w514 h264") ;+Multi

    myGui.Add("Text", "x648 y32 w120 h23 +0x200", "Win + C: paste selected")
    myGui.Add("Text", "x24 y424 w120 h23 +0x200", "Test:")
    Edit1 := myGui.Add("Edit", "x24 y456 w401 h21", '"Adventure in life is good; consistency in coffee even better." - Justina Chen')
    Edit2 := myGui.Add("Edit", "x24 y488 w402 h21", '"Coffee is a hug in a mug." - Unknown')
}
$^c::
{
    if(BCRecordCliboard.Value == 1)
    {
        BetterClipboardFolder := AppPluginsFolder "/BetterClipboard"
        ClipboardHistoryFile := BetterClipboardFolder "/ClipboardHistory.txt"

        DirCreate(BetterClipboardFolder)

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
#C::
{
    CurrentClip := A_Clipboard
    A_Clipboard := ogcListBox.text
    Send("^v")
    A_Clipboard := CurrentClip
}
BCAddToHistory(Text)
{
    ogcListBox.add([Text])
    BCHistoryArray.Push(Text)
}