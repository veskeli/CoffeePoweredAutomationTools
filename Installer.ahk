#SingleInstance, Force
SetBatchLines, -1
ListLines, Off
SetWorkingDir, %A_ScriptDir%
SplitPath, A_ScriptName, , , , GameScripts
#Persistent
;____________________________________________________________
;//////////////[Installer]///////////////
InstallerVersion = 0.3
global InstallerVersion
VersionUrlGithub := % "https://raw.githubusercontent.com/veskeli/GameScriptsByVeskeli/"
AppGithubDownloadURL := % "https://raw.githubusercontent.com/veskeli/GameScriptsByVeskeli/main/GameScripts.ahk"
;Braches [main] [Experimental] [PreRelease]
;____________________________________________________________
;//////////////[Folders]///////////////
ScriptName = CoffeeTools
AppFolderName = CoffeePoweredAutomationTools
AppFolder = %A_AppData%\%AppFolderName%
AppSettingsFolder = %AppFolder%\Settings
AppUpdaterFile = %AppFolder%\Updater.ahk
GuiPictureFolder = %AppFolder%\Gui
MainScriptFile = %AppFolder%\%ScriptName%
MainScriptAhkFile = %AppFolder%\%ScriptName%.ahk
AppUpdaterSettingsFile = %AppFolder%\UpdaterInfo.ini
AppVersionSettingsFile = %AppFolder%\VersionInfo.ini
AppScriptTempFile = %A_ScriptDir%\GameSciptTemp.ini
DownloadLocation = % A_ScriptDir . "\" . ScriptName . ".ahk"
;//////////////[Other Scripts]///////////////
AppGamingScriptsFolder = %AppFolder%\GamingScripts
AppOtherScriptsFolder = %AppFolder%\OtherScripts
;//////////////[ini]///////////////
AppSettingsIni = %AppSettingsFolder%\Settings.ini
AppGameScriptSettingsIni = %AppSettingsFolder%\GameScriptSettings.ini
AppHotkeysIni = %AppSettingsFolder%\Hotkeys.ini
AppVersionIdListIni = %AppFolder%\temp\VersionIdList.ini
AppPreVersionsIni = %AppFolder%\temp\PreVersions.ini
AppOtherScriptsIni = %AppOtherScriptsFolder%\OtherScripts.ini
;//////////////[Update]///////////////
AppUpdateFile = %AppFolder%\temp\OldFile.ahk
;//////////////[Script Dir]///////////////
ScriptFullPath =
T_SkipShortcut = false
FixUserLocation = false
ShortcutState = 1
AppInstallLocation =
;____________________________________________________________
;____________________________________________________________
;//////////////[Gui]///////////////
Menu Tray, Icon, shell32.dll, 163

Gui -MaximizeBox
Gui Font, s9, Segoe UI
Gui Font
Gui Font, s14
Gui Add, Text, x8 y0 w293 h23 +0x200, Coffee Powered Automation Tools
Gui Font
Gui Font, s9, Segoe UI
Gui Add, Progress, x8 y24 w295 h20 -Smooth vInstallBar, 0
Gui Add, Radio, x8 y48 w45 h23 +Checked vInstallAsAhk, AHK
Gui Add, Radio, x56 y48 w42 h23 vInstallAsExe, EXE
Gui Add, Edit, x8 y72 w259 h21 vLocation, % AppFolder
Gui Add, Button, x272 y72 w24 h23 vChangeLocation, ...
Gui Add, Button, x8 y104 w80 h23 vInstallScriptButton gInstallScript, Install
Gui Add, CheckBox, x96 y104 w120 h23 vShortCutToDesktop, Shortcut to desktop
Gui Add, Button, x224 y104 w80 h23 gCancelInstall, Cancel
Gui Font, s8
Gui Add, Text, x104 y48 w201 h23 +0x200, [Exe can be pinned and contains icon]
Gui Font

Gui Show, w312 h135, Coffee Tools Installer
Return
;____________________________________________________________
;____________________________________________________________
;//////////////[Close]///////////////
GuiEscape:
GuiClose:
CancelInstall:
    ExitApp
;____________________________________________________________
;____________________________________________________________
;//////////////[Install]///////////////
InstallScript:
Gui, Submit, Nohide
SetProgressBarState("0")
SetControlState("Disable")
;Check if already installed
if (FileExist(MainScriptAhkFile))
    {
        IniRead, InstalledCheck, %AppSettingsIni%, install, installFolder, Default
        if(InstalledCheck != "Error" or InstalledCheck != "")
        {
            MsgBox, 4,Already installed, Already installed!`ncontinue?
            IfMsgBox No
            {
                SetProgressBarState("0")
                SetControlState("Enable")
                Return
            }
        }
    }
;Create all folders
FileCreateDir,%AppFolder%
FileCreateDir,%AppSettingsFolder%
SetProgressBarState("10")
try{
    SetProgressBarState("60")
    UrlDownloadToFile, % AppGithubDownloadURL,% AppFolder . "\" . ScriptName . ".ahk"
}
Catch
{
    Try{
        UrlDownloadToFile, % AppGithubDownloadURL,% DownloadLocation
        FileMove, % DownloadLocation, % AppFolder . "\" . ScriptName . ".ahk"
    }
    Catch{
        if(A_IsAdmin)
            {
                MsgBox,,Error,Script is already running as admin`nTry to download Newer or older installer!
                ExitApp
            }
            MsgBox, 4,Install Error, [Main script] URL Download Error `nInstall Can't continue`nWould you like to restart as admin?
            IfMsgBox Yes
            {
                Run *RunAs %A_ScriptFullPath%
                ExitApp
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
MsgBox, 4,Install successful, Would you like to open the script?
IfMsgBox Yes
{
    run,% AppFolder . "\" . ScriptName . ".ahk"
    ExitApp
}
;Install done
SetControlState("Enable")
sleep 2000
SetProgressBarState("0")
Return
;____________________________________________________________
;____________________________________________________________
;//////////////[Voids]///////////////
SetProgressBarState(State)
{
    GuiControl,, InstallBar, %State%
}
SetControlState(State)
{
    GuiControl, %State%,ShortCutToDesktop
    GuiControl, %State%,InstallAsAhk
    GuiControl, %State%,InstallAsExe
    GuiControl, %State%,Location
    GuiControl, %State%,ChangeLocation
    GuiControl, %State%,InstallScriptButton
}