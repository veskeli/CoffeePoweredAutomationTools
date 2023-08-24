#Requires AutoHotkey v2.0+

BetterClipboardLoadTab()
{
    Tab.UseTab("BetterClipboard")
}
$^c::
{
    BetterClipboardFolder := AppPluginsFolder "/BetterClipboard"
    ClipboardHistoryFile := BetterClipboardFolder "/ClipboardHistory.txt"
    Send("^c")
    FileAppend(A_Clipboard "`n",ClipboardHistoryFile)
}