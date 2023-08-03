#SingleInstance Force
KeyHistory(0)
; REMOVED: SetBatchLines, -1
ListLines(false)
SendMode("Input") ; Forces Send and SendRaw to use SendInput buffering for speed.
SetTitleMatchMode(3) ; A window's title must exactly match WinTitle to be a match.
SetWorkingDir(A_ScriptDir)
SplitPath(A_ScriptName, , , , &GameScripts)
#MaxThreadsPerHotkey 4 ; no re-entrant hotkey handling
; DetectHiddenWindows, On
SetWinDelay(-1) ; Remove short delay done automatically after every windowing command except IfWinActive and IfWinExist
SetKeyDelay(-1, -1) ; Remove short delay done automatically after every keystroke sent by Send or ControlSend
SetMouseDelay(-1) ; Remove short delay done automatically after Click and MouseMove/Click/Drag
Persistent
;________________________________________________________________________________________________________________________
;//////////////[Changelog]///////////////
Changelog := "
(
Changelog:
AHK v2
)"
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Variables]///////////////
Version := "0.2"
VersionTitle := "AHK v2"
ScriptName := "CoffeeTools"
AppFolderName := "CoffeePoweredAutomationTools"
AppFolder := A_AppData . "\" . AppFolderName
AppSettingsFolder := AppFolder . "\Settings"
AppUpdaterFile := AppFolder . "\Updater.ahk"
AppUpdaterSettingsFile := AppFolder . "\UpdaterInfo.ini"
CurrentScriptBranch := "main"
CloseToTray := false
;//////////////[Tabs]///////////////
HomeTAB := true
SettingsTAB := true
OtherScriptsTAB := false ;Set to true
WindowsTAB := false ;Set to true
;//////////////[Links]///////////////
GithubPage := "https://github.com/veskeli/CoffeePoweredAutomationTools"
;//////////////[ini]///////////////
AppSettingsIni := AppSettingsFolder . "\Settings.ini"
AppGameScriptSettingsIni := AppSettingsFolder . "\GameScriptSettings.ini"
AppHotkeysIni := AppSettingsFolder . "\Hotkeys.ini"
AppVersionIdListIni := AppFolder . "\temp\VersionIdList.ini"
AppPreVersionsIni := AppFolder . "\temp\PreVersions.ini"
;AppOtherScriptsIni := AppOtherScriptsFolder . "\OtherScripts.ini"
;//////////////[Text]///////////////
RandomCoffeeQuotesFile := AppSettingsFolder . "\RandomCoffeeQuotes.txt"
;//////////////[Global variables]///////////////
global Version
global ScriptName
global AppUpdaterSettingsFile
global CurrentScriptBranch
global AppUpdaterFile
global RandomCoffeeQuotesFile
global CloseToTray
;____________________________________________________________
;//////////////[Tab Control]///////////////
if(FileExist(AppSettingsIni))
{
    T_HomeTab := IniRead(AppSettingsIni, "Tabs", "Home", "")
    T_SettingsTab := IniRead(AppSettingsIni, "Tabs", "Settings", "")
    T_OtherScriptsTab := IniRead(AppSettingsIni, "Tabs", "OtherScripts", "")
    T_WindowsTab := IniRead(AppSettingsIni, "Tabs", "Windows", "")
    ; Check bools
    if(T_HomeTab == "0")
        HomeTAB := false
    if(T_SettingsTab == "0")
        SettingsTAB := false
    if(T_OtherScriptsTab == "0")
        OtherScriptsTAB := false
    if(T_WindowsTab == "0")
        WindowsTAB := false
}
myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.OnEvent("Escape", GuiEscape)
myGui.SetFont("s9", "Segoe UI")
; Build tabs
TabHandle := Array()
if(HomeTAB)
    TabHandle.Push("Home")
if(SettingsTAB)
    TabHandle.Push("Settings")
if(OtherScriptsTAB)
    TabHandle := "Other Scripts"
if(WindowsTAB)
    TabHandle := "Windows"
Tab := myGui.Add("Tab3", "x0 y0 w898 h640", TabHandle)
UpdateTrayicon()
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Home]///////////////
if(HomeTAB)
{
    Tab.UseTab("Home")
    ;Quick Actions
    myGui.SetFont()
    myGui.Add("GroupBox", "x8 y32 w300 h110", "Quick actions")
    ogcButtonIPConfig := myGui.Add("Button", "x16 y56 w80 h23", "IPConfig")
    ogcButtonIPConfig.OnEvent("Click", RunIpConfig.Bind("Normal"))
    ogcButtonAppdata := myGui.Add("Button", "x16 y80 w80 h23", "Appdata")
    ogcButtonAppdata.OnEvent("Click", OpenAppdataFolder.Bind("Normal"))
    ogcButtonStartupfolder := myGui.Add("Button", "x96 y56 w80 h23", "Startup folder")
    ogcButtonStartupfolder.OnEvent("Click", OpenStartupFolder.Bind("Normal"))
    ogcButtonOpenSounds := myGui.Add("Button", "x96 y80 w80 h23", "Open Sounds")
    ogcButtonOpenSounds.OnEvent("Click", OpenSounds.Bind("Normal"))
    ogcButtonClearWindowsTempFolder := myGui.Add("Button", "x16 y104 w164 h28 +Disabled", "Clear Windows Temp Folder")
    ogcButtonClearWindowsTempFolder.OnEvent("Click", ClearWindowsTempFolder.Bind("Normal"))
    ;Always on top
    myGui.SetFont()
    myGui.Add("GroupBox", "x8 y152 w300 h62", "Toggle any application to Always on top by hotkey")
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Settings]///////////////
if(SettingsTAB)
{
    Tab.UseTab("Settings")
    ;Admin
    myGui.SetFont()
    myGui.Add("GroupBox", "x8 y32 w175 h88", "Admin")
    ogcRunAsThisAdminButton := myGui.Add("Button", "x16 y56 w152 h23  vRunAsThisAdminButton +Disabled", "Run This Script as admin")
    ogcRunAsThisAdminButton.OnEvent("Click", RunAsThisAdmin.Bind("Normal"))
    ogcRunAsThisAdminCheckbox := myGui.Add("CheckBox", "x16 y88 w152 h23  vRunAsThisAdminCheckbox +Disabled", "Run as admin on script start")
    ogcRunAsThisAdminCheckbox.OnEvent("Click", RunAsThisAdminCheckboxButton.Bind("Normal"))
    ;Shortcut
    myGui.SetFont()
    myGui.Add("GroupBox", "x182 y31 w120 h63", "Shortcut")
    ogcButtonShortcuttoDesktop := myGui.Add("Button", "x192 y48 w95 h35", "Shortcut to Desktop")
    ogcButtonShortcuttoDesktop.OnEvent("Click", Shortcut_to_desktop.Bind("Normal"))
    ;Report an issue
    myGui.SetFont("s15")
    ogcButtonReportanissueorbug := myGui.Add("Button", "x624 y32 w206 h35", "Report an issue or bug")
    ogcButtonReportanissueorbug.OnEvent("Click", ReportAnIssueOrBug.Bind("Normal"))
    ;Settings for this script
    myGui.SetFont()
    myGui.Add("GroupBox", "x8 y122 w175 h160", "Settings for this script.")
    ogcCheckBoxKeepthisalwaysontop := myGui.Add("CheckBox", "x16 y144 w143 h23", "Keep this always on top")
    ogcCheckBoxKeepthisalwaysontop.OnEvent("Click", KeepThisAlwaysOnTop.Bind("Normal"))
    ogcOnExitCloseToTrayCheckbox := myGui.Add("CheckBox", "x16 y168 w140 h23  vOnExitCloseToTrayCheckbox +Disabled", "On Exit close to tray")
    ogcOnExitCloseToTrayCheckbox.OnEvent("Click", OnExitCloseToTray.Bind("Normal"))
    ogcButtonRedownloadassets := myGui.Add("Button", "x16 y192 w133 h28 +Disabled", "Redownload assets")
    ogcButtonShowChangelog := myGui.Add("Button", "x16 y224 w133 h23", "Show Changelog")
    ogcButtonShowChangelog.OnEvent("Click", ShowChangelogButton.Bind("Normal"))
    ogcButtonCustomizeTabs := myGui.Add("Button", "x16 y252 w133 h23 +Disabled", "Customize Tabs")
    ;Debug
    myGui.SetFont()
    myGui.Add("GroupBox", "x8 y295 w170 h123", "Debug")
    ogcButtonOpenScriptFolder := myGui.Add("Button", "x16 y312 w110 h23", "Open Script Folder")
    ogcButtonOpenScriptFolder.OnEvent("Click", OpenScriptFolder.Bind("Normal"))
    ogcButtonOpeningithub := myGui.Add("Button", "x16 y336 w100 h23", "Open in github")
    ogcButtonOpeningithub.OnEvent("Click", OpenThisInGithub.Bind("Normal"))
    ogcButtonOpenSettingsFolder := myGui.Add("Button", "x16 y360 w139 h27", "Open Settings Folder")
    ogcButtonOpenSettingsFolder.OnEvent("Click", OpenAppSettingsFolder.Bind("Normal"))
    ogcButtonOpensettingsFile := myGui.Add("Button", "x16 y392 w116 h23", "Open settings File")
    ogcButtonOpensettingsFile.OnEvent("Click", OpenAppSettingsFile.Bind("Normal"))
    ;Delete
    myGui.SetFont()
    myGui.Add("GroupBox", "x8 y419 w170 h80", "Delete")
    ogcButtonDeleteallsettings := myGui.Add("Button", "x16 y440 w103 h23 +Disabled", "Delete all settings")
    ogcButtonDeleteallsettings.OnEvent("Click", DeleteAppSettings.Bind("Normal"))
    ogcButtonUninstall := myGui.Add("Button", "x16 y464 w103 h23 +Disabled", "Uninstall")
    ;Updates
    myGui.SetFont()
    myGui.Add("GroupBox", "x648 y392 w179 h117", "Updates")
    myGui.SetFont("s15")
    myGui.Add("Text", "x664 y472 w158 h28 +0x200", "Version = " . Version)
    myGui.SetFont()
    ogcCheckUpdatesOnStartup := myGui.Add("CheckBox", "x656 y416 w169 h23 vCheckUpdatesOnStartup +Disabled", "Check for updates on startup")
    ogcCheckUpdatesOnStartup.OnEvent("Click", AutoUpdates.Bind("Normal"))
    ogcButtonCheckforupdates := myGui.Add("Button", "x672 y440 w128 h23 +Disabled", "Check for updates")
    ogcButtonCheckforupdates.OnEvent("Click", ButtonCheckForUpdates.Bind("Normal"))
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Check Before Opening Script]///////////////
;Settings tab
if(FileExist(AppSettingsIni))
{
    ;Close To tray
    Temp_CloseToTray := IniRead(AppSettingsIni, "Settings", "CloseToTray", False)
    if(Temp_CloseToTray == true)
    {
        CloseToTray := true
        ogcOnExitCloseToTrayCheckbox.Value := 1
    }
    ;Start As Admin
    Temp_RunAsAdminOnStartup := IniRead(AppSettingsIni, "Settings", "RunAsAdminOnStart")
    if(Temp_RunAsAdminOnStartup == true)
    {
        ogcRunAsThisAdminCheckbox.Value := 1
        if(!A_IsAdmin)
        {
            Run("*RunAs " A_ScriptFullPath)
            ExitApp()
        }
    }
}
;//////////////[Check for updates]///////////////
;Is check for updates enabled
Temp_CheckUpdatesOnStartup := IniRead(AppSettingsIni, "Updates", "CheckOnStartup")
if(Temp_CheckUpdatesOnStartup != "ERROR")
    ogcCheckUpdatesOnStartup.Value := Temp_CheckUpdatesOnStartup
if(Temp_CheckUpdatesOnStartup == 1)
{
    CheckForUpdates(False)
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Show Gui]///////////////
;RandomCoffeeText := GetRandomCoffeeFact()
myGui.Title := "Coffee Tools | " . Version . " | " . VersionTitle . " | Alpha | "
myGui.Show("w835 h517")

Return
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[GUI/Tray Actions]///////////////
GuiEscape(*)
{
    ExitApp()
}
GuiClose(*)
{
    if(CloseToTray)
    {
        myGui.Hide()
    }
    else
    {
        ExitApp()
    }
}

EXIT(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{
	ExitApp()
}
OpenMainGui(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{
    myGui.Show()
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Home]///////////////

RunIpConfig(A_GuiEvent, GuiCtrlObj, Info, *)
{
RunWait(A_ComSpec " /k ipconfig")
}
OpenAppdataFolder(A_GuiEvent, GuiCtrlObj, Info, *)
{
Run(A_AppData)
}
OpenStartupFolder(A_GuiEvent, GuiCtrlObj, Info, *)
{
Run(A_Startup)
}
OpenSounds(A_GuiEvent, GuiCtrlObj, Info, *)
{
Run("mmsys.cpl")
}
ClearWindowsTempFolder(A_GuiEvent, GuiCtrlObj, Info, *)
{
ProgressGui := Gui("-Caption"), ProgressGui.Title := "Deleting Temporary Files..." , ProgressGui.SetFont("Bold"), ProgressGui.AddText("x0 w300 Center", "Deleting Temporary Files..."), gocProgress := ProgressGui.AddProgress("x10 w280 h20"), ProgressGui.SetFont(""), ProgressGui.AddText("x0 w300 Center", "Wait while the script is deleting temporary files."), ProgressGui.Show("W300")
dir := A_Temp
FileDelete(dir "\*.*")
Loop Files, dir "\*.*", "D"
{
    gocProgress.Value := %A_Index%
    DirDelete(A_LoopFileFullPath, 1)
}
gocProgress.Value := 100
ProgressGui.Destroy
MsgBox("Unused temporary files deleted.", "All Done!", "T5")
return
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Settings]///////////////
;Admin
RunAsThisAdmin(A_GuiEvent, GuiCtrlObj, Info, *)
{
Run("*RunAs " A_ScriptFullPath)
ExitApp()
}
RunAsThisAdminCheckboxButton(A_GuiEvent, GuiCtrlObj, Info, *)
{
oSaved := myGui.Submit("0")
RunAsThisAdminCheckbox := oSaved.RunAsThisAdminCheckbox
OnExitCloseToTrayCheckbox := oSaved.OnExitCloseToTrayCheckbox
CheckUpdatesOnStartup := oSaved.CheckUpdatesOnStartup
IniWrite(RunAsThisAdminCheckbox, AppSettingsIni, "Settings", "RunAsAdminOnStart")
return
}
;Shortcut
Shortcut_to_desktop(A_GuiEvent, GuiCtrlObj, Info, *)
{
MsgBox("Not Working yet", "", "T25")
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
}
;Report an issue
ReportAnIssueOrBug(A_GuiEvent, GuiCtrlObj, Info, *)
{
Run(GithubPage . "/issues")
return
}
;Settings for this script
KeepThisAlwaysOnTop(A_GuiEvent, GuiCtrlObj, Info, *)
{
WinSetAlwaysOnTop(, "A")
return
}
OnExitCloseToTray(A_GuiEvent, GuiCtrlObj, Info, *)
{
    oSaved := myGui.Submit("0")
    RunAsThisAdminCheckbox := oSaved.RunAsThisAdminCheckbox
    OnExitCloseToTrayCheckbox := oSaved.OnExitCloseToTrayCheckbox
    CheckUpdatesOnStartup := oSaved.CheckUpdatesOnStartup
    if(OnExitCloseToTrayCheckbox)
    {
        CloseToTray := true
        IniWrite("true", AppSettingsIni, "Settings", "CloseToTray")
    }
    else
    {
        CloseToTray := false
        IniWrite("false", AppSettingsIni, "Settings", "CloseToTray")
    }
}
ShowChangelogButton(A_GuiEvent, GuiCtrlObj, Info, *)
{
ShowChangelogMsgBox(Changelog)
}
;Debug
OpenScriptFolder(A_GuiEvent, GuiCtrlObj, Info, *)
{
 ;[TODO] add this
}
OpenThisInGithub(A_GuiEvent, GuiCtrlObj, Info, *)
{
Run(GithubPage)
}
OpenAppSettingsFolder(A_GuiEvent, GuiCtrlObj, Info, *)
{
Run(AppSettingsFolder)
}
OpenAppSettingsFile(A_GuiEvent, GuiCtrlObj, Info, *)
{
Run(AppSettingsIni)
}
;Delete
DeleteAppSettings(A_GuiEvent, GuiCtrlObj, Info, *)
{
msgResult := MsgBox("All Settings will be deleted!", "Are you sure?", "1 T15")
if (msgResult = "Cancel")
{
	return
}
else
{
    DirDelete(AppSettingsFolder, 1)
    ;Reset all settings when settings files are removed
    ogcCheckUpdatesOnStartup.Value := 0
}
}
;Updates
AutoUpdates(A_GuiEvent, GuiCtrlObj, Info, *)
{
oSaved := myGui.Submit("0")
RunAsThisAdminCheckbox := oSaved.RunAsThisAdminCheckbox
OnExitCloseToTrayCheckbox := oSaved.OnExitCloseToTrayCheckbox
CheckUpdatesOnStartup := oSaved.CheckUpdatesOnStartup
DirCreate(AppFolder)
DirCreate(AppSettingsFolder)
IniWrite(CheckUpdatesOnStartup, AppSettingsIni, "Updates", "CheckOnStartup")
}
ButtonCheckForUpdates(A_GuiEvent, GuiCtrlObj, Info, *)
{
CheckForUpdates(True)
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Functions]///////////////

UpdateTrayicon()
{
        ;Tray:= A_TrayMenu
        ;Tray.Click("1")
        ;Tray.Delete()
        ;Tray.Delete() ; V1toV2: not 100% replacement of NoStandard, Only if NoStandard is used at the beginning
        ;Tray.Add("Show GUI", OpenMainGui)
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
        ;Tray.Add("E&xit", EXIT)
        ;Tray.Default := "Show GUI"
        ;Tray.Tip("Game Script Ahk")
}
NotAdminError(T_CustomMessage := "")
{
    if(T_CustomMessage != "")
    {
        if(!A_IsAdmin)
        {
            msgResult := MsgBox(T_CustomMessage "`nPress `"Ok`" to run this script as admin", "Needs admin privileges", 1)
            if (msgResult = "ok")
            {
                Run("*RunAs " A_ScriptFullPath)
                ExitApp()
            }
        }
    }
    Else
    {
        if(!A_IsAdmin)
        {
            msgResult := MsgBox("This feature needs admin privileges`nPress `"Ok`" to run this script as admin", "Needs admin privileges", 1)
            if (msgResult = "ok")
            {
                Run("*RunAs " A_ScriptFullPath)
                ExitApp()
            }
        }
    }
}
CheckForUpdates(ShowRunningLatestMessage)
{
    if(!FileExist(AppUpdaterFile))
    {
        ;Updater File Missing!!
        ;[TODO]
        MsgBox("Updater File Is Missing!")
    }
    else
    {
        IniWrite(Version, AppUpdaterSettingsFile, "Options", "Version")
        IniWrite(A_ScriptFullPath, AppUpdaterSettingsFile, "Options", "ScriptFullPath")
        IniWrite(CurrentScriptBranch, AppUpdaterSettingsFile, "Options", "Branch")
        IniWrite(ShowRunningLatestMessage, AppUpdaterSettingsFile, "Options", "ShowRunningLatestMessage")

        Run(AppUpdaterFile)
    }
}
ShowChangelogMsgBox(messageText) {
    MsgBox(messageText, "Changelog [" Version "]", "")
}
GetRandomCoffeeFact()
{
    if FileExist(RandomCoffeeQuotesFile)
    {
        Facts := Fileread(RandomCoffeeQuotesFile)
        myArray := StrSplit(Facts, "`n")
        randomElement := myArray[GetRandomInRange(1, myArray.maxindex() )]
        Return randomElement
    }
    Else
    {
        Return
    }
}
GetRandomInRange(min, max) {
	out := Random(min, max)
	return out
}