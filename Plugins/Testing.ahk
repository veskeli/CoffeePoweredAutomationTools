#Requires AutoHotkey v2.0
TestingLoadTab()
{
    Tab.UseTab("Testing")
    ogcButtonOpenScriptFolder := myGui.Add("Button", "x16 y312 w110 h23", "Button Test")
    ogcButtonOpenScriptFolder.OnEvent("Click", RandomMessage.Bind("Normal"))
}
RandomMessage(*)
{
    MsgBox("Test")
}