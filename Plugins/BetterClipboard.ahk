#Requires AutoHotkey v2.0+
BetterClipboardVersion := "0.1"
BetterClipboardLoadTab()
{
    Tab.UseTab("BetterClipboard")
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