#Requires Autohotkey v2
;AutoGUI 2.5.8 creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;Easy_AutoGUI_for_AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

myGui := Gui()
ogcButtonOK := myGui.Add("Button", "x168 y56 w84 h80", "&OK")
ogcButtonOK.OnEvent("Click", OnEventHandler)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Window start"
myGui.Show("w1689 h627")
myGui.BackColor := "0x808040"
WinSetTransColor("0x808040",myGui.Title)

OnEventHandler(*)
{
	ToolTip("Click! This is a sample action.`n"
	. "Active GUI element values include:`n"
	. "ogcButtonOK => " ogcButtonOK.Value "`n", 77, 277)
	SetTimer () => ToolTip(), -3000 ; tooltip timer
}