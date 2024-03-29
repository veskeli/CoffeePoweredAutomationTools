#Requires Autohotkey v2
#SingleInstance Force
BuildVersion := "Build 6"

;vars
global AppFolder := A_ScriptDir
global AppPluginsFolder := AppFolder . "\Plugins"
global AppSettingsFolder := AppFolder . "\Settings"

myGui := Gui()
myGui.Opt("-MaximizeBox")

Tab := myGui.Add("Tab3", "x0 y0 w688 h416", ["Main", "Plugins"])
Tab.UseTab(1)

;Version control
myGui.Add("GroupBox", "x8 y32 w210 h139", "Update Version")
VersionDropDownList := myGui.Add("DropDownList", "x16 y48 w197", ["CoffeeTools", "Updater", "Launcher", "Installer"])
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
;Script Settings
ogcCheckBoxKeepthisalwaysontop := myGui.Add("CheckBox", "x150 y200 w143 h23", "Keep this always on top")
ogcCheckBoxKeepthisalwaysontop.OnEvent("Click", KeepThisAlwaysOnTop.Bind("Normal"))

Tab.UseTab(2)
;Version control
myGui.Add("GroupBox", "x8 y32 w210 h139", "Update Version")
PlugVersionDropDownList := myGui.Add("DropDownList", "x16 y48 w197")
DropdownGetAllPlugins()
PlugCurrentVersionText := myGui.Add("Text", "x16 y85 w187 h23 +0x200", "Current Version: 0.000")
myGui.Add("Text", "x16 y104 w70 h23 +0x200", "New version:")
PlugEdit1 := myGui.Add("Edit", "x88 y105 w120 h21", "0.000")
PlugVersionDropDownList.OnEvent("Change", UpdatePluginVersion.Bind())
ogcButtonPlugUpdate := myGui.Add("Button", "x10 y136 w50 h23", "Update")
ogcButtonPlugUpdate.OnEvent("Click", UpdatePluginAhkVersion.Bind())
ogcButtonPlugUpdateUp1 := myGui.Add("Button", "x60 y136 w50 h23", "Up 0.1")
ogcButtonPlugUpdateUp1.OnEvent("Click", AddToUpdatePluginNumber.Bind(0.1))
ogcButtonPlugUpdateUp2 := myGui.Add("Button", "x110 y136 w50 h23", "Up 0.01")
ogcButtonPlugUpdateUp2.OnEvent("Click", AddToUpdatePluginNumber.Bind(0.01))
ogcButtonPlugUpdateUp3 := myGui.Add("Button", "x160 y136 w50 h23", "Up 0.001")
ogcButtonPlugUpdateUp3.OnEvent("Click", AddToUpdatePluginNumber.Bind(0.001))

myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Coffee Tools Dev Tools | " BuildVersion
myGui.Show("w563 h345")

;Open scripts
OpenScript(FileName,*)
{
    ;Path
    local StartPath := A_ScriptDir
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
    local ApplicationVersion := GetApplicationVersionName(VersionDropDownList.Value)
    local SelectedVersionText := ApplicationVersion ' := "'

    if(VersionDropDownList.Value == 1)
        SelectedScriptTextFile := "CoffeePoweredAutomationTools"

    local PathToAhkFile := A_ScriptDir "\" VersionDropDownList.Text ".ahk"
    local PathToVersionFile := A_ScriptDir "\" "Version" "\" SelectedScriptTextFile "Version" ".txt"
    local MainScriptAhkFile := A_ScriptDir . "\" . SelectedScript . ".ahk"
    local MainScriptAhkFileTemp := A_ScriptDir . "\" . "Temp" . SelectedScript . ".ahk"


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

        local ChangeStartOnlyOnce := true

        ;Copy and save new version
        loop parse, MainFile, "`n"
        {
            if(InStr(A_LoopField,VersionText) and ChangeStartOnlyOnce)
            {
                MainFileEnd := NewVersionText
                SaveToStart := false
                ChangeStartOnlyOnce := false
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

GetApplicationName(tValue)
{
    switch  tValue{
        case 1:
            return "CoffeeTools"
        case 2:
            return "Updater"
        case 3:
            return "Launcher"
        case 4:
            return "Installer"
        default:
            return "CoffeeTools"
    }
}
GetApplicationVersionName(tValue)
{
    switch  tValue{
        case 1:
            return "Version"
        case 2:
            return "UpdaterVersion"
        case 3:
            return "LauncherVersion"
        case 4:
            return "InstallerVersion"
        default:
            return "Version"
    }
}
UpdateApplicationVersion(*)
{
    ApplicationName := GetApplicationName(VersionDropDownList.Value)
    ApplicationVersion := GetApplicationVersionName(VersionDropDownList.Value)

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
ReadVersionFromAhkFile(VersionVariableName,AhkFile,isPlugin := false)
{
    ;Variables
    local Path := A_ScriptDir "\" AhkFile ".ahk"
    if(isPlugin)
        Path := A_ScriptDir "\Plugins\" AhkFile ".ahk"
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
KeepThisAlwaysOnTop(A_GuiEvent, GuiCtrlObj, Info, *)
{
    WinSetAlwaysOnTop(-1, "A")
}
DropdownGetAllPlugins()
{
    local AllPluginNames := Array()

    LoadedPluginsFile := AppSettingsFolder . "\LoadedPlugins.txt"
    PluginFile := FileRead(LoadedPluginsFile)
    loop parse, PluginFile, "`n"
    {
        local NewWithoutEx := StrSplit(A_LoopField,".")
        AllPluginNames.Push(NewWithoutEx[1])
    }

    PlugVersionDropDownList.Add(AllPluginNames)
}
UpdatePluginVersion(*)
{
    PluginName := GetPluginName(PlugVersionDropDownList.Value)
    PluginVersion := GetPluginVersionName(VersionDropDownList.Value)

    local CurrentVersion := ReadVersionFromAhkFile(PluginVersion,PluginName,true)
    PlugCurrentVersionText.Text := "Current Version: " CurrentVersion
    PlugEdit1.Text := CurrentVersion
}
GetPluginName(ListValue)
{
    return PlugVersionDropDownList.Text
}
GetPluginVersionName(ListValue)
{
    return PlugVersionDropDownList.Text "Version"
}
AddToUpdatePluginNumber(AddAmount,*)
{
    local OldUpdateText := Float(PlugEdit1.Value)
    local NewUpdateText := Round(OldUpdateText + AddAmount,3)
    NewUpdateText := RTrim(NewUpdateText,"0")
    PlugEdit1.Value := NewUpdateText
}

;Update plugin Version
UpdatePluginAhkVersion(*)
{
    ;Variables
    local SelectedScript := PlugVersionDropDownList.Text
    local SelectedScriptTextFile := PlugVersionDropDownList.Text
    local ApplicationVersion := GetPluginVersionName(PlugVersionDropDownList.Value)
    local SelectedVersionText := ApplicationVersion ' := "'

    local PathToAhkFile := A_ScriptDir "\Plugins\" PlugVersionDropDownList.Text ".ahk"
    local PathToVersionFile := A_ScriptDir "\" "Version" "\" SelectedScriptTextFile ".txt"
    local MainScriptAhkFile := A_ScriptDir . "\Plugins\" . SelectedScript . ".ahk"
    local MainScriptAhkFileTemp := A_ScriptDir . "\Temp\" . "Temp" . SelectedScript . ".ahk"

    DirCreate(A_ScriptDir . "\Temp")

    ;Version text file
    if(FileExist(PathToVersionFile) and FileExist(MainScriptAhkFile))
    {
        FileDelete(PathToVersionFile)
        FileAppend(PlugEdit1.Text,PathToVersionFile)
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
        local NewVersionText := SelectedVersionText PlugEdit1.Text '"'

        local ChangeStartOnlyOnce := true

        ;Copy and save new version
        loop parse, MainFile, "`n"
        {
            if(InStr(A_LoopField,VersionText) and ChangeStartOnlyOnce)
            {
                MainFileEnd := NewVersionText
                SaveToStart := false
                ChangeStartOnlyOnce := false
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
        UpdatePluginVersion()
    }
}