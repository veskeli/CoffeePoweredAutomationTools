#Requires AutoHotkey v2.0+
BetterClipboardVersion := "0.12"
BetterClipboardLoadTab()
{
    Tab.UseTab("BetterClipboard")
    global ogcListBox := myGui.Add("ListBox", "x40 y40 w514 h264","")
}
$^c::
{
    BetterClipboardFolder := AppPluginsFolder "/BetterClipboard"
    ClipboardHistoryFile := BetterClipboardFolder "/ClipboardHistory.txt"

    DirCreate(BetterClipboardFolder)

    A_Clipboard := ""
    Send("^c")
    ClipWait(1)

    ;FileAppend(A_Clipboard "`n",ClipboardHistoryFile)
    ogcListBox.Add := A_Clipboard
}