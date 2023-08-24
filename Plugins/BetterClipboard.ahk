#Requires AutoHotkey v2.0+
BetterClipboardLoadTab()
{
    Tab.UseTab("BetterClipboard")
}

$^c::
{
    ;Send("^c")
    MsgBox("Test")
}