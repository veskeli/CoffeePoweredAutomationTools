#Requires AutoHotkey v2.0+
;________________________________________________________________________________________________________________________
;//////////////[Variables]///////////////
BetterClipboardFolder := AppPluginsFolder "/BetterClipboard"
ClipboardHistoryFile := BetterClipboardFolder "/ClipboardHistory.txt"

BetterClipboardLoadTab()
{
    Tab.UseTab("BetterClipboard")
}
$^c::
{
    Send("^c")
    FileAppend(A_Clipboard "`n",ClipboardHistoryFile)
}