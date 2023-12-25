;TODO
;Install as exe, Shortcut to desktop, Change location and Handle Cancel
#Requires AutoHotkey v2.0+
#SingleInstance Force
ListLines(false)
SetWorkingDir(A_ScriptDir)
SplitPath(A_ScriptName, , , , &GameScripts)
Persistent
;____________________________________________________________
;//////////////[Installer Variables]///////////////
InstallerVersion := "0.52"
global InstallerVersion
;//////////////[Folders]///////////////
ScriptName := "CoffeeTools"
AppFolderName := "CoffeePoweredAutomationTools"
AppFolder := A_AppData . "\" . AppFolderName
AppSettingsFolder := AppFolder . "\Settings"
MainScriptAhkFile := AppFolder . "\" . ScriptName . ".ahk"
DownloadLocation := A_ScriptDir . "\" . ScriptName . ".ahk"
UpdaterDownloadLocation := A_ScriptDir . "\Updater.ahk"
LauncherDownloadLocation := A_ScriptDir . "\Launcher.ahk"
;//////////////[Links]///////////////
GithubReposityLink := "https://raw.githubusercontent.com/veskeli/CoffeePoweredAutomationTools/main/"
AppGithubDownloadURL := GithubReposityLink ScriptName ".ahk"
UpdaterGithubDownloadURL := GithubReposityLink "Updater.ahk"
LauncherGithubDownloadURL := GithubReposityLink "Launcher.ahk"
;//////////////[ini]///////////////
AppSettingsIni := AppSettingsFolder . "\Settings.ini"
;____________________________________________________________
;____________________________________________________________
;//////////////[Gui]///////////////
TraySetIcon("shell32.dll","163")

myGui := Gui()
myGui.OnEvent("Close", GuiEscape)
myGui.OnEvent("Escape", GuiEscape)
myGui.Opt("-MaximizeBox")
myGui.SetFont("s9", "Segoe UI")
myGui.SetFont()
myGui.SetFont("s14")
myGui.Add("Text", "x8 y0 w293 h23 +0x200", "Coffee Powered Automation Tools")
myGui.SetFont()
myGui.SetFont("s9", "Segoe UI")
ogcProgressInstallBar := myGui.Add("Progress", "x8 y24 w295 h20 -Smooth vInstallBar", "0")
ogcRadioInstallAsAhk := myGui.Add("Radio", "x8 y48 w45 h23 +Checked vInstallAsAhk +Disabled", "AHK")
ogcRadioInstallAsExe := myGui.Add("Radio", "x56 y48 w42 h23 vInstallAsExe +Disabled", "EXE")
ogcEditLocation := myGui.Add("Edit", "x8 y72 w259 h21 vLocation +Disabled", AppFolder)
ogcButtonChangeLocation := myGui.Add("Button", "x272 y72 w24 h23 vChangeLocation +Disabled", "...")
;ogcButtonChangeLocation.OnEvent("Click", Button....Bind("Normal"))
ogcInstallScriptButton := myGui.Add("Button", "x8 y104 w80 h23 vInstallScriptButton", "Install")
ogcInstallScriptButton.OnEvent("Click", InstallScript.Bind("Normal"))
ogcCheckBoxShortCutToDesktop := myGui.Add("CheckBox", "x96 y104 w120 h23 vShortCutToDesktop +Disabled", "Shortcut to desktop")
ogcButtonCancel := myGui.Add("Button", "x224 y104 w80 h23", "Cancel")
ogcButtonCancel.OnEvent("Click", GuiEscape.Bind("Normal"))
myGui.SetFont("s8")
myGui.Add("Text", "x104 y48 w201 h23 +0x200", "[Exe can be pinned and contains icon]")
myGui.SetFont()

myGui.Title := "Coffee Tools Installer"
myGui.Show("w312 h135")
Return
;____________________________________________________________
;____________________________________________________________
;//////////////[Close]///////////////
GuiEscape(*)
{
    ExitApp()
}
;____________________________________________________________
;____________________________________________________________
;//////////////[Install]///////////////
InstallScript(A_GuiEvent, GuiCtrlObj, Info, *)
{
    oSaved := myGui.Submit("0")
    InstallAsAhk := oSaved.InstallAsAhk
    InstallAsExe := oSaved.InstallAsExe
    Location := oSaved.Location
    ShortCutToDesktop := oSaved.ShortCutToDesktop
    SetProgressBarState("0")
    SetControlState("Disable")
    ;Check if already installed
    if (FileExist(MainScriptAhkFile))
    {
        InstalledCheck := IniRead(AppSettingsIni, "install", "installFolder", "Default")
        if(InstalledCheck != "Error" or InstalledCheck != "")
        {
            msgResult := MsgBox("Already installed!`ncontinue?", "Already installed", 4)
            if (msgResult = "No")
            {
                SetProgressBarState("0")
                SetControlState("Enable")
                Return
            }
        }
    }
    ;Create all folders
    DirCreate(AppFolder)
    DirCreate(AppSettingsFolder)
    SetProgressBarState("10")
    try{
        SetProgressBarState("60")
        ;App
        Download(AppGithubDownloadURL,AppFolder . "\" . ScriptName . ".ahk")
        ;Updater
        Download(UpdaterGithubDownloadURL,AppFolder . "\Updater.ahk")
        ;Installer
        Download(LauncherGithubDownloadURL,AppFolder "\Launcher.ahk")
    }
    Catch
    {
        Try{
            ;App
            Download(AppGithubDownloadURL,DownloadLocation)
            FileMove(DownloadLocation, AppFolder . "\" . ScriptName . ".ahk")
            ;Updater
            Download(UpdaterGithubDownloadURL,UpdaterDownloadLocation)
            FileMove(UpdaterDownloadLocation, AppFolder . "\Updater.ahk")
            ;Launcher
            Download(LauncherGithubDownloadURL,LauncherDownloadLocation)
            FileMove(LauncherDownloadLocation, AppFolder . "\Launcher.ahk")
        }
        Catch{
            if(A_IsAdmin)
            {
                MsgBox("Script is already running as admin`nTry to download Newer or older installer!", "Error", "")
                ExitApp()
            }
            msgResult := MsgBox("[Main script] URL Download Error `nInstall Can't continue`nWould you like to restart as admin?", "Install Error", 4)
            if (msgResult = "Yes")
            {
                Run("*RunAs " A_ScriptFullPath)
                ExitApp()
            }
            Else
            {
                SetProgressBarState("0")
                SetControlState("Enable")
                Return
            }
        }
    }
    ;Install done
    SetProgressBarState("100")
    ;Would you like to open the script?
    msgResult := MsgBox("Would you like to open the script?", "Install successful", 4)
    if (msgResult = "Yes")
    {
        Run(AppFolder . "\" . ScriptName . ".ahk")
        ExitApp()
    }
    ;Install done
    SetControlState("Enable")
    Sleep(2000)
    SetProgressBarState("0")
}
;____________________________________________________________
;____________________________________________________________
;//////////////[Voids]///////////////
SetProgressBarState(State)
{
    ogcProgressInstallBar.Value := State
}
SetControlState(State)
{
    ;GuiControl, %State%,ShortCutToDesktop
    ;GuiControl, %State%,InstallAsAhk
    ;GuiControl, %State%,InstallAsExe
    ;GuiControl, %State%,Location
}