#SingleInstance, Force
#KeyHistory, 0
SetBatchLines, -1
ListLines, Off
SendMode Input ; Forces Send and SendRaw to use SendInput buffering for speed.
SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
SetWorkingDir, %A_ScriptDir%
SplitPath, A_ScriptName, , , , GameScripts
#MaxThreadsPerHotkey, 4 ; no re-entrant hotkey handling
; DetectHiddenWindows, On
SetWinDelay, -1 ; Remove short delay done automatically after every windowing command except IfWinActive and IfWinExist
SetKeyDelay, -1, -1 ; Remove short delay done automatically after every keystroke sent by Send or ControlSend
SetMouseDelay, -1 ; Remove short delay done automatically after Click and MouseMove/Click/Drag
#Persistent
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Variables]///////////////
Version = 0.01
VersionTitle = Interface Test
ScriptName = CoffeeTools
AppFolderName = CoffeePoweredAutomationTools
AppFolder = %A_AppData%\%AppFolderName%
AppSettingsFolder = %AppFolder%\Settings
AppUpdaterFile = %AppFolder%\Updater.ahk
AppUpdaterSettingsFile = %AppFolder%\UpdaterInfo.ini
CurrentScriptBranch = main
;//////////////[Tabs]///////////////
HomeTAB := true
SettingsTAB := true
OtherScriptsTAB := false ;Set to true
WindowsTAB := false ;Set to true
;//////////////[Links]///////////////
GithubPage = https://github.com/veskeli/CoffeePoweredAutomationTools
;//////////////[ini]///////////////
AppSettingsIni = %AppSettingsFolder%\Settings.ini
AppGameScriptSettingsIni = %AppSettingsFolder%\GameScriptSettings.ini
AppHotkeysIni = %AppSettingsFolder%\Hotkeys.ini
AppVersionIdListIni = %AppFolder%\temp\VersionIdList.ini
AppPreVersionsIni = %AppFolder%\temp\PreVersions.ini
AppOtherScriptsIni = %AppOtherScriptsFolder%\OtherScripts.ini
;//////////////[Global variables]///////////////
global Version
global ScriptName
global AppUpdaterSettingsFile
global CurrentScriptBranch
global AppUpdaterFile
;____________________________________________________________
;//////////////[Tab Control]///////////////
IniRead, T_HomeTab, %AppSettingsIni%,Tabs,Home
IniRead, T_SettingsTab, %AppSettingsIni%,Tabs,Settings
IniRead, T_OtherScriptsTab, %AppSettingsIni%,Tabs,OtherScripts
IniRead, T_WindowsTab, %AppSettingsIni%,Tabs,Windows
; Check bools
if(T_HomeTab == "0")
    HomeTAB := false
if(T_SettingsTab == "0")
    SettingsTAB := false
if(T_OtherScriptsTab == "0")
    OtherScriptsTAB := false
if(T_WindowsTab == "0")
    WindowsTAB := false
Gui 1:Font, s9, Segoe UI
; Build tabs
TabHandle =
if(HomeTAB)
    TabHandle = % "Home"
if(SettingsTAB)
    TabHandle = % TabHandle . "|" . "Settings"
if(OtherScriptsTAB)
    TabHandle = % TabHandle . "|" . "Other Scripts"
if(WindowsTAB)
    TabHandle = % TabHandle . "|" . "Windows"

Gui 1:Add, Tab3, x0 y0 w898 h640, %TabHandle%
UpdateTrayicon()
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Home]///////////////
if(HomeTAB)
{
    Gui 1:Tab, Home
    ;Quick Actions
    Gui 1:Font
    Gui 1:Add, GroupBox, x8 y32 w300 h110, Quick actions
    Gui 1:Add, Button, x16 y56 w80 h23 gRunIpConfig, IPConfig
    Gui 1:Add, Button, x16 y80 w80 h23 gOpenAppdataFolder, Appdata
    Gui 1:Add, Button, x96 y56 w80 h23 gOpenStartupFolder, Startup folder
    Gui 1:Add, Button, x96 y80 w80 h23 gOpenSounds, Open Sounds
    Gui 1:Add, Button, x16 y104 w164 h28 gClearWindowsTempFolder, Clear Windows Temp Folder
    ;Always on top
    Gui 1:Font
    Gui 1:Add, GroupBox, x8 y152 w300 h62, Toggle any application to Always on top by hotkey
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Settings]///////////////
if(SettingsTAB)
{
    Gui 1:Tab, Settings
    ;Admin
    Gui 1:Font
    Gui 1:Add, GroupBox, x8 y32 w175 h88, Admin
    Gui 1:Add, Button, x16 y56 w152 h23 gRunAsThisAdmin vRunAsThisAdminButton, Run This Script as admin
    Gui 1:Add, CheckBox, x16 y88 w152 h23 gRunAsThisAdminCheckboxButton vRunAsThisAdminCheckbox, Run as admin on script start
    ;Shortcut
    Gui 1:Font
    Gui 1:Add, GroupBox, x182 y31 w120 h63, Shortcut
    Gui 1:Add, Button, x192 y48 w95 h35 gShortcut_to_desktop, Shortcut to Desktop
    ;Report an issue
    Gui 1:Font, s15
    Gui 1:Add, Button, x624 y32 w206 h35 gReportAnIssueOrBug, Report an issue or bug
    ;Settings for this script
    Gui 1:Font
    Gui 1:Add, GroupBox, x8 y122 w175 h160, Settings for this script.
    Gui 1:Add, CheckBox, x16 y144 w143 h23 gKeepThisAlwaysOnTop, Keep this always on top
    Gui 1:Add, CheckBox, x16 y168 w140 h23 gOnExitCloseToTray vOnExitCloseToTrayCheckbox, On Exit close to tray
    ;Gui 1:Add, Button, x16 y192 w133 h28 gRedownloadAssets, Redownload assets
    ;Gui 1:Add, Button, x16 y224 w133 h23 gShowChangelogButton, Show Changelog
    ;Gui 1:Add, Button, x16 y252 w133 h23 gCustomizeTabs, Customize Tabs
    ;Debug
    Gui 1:Font
    Gui 1:Add, GroupBox, x8 y295 w170 h123, Debug
    Gui 1:Add, Button, x16 y312 w110 h23 gOpenScriptFolder, Open Script Folder
    Gui 1:Add, Button, x16 y336 w100 h23 gOpenThisInGithub, Open in github
    Gui 1:Add, Button, x16 y360 w139 h27 gOpenAppSettingsFolder, Open Settings Folder
    Gui 1:Add, Button, x16 y392 w116 h23 gOpenAppSettingsFile, Open settings File
    ;Delete
    Gui 1:Font
    Gui 1:Add, GroupBox, x8 y419 w170 h80, Delete
    Gui 1:Add, Button, x16 y440 w103 h23 gDeleteAppSettings, Delete all settings
    Gui 1:Add, Button, x16 y464 w103 h23 +Disabled, Uninstall
    ;Updates
    Gui 1:Font
    Gui 1:Add, GroupBox, x648 y392 w179 h117, Updates
    Gui 1:Font, s15
    Gui 1:Add, Text, x664 y472 w158 h28 +0x200, Version = %Version%
    Gui 1:Font
    Gui 1:Add, CheckBox, x656 y416 w169 h23 vCheckUpdatesOnStartup gAutoUpdates, Check for updates on startup
    Gui 1:Add, Button, x672 y440 w128 h23 gButtonCheckForUpdates, Check for updates
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Check Before Opening Script]///////////////
;Settings tab
if(FileExist(AppSettingsIni))
{
    ;Close To tray
    iniread, Temp_CloseToTray,%AppSettingsIni%,Settings,CloseToTray
    if(%Temp_CloseToTray% == true)
    {
        CloseToTray := true
        GuiControl,1:,OnExitCloseToTrayCheckbox,1
    }
    ;Start As Admin
    iniread, Temp_RunAsAdminOnStartup,%AppSettingsIni%,Settings,RunAsAdminOnStart
    if(Temp_RunAsAdminOnStartup == true)
    {
        GuiControl,1:,RunAsThisAdminCheckbox,1
        if(!A_IsAdmin)
        {
            Run *RunAs %A_ScriptFullPath%
            ExitApp
        }
    }
}
;//////////////[Check for updates]///////////////
;Is check for updates enabled
IniRead, Temp_CheckUpdatesOnStartup, %AppSettingsIni%, Updates, CheckOnStartup
if(Temp_CheckUpdatesOnStartup != "ERROR")
    GuiControl,1:,CheckUpdatesOnStartup,%Temp_CheckUpdatesOnStartup%
if(Temp_CheckUpdatesOnStartup == 1)
{
    CheckForUpdates()
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Show Gui]///////////////
Gui 1:Show, w835 h517, Coffee Tools | %Version% | No Auto Updates!
Return
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[GUI/Tray Actions]///////////////
GuiEscape:
    ExitApp
GuiClose:
if(CloseToTray)
{
    Gui, 1:Hide
}
else
{
    ExitApp
}
Return

EXIT:
	ExitApp
Return
OpenMainGui:
    Gui, 1:Show
return
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Home]///////////////
RunIpConfig:
runwait %ComSpec% /k ipconfig
return
OpenAppdataFolder:
run, %A_AppData%
return
OpenStartupFolder:
run, %A_Startup%
return
OpenSounds:
Run, mmsys.cpl
return
ClearWindowsTempFolder:
Progress, b w300, Wait while the script is deleting temporary files., Deleting Temporary Files..., Deleting Temporary Files...
dir= %A_Temp%
FileDelete, %dir%\*.*
Loop, %dir%\*.*, 2
{
    Progress, %A_Index%
    FileRemoveDir, %A_LoopFileLongPath%,1
}
Progress, 100
Progress, Off
MsgBox,,All Done!,Unused temporary files deleted.,5
return
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Settings]///////////////
;Admin
RunAsThisAdmin:
Run *RunAs %A_ScriptFullPath%
ExitApp
RunAsThisAdminCheckboxButton:
Gui, 1:Submit, Nohide
IniWrite, %RunAsThisAdminCheckbox%,%AppSettingsIni%,Settings,RunAsAdminOnStart
return
;Shortcut
Shortcut_to_desktop:
MsgBox,,,Not Working yet,25
/*
if(IsEXERunnerEnabled)
{
    IniRead, T_RevertLocation,%AppSettingsIni%, ExeRunner, ExeFileLocation
    if(T_RevertLocation = "ERROR")
    {
        iniread,T_RevertLocation,%AppSettingsIni%, ExeRunner, OldAhkFileLocation
    }
    IniRead, UseCorrectFolder,%AppSettingsIni%,Appdata,UseCorrectFolder
    if(UseCorrectFolder == "true")
    {
        IniRead, CorrectDesktop,%AppSettingsIni%,Appdata,CorrectDesktop
        FileCreateShortcut,% T_RevertLocation . "\" . ScriptName . ".exe", %CorrectDesktop%\%ScriptName%.lnk
    }
    Else
    {
        FileCreateShortcut,% T_RevertLocation . "\" . ScriptName . ".exe", %A_Desktop%\%ScriptName%.lnk
    }
}
else
{
    FileCreateShortcut,"%A_ScriptFullPath%", %A_Desktop%\%ScriptName%.lnk
}
*/
return
;Report an issue
ReportAnIssueOrBug:
run, % GithubPage . "/issues"
return
;Settings for this script
KeepThisAlwaysOnTop:
WinSet, AlwaysOnTop,, A
return
OnExitCloseToTray:
Gui, 1:Submit, Nohide
if(OnExitCloseToTrayCheckbox)
{
    CloseToTray := true
    IniWrite, true,%AppSettingsIni%,Settings,CloseToTray
}
else
{
    CloseToTray := false
    IniWrite, false,%AppSettingsIni%,Settings,CloseToTray
}
return
;Debug
OpenScriptFolder:
run, %A_ScriptDir%
return
OpenThisInGithub:
run, % GithubPage
return
OpenAppSettingsFolder:
run, %AppFolder%
return
OpenAppSettingsFile:
run, %AppSettingsIni%
return
;Delete
DeleteAppSettings:
MsgBox, 1,Are you sure?,All Settings will be deleted!, 15
IfMsgBox, Cancel
{
	return
}
else
{
    FileRemoveDir, %AppSettingsFolder%,1
    ;Reset all settings when settings files are removed
    GuiControl,1:,CheckUpdatesOnStartup,0
}
return
;Updates
AutoUpdates:
Gui, 1:Submit, Nohide
FileCreateDir, %AppFolder%
FileCreateDir, %AppSettingsFolder%
IniWrite, %CheckUpdatesOnStartup%, %AppSettingsIni%, Updates, CheckOnStartup
return
ButtonCheckForUpdates:
CheckForUpdates()
Return
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Functions]///////////////
UpdateTrayicon()
{
        Menu,Tray,Click,1
        Menu,Tray,DeleteAll
        Menu,Tray,NoStandard
        Menu,Tray,Add,Show GUI,OpenMainGui
        ;Menu,Tray,Add
        ;Menu,GameActions,Add,Xbox Overlay,ToggleXboxOverlay2
        ;Menu,GameActions,Add,Game DVR,ToggleGameDVR2
        ;Menu,GameActions,Add,Clear Windows Temp Folder,ClearWindowsTempFolder
        ;Menu,Tray,Add, Game Actions, :GameActions
        ;Menu,QuickActions,Add,Open Programs && Features,OpenProgramsAndFeatures
        ;Menu,QuickActions,Add,Open Sounds,OpenSounds
        ;Menu,QuickActions,Add,Open Power Options,OpenPowerSettings
        ;Menu,QuickActions,Add,Open System Properties,OpenSystemProperties
        ;Menu,Tray,Add, Quick Actions, :QuickActions
        ;Menu,Tray,Add
        ;Menu,Tray,Add,Open Appdata Folder,OpenAppdataFolder
        ;Menu,Tray,Add,Run IpConfig,RunIpConfig
        ;Menu,Tray,Add,Open Sounds,OpenSounds
        ;Menu,Tray,Add
        Menu,Tray,Add,E&xit,EXIT
        Menu,Tray,Default,Show GUI
        Menu,Tray,Tip, Game Script Ahk
}
NotAdminError(T_CustomMessage = "")
{
    if(T_CustomMessage != "")
    {
        if(!A_IsAdmin)
        {
            MsgBox, 1,Needs admin privileges,%T_CustomMessage%`nPress "Ok" to run this script as admin
            IfMsgBox, ok
            {
                Run *RunAs %A_ScriptFullPath%
                ExitApp
            }
        }
    }
    Else
    {
        if(!A_IsAdmin)
        {
            MsgBox, 1,Needs admin privileges,This feature needs admin privileges`nPress "Ok" to run this script as admin
            IfMsgBox, ok
            {
                Run *RunAs %A_ScriptFullPath%
                ExitApp
            }
        }
    }
}
CheckForUpdates()
{
    if(!FileExist(AppUpdaterFile))
    {
        ;Updater File Missing!!
        ;[TODO]
        MsgBox Updater File Is Missing!
    }
    else
    {
        IniWrite, %Version%,%AppUpdaterSettingsFile%,Options,Version
        IniWrite, %A_ScriptFullPath%,%AppUpdaterSettingsFile%,Options,ScriptFullPath
        IniWrite, %CurrentScriptBranch%,%AppUpdaterSettingsFile%,Options,Branch

        run, %AppUpdaterFile%
    }
}