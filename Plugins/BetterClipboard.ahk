#Requires AutoHotkey v2.0+
BetterClipboardVersion := "0.11"
BetterClipboardLoadTab()
{
    Tab.UseTab("BetterClipboard")
    ogcButtonOpenScriptFolder := myGui.Add("Button", "x16 y312 w110 h23", "Button Test")
}
$^c::
{
    BetterClipboardFolder := AppPluginsFolder "/BetterClipboard"
    ClipboardHistoryFile := BetterClipboardFolder "/ClipboardHistory.txt"

    DirCreate(BetterClipboardFolder)

    A_Clipboard := ""
    Send("^c")
    ClipWait(1)

    FileAppend(A_Clipboard "`n",ClipboardHistoryFile)
}