;<---#Include--->
#Requires AutoHotkey v2.0+
#SingleInstance Force
KeyHistory(0)
ListLines(false)
SendMode("Input") ; Forces Send and SendRaw to use SendInput buffering for speed.
SetTitleMatchMode(3) ; A window's title must exactly match WinTitle to be a match.
SetWorkingDir(A_ScriptDir)
SplitPath(A_ScriptName, , , , &GameScripts)
#MaxThreadsPerHotkey 4 ; no re-entrant hotkey handling
; DetectHiddenWindows, On
;SetWinDelay(-1) ; Remove short delay done automatically after every windowing command except IfWinActive and IfWinExist
;SetKeyDelay(-1, -1) ; Remove short delay done automatically after every keystroke sent by Send or ControlSend
;SetMouseDelay(-1) ; Remove short delay done automatically after Click and MouseMove/Click/Drag
Persistent
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Coffee Tools]///////////////
Version := "0.34832"
VersionMode := "Alpha"
;//////////////[Folders]///////////////
ScriptName := "CoffeeTools"
AppFolderName := "CoffeePoweredAutomationTools"
;AppFolder := A_AppData . "\" . AppFolderName
AppFolder := A_ScriptDir
AppPluginsFolder := AppFolder . "\Plugins"
AppSettingsFolder := AppFolder . "\Settings"
AppUpdaterFile := AppFolder . "\Updater.ahk"
AppUpdaterSettingsFile := AppFolder . "\UpdaterInfo.ini"
LauncherAhkFile := AppFolder . "\Launcher.ahk"
MainScriptAhkFile := AppFolder . "\" . ScriptName . ".ahk"
MainScriptAhkFileWithPlugins := AppFolder . "\" . ScriptName . "WithPlugins.ahk"
;//////////////[Variables]///////////////
VersionTitle := "Plugin Support"
CurrentScriptBranch := "main"
CloseToTray := false
global PluginsLoaded := false
PluginsInManagerCount := 1
global IsPluginSettingsOpen := false
global PluginNameList := Array()
global PluginLoadError := false
;//////////////[Tabs]///////////////
HomeTAB := true
SettingsTAB := true
OtherScriptsTAB := false ;Set to true
WindowsTAB := false ;Set to true
;//////////////[Links]///////////////
GithubPage := "https://github.com/veskeli/CoffeePoweredAutomationTools"
global GithubReposityLink := "https://raw.githubusercontent.com/veskeli/CoffeePoweredAutomationTools/"
RawGithubPage := "https://raw.githubusercontent.com/veskeli/CoffeePoweredAutomationTools"
PluginGithubLink := RawGithubPage "/" CurrentScriptBranch "/Plugins"
AllPluginsFile := RawGithubPage "/" CurrentScriptBranch "/Plugins/AllPlugins.txt"
;//////////////[ini]///////////////
AppSettingsIni := AppSettingsFolder . "\Settings.ini"
AppGameScriptSettingsIni := AppSettingsFolder . "\GameScriptSettings.ini"
AppHotkeysIni := AppSettingsFolder . "\Hotkeys.ini"
AppVersionIdListIni := AppFolder . "\temp\VersionIdList.ini"
AppPreVersionsIni := AppFolder . "\temp\PreVersions.ini"
;AppOtherScriptsIni := AppOtherScriptsFolder . "\OtherScripts.ini"
;//////////////[Text]///////////////
RandomCoffeeQuotesFile := AppSettingsFolder . "\RandomCoffeeQuotes.txt"
LoadedPluginsFile := AppSettingsFolder . "\LoadedPlugins.txt"
;//////////////[Global variables]///////////////
global Version
global VersionMode
global ScriptName
global AppUpdaterSettingsFile
global CurrentScriptBranch
global AppUpdaterFile
global RandomCoffeeQuotesFile
global CloseToTray
;____________________________________________________________
;//////////////[Tab Control and plugin control]///////////////
if(FileExist(AppSettingsIni))
{
    ;Check tabs
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
    ;Check Plugins
    LoadPluginsOnStart := IniRead(AppSettingsIni,"PluginLoader","RunOnStart",false)
    PluginLoadError := IniRead(AppSettingsIni,"Error","PluginLoad",false)
    if(!PluginsLoaded)
    {
        if(PluginLoadError or PluginLoadError == 1)
        {
            MsgBox("Plugin load failed. reinstalling plugins may fix this issue")
            IniWrite(0,AppSettingsIni,"Error","PluginLoad")
        }
        else
        {
            if(LoadPluginsOnStart or LoadPluginsOnStart == 1)
            {
                RunWithPlugins()
            }
        }
    }
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
if(PluginsLoaded) ;Add plugins to tabs
{
    if(FileExist(LoadedPluginsFile))
    {
        PluginFile := FileRead(LoadedPluginsFile)
        loop parse, PluginFile, "`n"
        {
            PluginName := StrReplace(A_LoopField,".ahk")
            TabHandle.Push(PluginName)
            PluginNameList.Push(PluginName)
        }
    }
    else
    {
        PluginsLoaded := false
    }
}
global Tab := myGui.Add("Tab3", "x0 y0 w898 h640", TabHandle)
UpdateTrayicon()
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Home]///////////////
global TabHeight := 26
if(HomeTAB)
{
    Tab.UseTab("Home")

    ;HomeScreenCategory("QuickActions")

    myGui.SetFont("s15")
    temphomescreentext := "
(
While a home screen is planned for the future, it is not currently a priority.
Our current focus is on developing new features, presented in the form of plugins.

(Temporarily set the starting tab in settings.)
)"
    myGui.Add("Text", "x10 y25 w600 h300", temphomescreentext)
    myGui.SetFont()
    ;Always on top
    ;myGui.SetFont()
    ;myGui.Add("GroupBox", "x8 y152 w300 h62", "Toggle any application to Always on top by hotkey")
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
    ogcRunAsThisAdminButton := myGui.Add("Button", "x16 y56 w152 h23  vRunAsThisAdminButton", "Run This Script as admin")
    ogcRunAsThisAdminButton.OnEvent("Click", RunAsThisAdmin.Bind("Normal"))
    ogcRunAsThisAdminCheckbox := myGui.AddCheckbox("x16 y88 w152 h23  vRunAsThisAdminCheckbox", "Run as admin on script start")
    ogcRunAsThisAdminCheckbox.OnEvent("Click", RunAsThisAdminCheckboxButton.Bind("Normal"))
    ;Shortcut
    myGui.SetFont()
    myGui.Add("GroupBox", "x182 y31 w120 h63", "Shortcut")
    ogcButtonShortcuttoDesktop := myGui.Add("Button", "x192 y48 w95 h35 +Disabled", "Shortcut to Desktop")
    ogcButtonShortcuttoDesktop.OnEvent("Click", Shortcut_to_desktop.Bind("Normal"))
    ;Plugin Manager
    myGui.Add("GroupBox", "x301 y31 w195 h63", "Plugin Manager")
    myGui.SetFont("s13")
    ogcButtonCustomizeTabs := myGui.Add("Button", "x312 y48 w167 h36", "Plugin Manager")
    ogcButtonCustomizeTabs.OnEvent("Click",CustomizePlugins.Bind("Normal"))
    myGui.SetFont()
    ;Report an issue
    myGui.SetFont("s15")
    ogcButtonReportanissueorbug := myGui.Add("Button", "x624 y32 w206 h35", "Report an issue or bug")
    ogcButtonReportanissueorbug.OnEvent("Click", ReportAnIssueOrBug.Bind("Normal"))
    ;Settings for this script
    myGui.SetFont()
    myGui.Add("GroupBox", "x8 y122 w175 h168", "Settings for this script.")
    ogcCheckBoxKeepthisalwaysontop := myGui.Add("CheckBox", "x16 y138 w143 h23", "Keep this always on top")
    ogcCheckBoxKeepthisalwaysontop.OnEvent("Click", KeepThisAlwaysOnTop.Bind("Normal"))
    ogcOnExitCloseToTrayCheckbox := myGui.Add("CheckBox", "x16 y158 w140 h23  vOnExitCloseToTrayCheckbox", "On Exit close to tray")
    ogcOnExitCloseToTrayCheckbox.OnEvent("Click", OnExitCloseToTray.Bind("Normal"))
    ogcButtonRedownloadassets := myGui.Add("Button", "x16 y180 w133 h28", "Redownload assets")
    ogcButtonRedownloadassets.OnEvent("Click", RedownloadAssets.Bind("Normal"))
    ogcButtonRunAlwaysWithPlugins := myGui.Add("Checkbox", "x16 y210 w145 h23", "Run always with plugins")
    ogcButtonRunAlwaysWithPlugins.OnEvent("Click",SetRunPluginsOnLoad.Bind())
    ogcButtonRunWithPlugins := myGui.Add("Button", "x16 y232 w133 h23", "Run with plugins")
    ogcButtonRunWithPlugins.OnEvent("Click",RunWithPlugins.Bind("Normal"))
    myGui.Add("Text", "x14 y264 w100 h23", "Start Tab:")
    ogcButtonStartTab := myGui.Add("DropDownList", "x64 y260 w110", ["Home","Settings"])
    ogcButtonStartTab.OnEvent("Change",SetStartingTab.Bind())
    if(PluginsLoaded)
    {
        ogcButtonRunWithPlugins.Text := "Run without plugins"
    }
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
    ogcButtonDeleteallsettings := myGui.Add("Button", "x16 y440 w103 h23", "Delete all settings")
    ogcButtonDeleteallsettings.OnEvent("Click", DeleteAppSettings.Bind("Normal"))
    ogcButtonUninstall := myGui.Add("Button", "x16 y464 w103 h23", "Uninstall")
    ogcButtonUninstall.OnEvent("Click",UninstallScript.Bind())
    ;Updates
    myGui.SetFont()
    myGui.Add("GroupBox", "x648 y400 w179 h110", "Updates")
    myGui.SetFont("s15")
    myGui.Add("Text", "x664 y463 w158 h23 +0x200", "Version = " . Version)
    myGui.SetFont()
    ogcTextUpdaterVersion := myGui.Add("Text", "x664 y488 w158 h18 +0x200", "Updater missing")
    ogcCheckUpdatesOnStartup := myGui.Add("CheckBox", "x656 y416 w169 h23 vCheckUpdatesOnStartup", "Check for updates on startup")
    ogcCheckUpdatesOnStartup.OnEvent("Click", AutoUpdates.Bind("Normal"))
    ogcButtonCheckforupdates := myGui.Add("Button", "x672 y440 w128 h23", "Check for updates")
    ogcButtonCheckforupdates.OnEvent("Click", ButtonCheckForUpdates.Bind("Normal"))
}
if(PluginsLoaded)
{
try
{
;<---Start_Include--->
;<---End_Include--->
}
catch
{
    ;TODO: Automatic repair
    ;Currently Load normal and show error
    CreateDefaultDirectories()
    IniWrite(1,AppSettingsIni,"Error","PluginLoad")
    IniWrite(0,AppSettingsIni,"PluginLoader","RunOnStart")
    if(FileExist(MainScriptAhkFileWithPlugins))
        FileDelete(MainScriptAhkFileWithPlugins)
    Run(MainScriptAhkFile)
    ExitApp
}
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Check Before Opening Script]///////////////
CreateDefaultDirectories()
;Settings tab

;Starting Tab
If(PluginsLoaded)
{
    ogcButtonStartTab.Add(PluginNameList)
}
StartingTabValue := Integer(1)
;Is Admin
if(A_IsAdmin)
{
    ogcRunAsThisAdminButton.Text := "Already running as admin"
    ogcRunAsThisAdminButton.Enabled := false
}
;Load Settings
if(FileExist(AppSettingsIni))
{
    ;Close To tray
    Temp_CloseToTray := IniRead(AppSettingsIni, "Settings", "CloseToTray", False)
    if(Temp_CloseToTray)
    {
        CloseToTray := true
        ogcOnExitCloseToTrayCheckbox.Value := 1
    }
    ;Start As Admin
    Temp_RunAsAdminOnStartup := IniRead(AppSettingsIni, "Settings", "RunAsAdminOnStart", False)
    if(Temp_RunAsAdminOnStartup == true)
    {
        ogcRunAsThisAdminCheckbox.Value := 1
        if(!A_IsAdmin)
        {
            Run("*RunAs " A_ScriptFullPath)
            ExitApp()
        }
    }
    ;Run plugins at start
    ogcButtonRunAlwaysWithPlugins.Value := IniRead(AppSettingsIni,"PluginLoader","RunOnStart",0)
    ;Starting Tab
    if(PluginsLoaded)
    {
        StartingTabValue := Integer(IniRead(AppSettingsIni,"Settings","StartingTabWithPlugins",1))
    }
    else
    {
        StartingTabValue := Integer(IniRead(AppSettingsIni,"Settings","StartingTab",1))
    }
}
;Starting Tab
Tab.Choose(StartingTabValue)
ogcButtonStartTab.Choose(StartingTabValue)
;Updater
if(FileExist(AppUpdaterFile))
{
    ogcTextUpdaterVersion.Text := ""
    TextFile := FileRead(AppUpdaterFile)
    loop Parse TextFile, "`n"
    {
        if(InStr(A_LoopField,"UpdaterVersion"))
        {
            text := StrReplace(A_LoopField, '"')
            text := StrReplace(text, ':')
            ogcTextUpdaterVersion.Text := text
            break
        }
    }
}
;//////////////[Check for updates]///////////////
;Is check for updates enabled
if(FileExist(AppSettingsIni))
{
    Temp_CheckUpdatesOnStartup := IniRead(AppSettingsIni, "Updates", "CheckOnStartup", False)
    ogcCheckUpdatesOnStartup.Value := Temp_CheckUpdatesOnStartup
    if(Temp_CheckUpdatesOnStartup == 1)
    {
        CheckForUpdates(true)
    }
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Show Gui]///////////////
RandomCoffeeText := GetRandomCoffeeFact()
if(PluginsLoaded)
{
    TitleText := "Coffee Tools W/Plugins | " . Version . " | " . VersionTitle . " | " . VersionMode . " | " . RandomCoffeeText
}
else
{
    TitleText := "Coffee Tools | " . Version . " | " . VersionTitle . " | " . VersionMode . " | " . RandomCoffeeText
}
myGui.Title := TitleText
myGui.Show("w835 h517")
Return
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[GUI/Tray Actions]///////////////
GuiEscape(*)
{
    GuiClose()
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
    ogcButtonOpenSounds.Enabled := false
    Run("mmsys.cpl")
    ogcButtonOpenSounds.Enabled := true
}
ClearWindowsTempFolder(A_GuiEvent, GuiCtrlObj, Info, *)
{
    ProgressGui := Gui("-Caption"), ProgressGui.Title := "Deleting Temporary Files..." , ProgressGui.SetFont("Bold"), ProgressGui.AddText("x0 w300 Center", "Deleting Temporary Files..."), gocProgress := ProgressGui.AddProgress("x10 w280 h20"), ProgressGui.SetFont(""), ProgressGui.AddText("x0 w300 Center", "Wait while the script is deleting temporary files."), ProgressGui.Show("W300")
    MsgBoxText := "Unused temporary files deleted."
    try
    {
        dir := A_Temp
        FileDelete(dir "\*.*")
        Loop Files, dir "\*.*", "D"
        {
            gocProgress.Value := %A_Index%
            DirDelete(A_LoopFileFullPath, 1)
        }
    }
    catch
    {
        MsgBoxText := "FileDelete Failed `nThis is script error`nWill be fixed on later versions"
    }
    gocProgress.Value := 100
    ProgressGui.Destroy
    MsgBox(MsgBoxText, "Temp Clear", "T5")
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
    CreateDefaultDirectories()
    oSaved := myGui.Submit("0")
    RunAsThisAdminCheckbox := oSaved.RunAsThisAdminCheckbox
    OnExitCloseToTrayCheckbox := oSaved.OnExitCloseToTrayCheckbox
    CheckUpdatesOnStartup := oSaved.CheckUpdatesOnStartup
    IniWrite(RunAsThisAdminCheckbox, AppSettingsIni, "Settings", "RunAsAdminOnStart")
}
;Shortcut
Shortcut_to_desktop(A_GuiEvent, GuiCtrlObj, Info, *)
{
    MsgBox("Not Working yet", "", "T25")
    ;TODO:
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
;Plugin Manager
CustomizePlugins(A_GuiEvent, GuiCtrlObj, Info, *)
{
    PluginManagerInt()
    PluginManagerGui.Show()
}
;Report an issue
ReportAnIssueOrBug(A_GuiEvent, GuiCtrlObj, Info, *)
{
    Run(GithubPage . "/issues")
}
;Settings for this script
KeepThisAlwaysOnTop(A_GuiEvent, GuiCtrlObj, Info, *)
{
    WinSetAlwaysOnTop(-1, "A")
}
OnExitCloseToTray(A_GuiEvent, GuiCtrlObj, Info, *)
{
    CreateDefaultDirectories()
    if(ogcOnExitCloseToTrayCheckbox.Value == 1)
    {
        global CloseToTray := true
        IniWrite("1", AppSettingsIni, "Settings", "CloseToTray")
    }
    else
    {
        global CloseToTray := false
        IniWrite("0", AppSettingsIni, "Settings", "CloseToTray")
    }
}
RedownloadAssets(*)
{
    if(FileExist(AppUpdaterFile))
    {
        CreateDefaultDirectories()
        IniWrite(True, AppUpdaterSettingsFile, "Options", "RedownloadAssets")
        Run(AppUpdaterFile)
    }
    else
    {
        ;Updater File Missing!!
        ;TODO:
        MsgBox("Updater File Is Missing!")
    }
}
SetRunPluginsOnLoad(*)
{
    CreateDefaultDirectories()
    IniWrite(ogcButtonRunAlwaysWithPlugins.Value,AppSettingsIni,"PluginLoader","RunOnStart")
}
SetStartingTab(*)
{
    try
    {
        local NewStartTab := ogcButtonStartTab.Value

        if(PluginsLoaded)
        {
            IniWrite(NewStartTab,AppSettingsIni,"Settings","StartingTabWithPlugins")
        }
        else
        {
            IniWrite(NewStartTab,AppSettingsIni,"Settings","StartingTab")
        }
    }
    catch
    {
        ;TODO: Better error
        msgbox("Can't write settings. Restarting the script may fix this issue.","Something went wrong!")
    }
}
RunWithPlugins(ForceStartWithPlugins := false,*)
{
    if(PluginsLoaded and !ForceStartWithPlugins)
    {
        if(ogcButtonRunAlwaysWithPlugins.Value == 1)
        {
            MsgBox('Disable "Run always with plugins" To run without plugins')
            return
        }
        Run(MainScriptAhkFile)
        ExitApp
    }
    else
    {
        if(FileExist(LauncherAhkFile))
        {
            Run(LauncherAhkFile)
            ExitApp
        }
        else
        {
            ;TODO: Better msgbox
            MsgBox("Launcher File Is Missing!")
        }
    }
}
;Debug
OpenScriptFolder(A_GuiEvent, GuiCtrlObj, Info, *)
{
    if(FileExist(AppFolder))
        Run(AppFolder)
    else
        FileOrFolderMissing(true)
}
OpenThisInGithub(A_GuiEvent, GuiCtrlObj, Info, *)
{
    Run(GithubPage)
}
OpenAppSettingsFolder(A_GuiEvent, GuiCtrlObj, Info, *)
{
    if(FileExist(AppSettingsFolder))
        Run(AppSettingsFolder)
    else
        FileOrFolderMissing(true)
}
OpenAppSettingsFile(A_GuiEvent, GuiCtrlObj, Info, *)
{
    if(FileExist(AppSettingsIni))
        Run(AppSettingsIni)
    else
        FileOrFolderMissing(false)
}
;Delete
DeleteAppSettings(A_GuiEvent, GuiCtrlObj, Info, *)
{
    if(FileExist(AppSettingsFolder))
    {
        msgResult := MsgBox("All Settings will be deleted!`n(Script Will Reload)", "Are you sure?", "1 T15")
        if (msgResult = "Cancel")
        {
            return
        }
        else
        {
            DirDelete(AppSettingsFolder, 1)
            ;Reset all settings when settings files are removed
            Run(A_ScriptFullPath)
            ExitApp
        }
    }
    else
    {
        MsgBox("No settings saved!","Nothing to delete!","T25")
    }
}
;Uninstall
UninstallScript(*)
{
    ;Get current folder name
    local l_str_FolderName := InStr(A_ScriptDir, "\", false, -1)
    l_str_FolderName := SubStr(A_ScriptDir, l_str_FolderName + 1)
    ;Get file count
    local l_int_MaxFileCount := 6
    local l_int_FileCountInFolder := 0
    loop files, "*.*", "D"
    {
        l_int_FileCountInFolder := l_int_FileCountInFolder + 1
    }

    local l_srt_Msg := "You are about to uninstall. All plugins and settings will be deleted.`nContinue?"
    ;If folder name is incorrect or file count is not normal
    if(l_str_FolderName != AppFolderName or l_int_FileCountInFolder > l_int_MaxFileCount)
    {
        if(l_str_FolderName != AppFolderName) ;If name is not correct
        {
            l_srt_errMsg := 'Script folder name is not correct. Folder name: "' l_str_FolderName '"`nThis folder will be deleted`nContinue?'
        }
        else if(l_int_FileCountInFolder > l_int_MaxFileCount) ;If more files
        {
            l_srt_errMsg := "More files then usually. File count: " l_int_FileCountInFolder ". Make sure that there is not any inportant files!`nContinue?"
        }
        else
        {
            MsgBox("Files cannot be deleted. You can manually delete files.","Uninstall failed!")
            return
        }
        local l_errmsgbox := MsgBox(l_srt_errMsg,"Error!","Y/N/C")
        if(l_errmsgbox != "Yes")
        {
            return
        }
    }
    local l_msgbox := MsgBox(l_srt_Msg,"Are you sure!","Y/N/C")
    if(l_msgbox != "Yes")
    {
        return
    }
    else
    {
        DirDelete(A_ScriptDir,1)
        ExitApp
    }
}
;Updates
AutoUpdates(A_GuiEvent, GuiCtrlObj, Info, *)
{
    CreateDefaultDirectories()
    oSaved := myGui.Submit("0")
    RunAsThisAdminCheckbox := oSaved.RunAsThisAdminCheckbox
    OnExitCloseToTrayCheckbox := oSaved.OnExitCloseToTrayCheckbox
    CheckUpdatesOnStartup := oSaved.CheckUpdatesOnStartup
    IniWrite(CheckUpdatesOnStartup, AppSettingsIni, "Updates", "CheckOnStartup")
}
ButtonCheckForUpdates(A_GuiEvent, GuiCtrlObj, Info, *)
{
    CheckForUpdates(false)
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Functions]///////////////
UpdateTrayicon()
{
        Tray:= A_TrayMenu
        Tray.Delete()
        Tray.Add("Show GUI", OpenMainGui)
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
        Tray.Add("E&xit", EXIT)
        Tray.Default := "Show GUI"
        ;Tray.Tip(ScriptName)
}
/**
 * @param SkipRunningLatestMessage Skip Running Latest Message
**/
CheckForUpdates(SkipRunningLatestMessage)
{
    if(!FileExist(AppUpdaterFile))
    {
        ;Updater File Missing!!
        ;[TODO:]
        MsgBox("Updater File Is Missing!")
    }
    else
    {
        IniWrite(SkipRunningLatestMessage, AppUpdaterSettingsFile, "Options", "SkipRunningLatestMessage")
        if(PluginsLoaded)
            IniWrite(true, AppUpdaterSettingsFile, "Options", "PluginsLoaded")
        Run(AppUpdaterFile)
    }
}
GetRandomCoffeeFact()
{
    if FileExist(RandomCoffeeQuotesFile)
    {
        Facts := Fileread(RandomCoffeeQuotesFile)
        myArray := StrSplit(Facts, "`n")
        randomElement := myArray[Random(1, myArray.Length)]
        Return randomElement
    }
    Else
    {
        Return
    }
}
CreateDefaultDirectories()
{
    if(!FileExist(AppFolder)) ;Just in case
        DirCreate(AppFolder)
    if(!FileExist(AppSettingsFolder))
        DirCreate(AppSettingsFolder)
    if(!FileExist(AppPluginsFolder))
        DirCreate(AppPluginsFolder)
}
FileOrFolderMissing(IsFolder)
{
    if(IsFolder)
    {
        MsgBox("Folder does not exist.","Folder Missing","T20")
    }
    else
    {
        MsgBox("File does not exist.","File Missing","T20")
    }
}
/**
 * Create and open Plugin manager
**/
PluginManagerInt()
{
    global PluginManagerGui := Gui()
    PluginManagerGui.Add("Text", "x8 y8 w73 h23 +0x200", "Plugin name:")
    PluginManagerGui.Add("Text", "x8 y40 w395 h2 +0x10")
    ;Plugins here
    ;PluginManagerGui.Add("Text", "x8 y48 w207 h23 +0x200", "Plugin")
    ;ogcButtonSettings := PluginManagerGui.Add("Button", "x224 y48 w80 h23 +Disabled", "Settings")
    ;ogcButtonInstall := PluginManagerGui.Add("Button", "x312 y48 w80 h23", "Install")
    GetAllPlugins()
    PluginManagerGui.OnEvent('Close', (*) => ClosePluginManager())
    PluginManagerGui.Title := "Plugin Manager"
}
ClosePluginManager(*)
{
    PluginManagerGui.Destroy()

    global IsPluginSettingsOpen
    if(IsPluginSettingsOpen)
        ClosePluginSettings()
}
/**
 * Read file from github containg all plugin names
 * Then adds them to plugin manager
**/
GetAllPlugins()
{
    global PluginsInManagerCount := 1 ;Reset Count
    ;Read file containing all plugin names
    whr := ComObject("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", AllPluginsFile, False)
    whr.Send()
    whr.WaitForResponse()
    Response := whr.ResponseText

    ;add all plugins to gui
    loop parse, Response, "`n"
    {
        AddNewPlugin(A_LoopField)
    }
}
/**
 * Open Plugin settings
**/
OpenPluginSettings(PluginName,*)
{
    global IsPluginSettingsOpen
    if(IsPluginSettingsOpen)
        ClosePluginSettings()

    global PluginSettingsGui := Gui()
    PluginSettingsGui.SetFont("s12")
    PluginSettingsGui.Add("Text", "x8 y0 w228 h23 +0x200", PluginName)
    PluginSettingsGui.SetFont("s9")
    
    ;Check updates on startup
    PluginSettingsCheckBox1 := PluginSettingsGui.Add("CheckBox", "x8 y24 w142 h23 +Checked", "Check Updates on startup")
    PluginSettingsCheckBox1.OnEvent("Click",SetPlugiCheckUpdatesOnStart.Bind(PluginName))
    if(IniRead(AppSettingsIni,"Plugins",PluginName,0) == 0)
        PluginSettingsCheckBox1.Value := 0

    PluginSettingsogcButtonCheckForUpdates := PluginSettingsGui.Add("Button", "x8 y72 w103 h23", "Check For Updates")
    PluginSettingsogcButtonCheckForUpdates.OnEvent("Click",CheckForPluginUpdates.Bind(PluginName))
    PluginSettingsogcButtonOpenFilelocation := PluginSettingsGui.Add("Button", "x8 y48 w102 h23", "Open File location")
    PluginSettingsogcButtonOpenFilelocation.OnEvent("Click",OpenPluginLocation.Bind(PluginName))
    PluginSettingsogcButtonCancel := PluginSettingsGui.Add("Button", "x152 y72 w80 h23", "Close")
    PluginSettingsogcButtonCancel.OnEvent("Click",(*) => ClosePluginSettings())
    PluginSettingsGui.OnEvent('Close', (*) => ClosePluginSettings())
    PluginSettingsGui.Title := "Settings"
    PluginSettingsGui.Show("w238 h101")

    IsPluginSettingsOpen := true
}
SetPlugiCheckUpdatesOnStart(PluginName,obj,*)
{
    IniWrite(obj.Value,AppSettingsIni,"Plugins",PluginName)
}
ClosePluginSettings(*)
{
    PluginSettingsGui.Destroy()
    global IsPluginSettingsOpen := false
}
OpenPluginLocation(PluginName,*)
{
    Run(AppPluginsFolder)
}
CheckForPluginUpdates(func_PluginName,*)
{
    local l_file_FileName := func_PluginName ".ahk"

    local l_float_OldPluginVersion := ReadVersionFromAhkFile(func_PluginName "Version",AppPluginsFolder "\" l_file_FileName)
    local l_float_NewPluginVersion := GetNewVersionFromGithub(CurrentScriptBranch,"/Version/" func_PluginName ".txt")
    
    if(l_float_OldPluginVersion < l_float_NewPluginVersion)
    {
        local l_srt_Prompt := MsgBox("Old: " l_float_OldPluginVersion " New: " l_float_NewPluginVersion,"PluginUpdate","YesNo")
        if(l_srt_Prompt == "Yes")
        {
            url := PluginGithubLink "/" func_PluginName ".ahk"
            plugin := AppPluginsFolder "\" func_PluginName ".ahk"
            
            FileDelete(plugin)
            Download(url,plugin)
        }
    }
    else
    {
        MsgBox("Already running latest version. (" l_float_OldPluginVersion ")","Latest")
    }
}
/**
 * Create plugin line
 * * Used in GetAllPlugins()
**/
AddNewPlugin(PluginName)
{
    global PluginsInManagerCount
    StartingY := 20
    CorrectY := StartingY + 28 * PluginsInManagerCount
    FixedPluginName := StrSplit(PluginName,A_Space)

    PluginManagerGui.Add("Text", "x8 y" CorrectY " w207 h23 +0x200", PluginName)
    ogcButtonSettings := PluginManagerGui.Add("Button", "x224 y" CorrectY " w80 h23 +Disabled", "Settings")
    ogcButtonInstall := PluginManagerGui.Add("Button", "x312 y" CorrectY " w80 h23", "Install")
    ogcButtonInstall.OnEvent("Click", DownloadPlugin.Bind(PluginName,ogcButtonSettings))

    destination := AppPluginsFolder "/" FixedPluginName[1] ".ahk"
    if(FileExist(destination))
    {
        ogcButtonSettings.Enabled := true
        ogcButtonInstall.Text := "Remove"
    }

    ;Settings
    ogcButtonSettings.OnEvent("Click", OpenPluginSettings.Bind(FixedPluginName[1]))

    PluginsInManagerCount++
}
/**
 * @param PluginName Downloads this plugin if found
**/
DownloadPlugin(PluginName,SettingsObj,obj,*)
{
    CreateDefaultDirectories()

    FixedPluginName := StrSplit(PluginName,A_Space)
    local WholePluginName := PluginName
    PluginName := FixedPluginName[1]
    url := PluginGithubLink "/" PluginName ".ahk"
    destination := AppPluginsFolder "/" PluginName ".ahk"

    if(FileExist(destination))
    {
        SettingsObj.Enabled := false
        obj.Enabled := false
        obj.Text := "Deleting..."

        FileDelete(destination)

        obj.Enabled := true
        obj.Text := "Install"
    }
    else
    {
        ;warn dev and alpha states
        if(InStr(WholePluginName,"Dev") or InStr(WholePluginName,"Alpha"))
        {
            local alertResult := MsgBox("The chosen plugin is in an alpha/dev state, and it may be unreliable or potentially disrupt the script.`nYou can run the script without plugins and remove any that cause issues.`nContinue anyways?","Plugin Caution: Alpha/Dev State Advisory","YesNo")
            if(alertResult == "No")
                return
        }

        ;Download
        obj.Enabled := false
        obj.Text := "Downloading..."

        Download(url,destination)

        SettingsObj.Enabled := true
        obj.Enabled := true
        obj.Text := "Remove"

        ;Set update on start enabled
        IniWrite(1,AppSettingsIni,"Plugins",PluginName)
    }

    ;Fix starting tab
    if(FileExist(AppSettingsIni))
    {
        StartingTabValue := Integer(IniRead(AppSettingsIni,"Settings","StartingTabWithPlugins",1))
        if(StartingTabValue != 1 and StartingTabValue != 2)
        {
            IniWrite(2,AppSettingsIni,"Settings","StartingTabWithPlugins")
            MsgBox("Starting tab reset to settings.","Start Tab Reset")
        }
    }
    ;Ask to restart if plugins loaded
    if(PluginsLoaded)
    {
        askRestart := MsgBox("Do you want to restart the application in order to load the newly changed plugins?","Restart for changed Plugins?","YesNo")
        if(askRestart == "Yes")
        {
            RunWithPlugins(true)
            ExitApp
        }
    }
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[HomeScreenCategories]///////////////
HomeScreenCategory(CategoryName,CategoryPosition := 0)
{
    switch CategoryName {
        case "QuickActions":
            ;Quick Actions
            QuickActionsLocationY := TabHeight + CategoryPosition
            myGui.SetFont()
            myGui.Add("GroupBox", "x8 y" QuickActionsLocationY " w300 h110", "Quick actions")
            global ogcButtonIPConfig := myGui.Add("Button", "x16 y" 24 + QuickActionsLocationY " w80 h23", "IPConfig")
            ogcButtonIPConfig.OnEvent("Click", RunIpConfig.Bind("Normal"))
            global ogcButtonAppdata := myGui.Add("Button", "x16 y" 48 + QuickActionsLocationY " w80 h23", "Appdata")
            ogcButtonAppdata.OnEvent("Click", OpenAppdataFolder.Bind("Normal"))
            global ogcButtonStartupfolder := myGui.Add("Button", "x96 y" 24 + QuickActionsLocationY " w80 h23", "Startup folder")
            ogcButtonStartupfolder.OnEvent("Click", OpenStartupFolder.Bind("Normal"))
            global ogcButtonOpenSounds := myGui.Add("Button", "x96 y" 48 + QuickActionsLocationY " w80 h23", "Open Sounds")
            ogcButtonOpenSounds.OnEvent("Click", OpenSounds.Bind("Normal"))
            global ogcButtonClearWindowsTempFolder := myGui.Add("Button", "x16 y" 72 + QuickActionsLocationY " w164 h28", "Clear Windows Temp Folder")
            ogcButtonClearWindowsTempFolder.OnEvent("Click", ClearWindowsTempFolder.Bind("Normal"))
        default:
            MsgBox("Name Not Found!")
    }
}
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Custom Error handling]///////////////
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
;________________________________________________________________________________________________________________________
;________________________________________________________________________________________________________________________
;//////////////[Inherited from updater without using include]///////////////
/**
 * Github Reposity link setup
 *
 * Returns 'ERROR' if not found
 *
 * @param T_Branch Branch Name
 * @param linkEnd File name (Path to file). Add "/" To Start
 *
 * Link: GithubReposityLink + T_Branch + linkEnd
 *
 * Link Example: [https://raw.githubusercontent.com/ USERNAME / REPOSITYNAME /] + [main] + [/version.txt]
 * v1
**/
GetNewVersionFromGithub(T_Branch,linkEnd)
{
    ;Build link
    VersionLink := GithubReposityLink . T_Branch . linkEnd
    ;Get Version Text
    T_NewVersion := ReadFileFromLink(VersionLink)
    if(T_NewVersion == "ERROR")
    {
        ;msgbox,,No Internet Connection!,No Internet Connection!
        return "ERROR"
    }
    ;Check that not empty or not found
    if(T_NewVersion != "" and T_NewVersion != "404: Not Found" and T_NewVersion != "500: Internal Server Error" and T_NewVersion != "400: Invalid request")
    {
        Return T_NewVersion
    }
    else
    {
        return "ERROR"
    }
}
/**
 * Returns version found (Empty if not found)
 *
 * @param VersionVariableName Is case sensitive
 * @param AhkFile Path to Ahk File
 * v1
**/
ReadVersionFromAhkFile(VersionVariableName,AhkFile)
{
    ;Variables
    VersionFile := FileRead(AhkFile)
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
 * v1
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
/**
 * @param Link Link to text file
 * v1
**/
ReadFileFromLink(Link)
{
    try
    {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", Link, False)
        whr.Send()
        whr.WaitForResponse()
        TResponse := whr.ResponseText
    }
    Catch Error as T_Error
    {
        return "ERROR"
    }
    return TResponse
}