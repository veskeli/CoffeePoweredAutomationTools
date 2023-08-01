#SingleInstance, Force
SetBatchLines, -1
ListLines, Off
SetWorkingDir, %A_ScriptDir%
SplitPath, A_ScriptName, , , , GameScripts
#Persistent
;____________________________________________________________
;//////////////[Updater]///////////////
UpdaterVersion = 0.3
global UpdaterVersion
VersionUrlGithub := % "https://raw.githubusercontent.com/veskeli/GameScriptsByVeskeli/"
AppGithubDownloadURL := % "https://raw.githubusercontent.com/veskeli/GameScriptsByVeskeli/main/GameScripts.ahk"
;Braches [main] [Experimental] [PreRelease]
;____________________________________________________________
;//////////////[Folders]///////////////
ScriptName = GameScripts
AppFolderName = AHKGameScriptsByVeskeli
AppFolder = %A_AppData%\%AppFolderName%
AppSettingsFolder = %AppFolder%\Settings
AppUpdaterFile = %AppFolder%\Updater.ahk
GuiPictureFolder = %AppFolder%\Gui
MainScriptFile = %AppFolder%\%ScriptName%
MainScriptAhkFile = %AppFolder%\%ScriptName%.ahk
AppUpdaterSettingsFile = %AppFolder%\UpdaterInfo.ini
AppVersionSettingsFile = %AppFolder%\VersionInfo.ini
AppScriptTempFile = %A_ScriptDir%\GameSciptTemp.ini
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
;//////////////[Update Script]///////////////
iniread,version,%AppUpdaterSettingsFile%,Options,Version
iniread,MainScriptFile,%AppUpdaterSettingsFile%,Options,ScriptFullPath
iniread,MainScriptBranch,%AppUpdaterSettingsFile%,Options,Branch
global version
global MainScriptFile
global MainScriptBranch
FileDelete,%AppUpdaterSettingsFile%

UpdateScript(true,MainScriptBranch)
CheckForUpdaterUpdates()
ExitApp
;____________________________________________________________
;____________________________________________________________
;//////////////[Voids]///////////////
UpdateScript(T_CheckForUpdates,T_Branch)
{
    if(T_Branch == "main" or T_Branch == "Experimental" or T_Branch == "PreRelease")  ;Check that branch is correctly typed
    {
        newversion := GetNewVersion(T_Branch)
        if(newversion == "ERROR")
        {
            MsgBox,,Update ERROR!,New Version Error!`nError while getting new version,15
            return
        }
        if(T_CheckForUpdates) ;If normal Check and update
        {
            if(newversion > version)
            {
                if(T_Branch == "main")
                {
                    UpdateText := % "New version is: " . newversion . "`nOld is: " . version .  "`nUpdate now?"
                }
                else if(T_Branch == "PreRelease")
                {
                    UpdateText := % "New Pre-Release is: " . newversion . "`nOld is: " . version .  "`nUpdate now?"
                }
                else if(T_Branch == "Experimental")
                {
                    UpdateText := % "New Experimental version is: " . newversion . "`nOld is: " . version .  "`nUpdate now?"
                }
                MsgBox, 4,Update,%UpdateText%
                IfMsgBox, Yes
                {
                    TForceUpdate(newversion,T_Branch)
                }
                Else
                {
                    return "ERROR"
                }
            }
        }
        else    ;Force update/Download
        {
            msgbox, Force Download Called!?!
            ;TForceUpdate(newversion,T_Branch)
        }
    }
    else
    {
        ExitApp
    }
}
GetNewVersion(T_Branch)
{
    ;Build link
    VersionLink := % VersionUrlGithub . T_Branch . "/version.txt"
    ;Get Version Text
    T_NewVersion := ReadFileFromLink(VersionLink)
    if(T_NewVersion == "ERROR")
    {
        ;msgbox,,No Internet Connection!,No Internet Connection!
        return
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
ReadFileFromLink(Link)
{
    try
    {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", Link, False)
        whr.Send()
        whr.WaitForResponse()
        TResponse := whr.ResponseText
    }
    Catch T_Error
    {
        return "ERROR"
    }
    return TResponse
}
;Activate Download
TForceUpdate(newversion,T_Branch)
{
    ;Check That if script is running
    SetTitleMatchMode, 2
    DetectHiddenWindows, On
    If WinExist("GameScripts.ahk" . " ahk_class AutoHotkey")
    {
        ;Stop Script
        WinClose
    }
    ;Update Script
    ForceUpdate(newversion,T_Branch)
}
ForceUpdate(newversion,T_Branch)
{
    ;Save branch
    IniWrite, %T_Branch%,%AppSettingsIni%,Branch,Instance1
    ;Download update
    SplashTextOn, 250,50,Downloading...,Downloading new version.`nVersion: %newversion%
    FileDelete, %MainScriptFile%
    DownloadLink := % VersionUrlGithub . T_Branch . "/GameScripts.ahk"
    UrlDownloadToFile, %DownloadLink%, %MainScriptFile%
    SplashTextOff
    loop
    {
        if (FileExist(MainScriptAhkFile))
        {
            Run, %MainScriptAhkFile%
            ExitApp
        }
    }
    ExitApp
}
CheckForUpdaterUpdates()
{
    newversion := GetNewUpdaterVersion(MainScriptBranch)
    if(newversion == "ERROR")
    {
        ExitApp
    }
    if(newversion > UpdaterVersion)
    {
        ForceUpdateUpdater(newversion)
    }
}
GetNewUpdaterVersion(T_Branch)
{
    ;Build link
    VersionLink := % VersionUrlGithub . T_Branch . "/UpdaterVersion.txt"
    ;Get Version Text
    T_NewVersion := ReadFileFromLink(VersionLink)
    if(T_NewVersion == "ERROR")
    {
        ExitApp
    }
    ;Check that not empty or not found
    if(T_NewVersion != "" and T_NewVersion != "404: Not Found" and T_NewVersion != "500: Internal Server Error")
    {
        Return T_NewVersion
    }
    else
    {
        ExitApp
    }
}
ForceUpdateUpdater(newversion)
{
    FileCreateDir, %AppFolder%\temp
    FileMove, %A_ScriptFullPath%, %AppUpdateFile%
    DownloadLink := % VersionUrlGithub . MainScriptBranch . "/Updater.ahk"
    UrlDownloadToFile, %DownloadLink%, %A_ScriptFullPath%
    ExitApp
}
;____________________________________________________________
;____________________________________________________________
GuiEscape:
GuiClose:
CancelInstall:
    ExitApp