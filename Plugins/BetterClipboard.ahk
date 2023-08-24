#Requires AutoHotkey v2.0+

BetterClipboardLoadTab()
{
    Tab.UseTab("BetterClipboard")
    ;________________________________________________________________________________________________________________________
    ;//////////////[Variables]///////////////
    BetterClipboardFolder := AppPluginsFolder "/BetterClipboard"
    ClipboardHistoryFile := BetterClipboardFolder "/ClipboardHistory.txt"
}
$^c::
{
    Send("^c")
    FileAppend(A_Clipboard "`n",ClipboardHistoryFile)
}