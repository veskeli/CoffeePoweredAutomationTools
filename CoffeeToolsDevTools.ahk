#Requires Autohotkey v2
BuildVersion := "Build 2"

myGui := Gui()
myGui.Opt("-MaximizeBox")

Tab := myGui.Add("Tab3", "x0 y0 w688 h416", ["Main", "Plugins"])
Tab.UseTab(1)

;Version control
myGui.Add("GroupBox", "x8 y32 w210 h139", "Update Version")
VersionDropDownList := myGui.Add("DropDownList", "x16 y48 w197", ["CoffeeTools", "Updater"]) ;["CoffeeTools", "Updater", "Launcher", "Installer"]
VersionDropDownList.Choose(1)
CurrentVersionText := myGui.Add("Text", "x16 y85 w187 h23 +0x200", "Current Version: 0.000")
CoffeeToolsCurrentVersion := ReadVersionFromAhkFile("Version","CoffeeTools")
myGui.Add("Text", "x16 y104 w70 h23 +0x200", "New version:")
Edit1 := myGui.Add("Edit", "x88 y105 w120 h21", "0.000")
Edit1.Text := CoffeeToolsCurrentVersion
UpdateApplicationVersion(VersionDropDownList.Value)
VersionDropDownList.OnEvent("Change", UpdateApplicationVersion.Bind())
ogcButtonUpdate := myGui.Add("Button", "x10 y136 w50 h23", "Update")
ogcButtonUpdate.OnEvent("Click", UpdateAhkVersion.Bind())
ogcButtonUpdateUp1 := myGui.Add("Button", "x60 y136 w50 h23", "Up 0.1")
ogcButtonUpdateUp1.OnEvent("Click", AddToUpdateNumber.Bind(0.1))
ogcButtonUpdateUp2 := myGui.Add("Button", "x110 y136 w50 h23", "Up 0.01")
ogcButtonUpdateUp2.OnEvent("Click", AddToUpdateNumber.Bind(0.01))
ogcButtonUpdateUp3 := myGui.Add("Button", "x160 y136 w50 h23", "Up 0.001")
ogcButtonUpdateUp3.OnEvent("Click", AddToUpdateNumber.Bind(0.001))
;Open
myGui.Add("GroupBox", "x8 y176 w132 h147", "Open")
OpenFromDropDownList := myGui.Add("DropDownList", "x16 y192 w113", ["Dev", "Appdata"])
OpenFromDropDownList.Choose(1)
ogcButtonCoffeeTools := myGui.Add("Button", "x16 y216 w80 h23", "Coffee Tools")
ogcButtonCoffeeTools.OnEvent("Click", OpenScript.Bind("CoffeeTools"))
ogcButtonP := myGui.Add("Button", "x96 y216 w40 h23", "Plugins")
ogcButtonP.OnEvent("Click", OpenScript.Bind("CoffeeToolsWithPlugins"))
ogcButtonUpdater := myGui.Add("Button", "x16 y240 w80 h23", "Updater")
ogcButtonUpdater.OnEvent("Click", OpenScript.Bind("Updater"))
ogcButtonLauncher := myGui.Add("Button", "x16 y264 w80 h23", "Launcher")
ogcButtonLauncher.OnEvent("Click", OpenScript.Bind("Launcher"))
ogcButtonInstaller := myGui.Add("Button", "x16 y288 w80 h23", "Installer")
ogcButtonInstaller.OnEvent("Click", OpenScript.Bind("Installer"))
;Move
myGui.Add("GroupBox", "x224 y32 w193 h123", "Move")
MoveDropDownList := myGui.Add("DropDownList", "x232 y48 w174", ["CoffeeTools", "Updater", "Launcher", "Installer"])
MoveDropDownList.Choose(1)
myGui.Add("Text", "x232 y72 w34 h23 +0x200", "From:")
MoveFromDropDownList := myGui.Add("DropDownList", "x272 y72 w120", ["Dev", "Appdata"])
MoveFromDropDownList.Choose(1)
myGui.Add("Text", "x232 y96 w32 h23 +0x200", "To:")
MoveToDropDownList := myGui.Add("DropDownList", "x272 y96 w120", ["Appdata", "Dev"])
MoveToDropDownList.Choose(1)
ogcButtonMove := myGui.Add("Button", "x232 y120 w80 h23 +Disabled", "Move")
ogcButtonSwitch := myGui.Add("Button", "x320 y120 w80 h22 +Disabled", "Switch")

Tab.UseTab()

myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Coffee Tools Dev Tools | " BuildVersion
myGui.Show("w563 h345")

;Open scripts
global StartPath := A_ScriptDir
OpenScript(FileName,*)
{
    ;Path
    global StartPath
    if(OpenFromDropDownList.Value == 2)
        StartPath := A_AppData "\CoffeePoweredAutomationTools"

    Path := StartPath "\" FileName ".ahk"

    if(FileExist(Path))
        Run(Path)
    else
        MsgBox("File not found!`nPath: `n" Path)
}
;Update
AddToUpdateNumber(AddAmount,*)
{
    local OldUpdateText := Float(Edit1.Value)
    local NewUpdateText := Round(OldUpdateText + AddAmount,3)
    NewUpdateText := RTrim(NewUpdateText,"0")
    Edit1.Value := NewUpdateText
}
;Update Version
UpdateAhkVersion(*)
{
    ;Variables
    local SelectedScript := VersionDropDownList.Text
    local SelectedScriptTextFile := VersionDropDownList.Text
    local SelectedVersionText := 'Version := "'

    if(VersionDropDownList.Value == 1)
        SelectedScriptTextFile := "CoffeePoweredAutomationTools"

    local PathToAhkFile := A_ScriptDir "\" VersionDropDownList.Text ".ahk"
    local PathToVersionFile := A_ScriptDir "\" "Version" "\" SelectedScriptTextFile "Version" ".txt"
    local MainScriptAhkFile := A_ScriptDir . "\" . SelectedScript . ".ahk"
    local MainScriptAhkFileTemp := A_ScriptDir . "\" . "Temp" . SelectedScript . ".ahk"

    switch VersionDropDownList.Value {
        case 1:
            SelectedVersionText := 'Version := "'
        case 2:
            SelectedVersionText := 'UpdaterVersion := "'
        default:
            SelectedVersionText := 'Version := "'
    }

    ;Version text file
    if(FileExist(PathToVersionFile) and FileExist(MainScriptAhkFile))
    {
        FileDelete(PathToVersionFile)
        FileAppend(Edit1.Text,PathToVersionFile)
    }
    else
    {
        MsgBox("Text file or file missing")
        return
    }

    ;Ahk File
    if(FileExist(MainScriptAhkFile))
    {
        MainFile := FileRead(MainScriptAhkFile)
        MainFileStart := ""
        MainFileEnd := ""
        SaveToStart := true
        local VersionText := SelectedVersionText
        local NewVersionText := SelectedVersionText Edit1.Text '"'

        ;Copy and save new version
        loop parse, MainFile, "`n"
        {
            if(InStr(A_LoopField,VersionText))
            {
                MainFileEnd := NewVersionText
                SaveToStart := false
                continue
            }
            else
            {
                if(A_Index == 1)
                {
                    MainFileStart := A_LoopField
                }
                else
                {
                    if(SaveToStart)
                    {
                        MainFileStart := MainFileStart . "`n" . A_LoopField
                    }
                    else
                    {
                        MainFileEnd := MainFileEnd . "`n" . A_LoopField
                    }
                }
            }
        }
        if(SaveToStart)
        {
            MsgBox("Version not found")
            return
        }
        NewFile := MainFileStart . "`n" . MainFileEnd

        ;Write new file
        FileMove(MainScriptAhkFile,MainScriptAhkFileTemp,true)
        FileAppend(NewFile,MainScriptAhkFile)

        ;Update Gui
        UpdateApplicationVersion()
    }
}


UpdateApplicationVersion(*)
{
    switch  VersionDropDownList.Value{
        case 1:
            ApplicationName := "CoffeeTools"
            ApplicationVersion := "Version"
        case 2:
            ApplicationName := "Updater"
            ApplicationVersion := "UpdaterVersion"
        default:
            ApplicationName := "CoffeeTools"
            ApplicationVersion := "Version"
    }

    local CurrentVersion := ReadVersionFromAhkFile(ApplicationVersion,ApplicationName)
    CurrentVersionText.Text := "Current Version: " CurrentVersion
    Edit1.Text := CurrentVersion
}
/**
 * Returns version found (Empty if not found)
 *
 * @param VersionVariableName Is case sensitive
 * @param AhkFile Path to Ahk File
**/
ReadVersionFromAhkFile(VersionVariableName,AhkFile)
{
    ;Variables
    local Path := A_ScriptDir "\" AhkFile ".ahk"
    VersionFile := FileRead(Path)
    FoundVersion := ""

    loop parse, VersionFile, "`n" ;Loop lines
    {
        if(InStr(A_LoopField,VersionVariableName,1)) ;If contains variable name
        {
            FoundVersion := ParseVersionLine(A_LoopField)
            break
        }
    }
    return FoundVersion
}
/**
 * Parses ahk variable
**/
ParseVersionLine(Line)
{
    ReturnFoundVersion := ""
    VarStart := false
    VarEnd := false
    loop parse, Line ;Loop line characters
    {
        if(InStr(A_LoopField,'"')) ;Find "
        {
            if(VarStart) ;End "
            {
                VarEnd := true
                break
            }
            else ;Start saving after "
            {
                VarStart := true
                continue
            }
        }
        else if(VarStart) ;Save characters to variable
        {
            ReturnFoundVersion := ReturnFoundVersion A_LoopField
        }
    }
    return ReturnFoundVersion
}