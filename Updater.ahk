#SingleInstance, Force
SetBatchLines, -1
ListLines, Off
SetWorkingDir, %A_ScriptDir%
SplitPath, A_ScriptName, , , , GameScripts
#Persistent
;____________________________________________________________
;//////////////[Updater]///////////////
UpdaterVersion = 0.34
global UpdaterVersion
;Braches [main] [Experimental] [PreRelease]
ProgressBarVisible := False
global ProgressBarVisible
;____________________________________________________________
;//////////////[Folders]///////////////
ScriptName = CoffeeTools
AppFolderName = CoffeePoweredAutomationTools
AppFolder = %A_AppData%\%AppFolderName%
AppSettingsFolder = %AppFolder%\Settings
MainScriptFile = %AppFolder%\%ScriptName%
MainScriptAhkFile = %AppFolder%\%ScriptName%.ahk
AppUpdaterSettingsFile = %AppFolder%\UpdaterInfo.ini
;//////////////[ini]///////////////
AppSettingsIni = %AppSettingsFolder%\Settings.ini
;//////////////[Update]///////////////
AppUpdateFile = %AppFolder%\temp\Updater.ahk
ShowRunningLatestMessage := True
;//////////////[Links]///////////////
GithubReposityLink := "https://raw.githubusercontent.com/veskeli/CoffeePoweredAutomationTools/"
;//////////////[Script Dir]///////////////
ScriptFullPath =
T_SkipShortcut = false
FixUserLocation = false
ShortcutState = 1
AppInstallLocation =
;Global
global ShowRunningLatestMessage
global GithubReposityLink
;____________________________________________________________
;____________________________________________________________
;//////////////[Progress Bar]///////////////
Gui 2:Font, s9, Segoe UI
Gui 2:Add, Text, x8 y2 w217 h43 vProgressBarText, Updating
Gui 2:Add, Progress, vDownloadProgressBar x8 y48 w215 h20 -Smooth, 33
Gui 2:Add, Button, +Disabled x144 y72 w80 h23, Cancel
;____________________________________________________________
;____________________________________________________________
;//////////////[Update Script]///////////////
IfExist, %AppUpdaterSettingsFile%
{
    iniread,version,%AppUpdaterSettingsFile%,Options,Version
    iniread,MainScriptFile,%AppUpdaterSettingsFile%,Options,ScriptFullPath
    iniread,MainScriptBranch,%AppUpdaterSettingsFile%,Options,Branch
    iniread,ShowRunningLatestMessage,%AppUpdaterSettingsFile%,Options,ShowRunningLatestMessage
    global version
    global MainScriptFile
    global MainScriptBranch
    FileDelete,%AppUpdaterSettingsFile%

    TryUpdateScript(true,MainScriptBranch)
}
Else
{
    MsgBox,, Updater,No pending updates...,25
    /*
    MsgBox, 4, Updater, No pending updates. Would you like to reinstall script?
    IfMsgBox Yes
    {
        UpdateScript(true,MainScriptBranch)
    }
    */
}
CheckForUpdaterUpdates() ;[TODO] Not working
ExitApp
;____________________________________________________________
;____________________________________________________________
;//////////////[Update Main File]///////////////
TryUpdateScript(T_CheckForUpdates,T_Branch)
{
    if(T_Branch == "main" or T_Branch == "Experimental" or T_Branch == "PreRelease")  ;Check that branch is correctly typed
    {
        newversion := GetNewVersion(T_Branch,"/Version/CoffeePoweredAutomationToolsVersion.txt")
        if(newversion == "ERROR" or newversion == "")
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
                    StartUpdate(newversion,T_Branch)
                }
                Else
                {
                    return
                }
            }
            Else
            {
                if(ShowRunningLatestMessage)
                {
                    MsgBox,, Already latest version!, Already latest version!, 25
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
;Activate Download
StartUpdate(newversion,branch)
{
    ;Check That if script is running
    SetTitleMatchMode, 2
    DetectHiddenWindows, On
    If WinExist("CoffeeTools.ahk" . " ahk_class AutoHotkey")
    {
        ;Stop Script
        WinClose
    }
    ;Update Script
    UpdateScript(newversion,branch)
}
UpdateScript(newversion,branch) ;[TODO] Get correct file based on version (Currently gets latest from github)
{
    ;Save branch
    IniWrite, %branch%,%AppSettingsIni%,Branch,Instance1
    ;Set Progressbar
    SetProgressBarText("Downloading new version: %newversion%")
    SetProgressBarState(5)
    ;Delete old file
    FileDelete, %MainScriptFile%
    SetProgressBarState(50)

    DownloadLink := % GithubReposityLink . branch . "/GameScripts.ahk"
    SetProgressBarState(95)
    ;Download new file
    UrlDownloadToFile, %DownloadLink%, %MainScriptFile%
    ;SplashTextOff
    SetProgressBarState(100)
    loop
    {
        if (FileExist(MainScriptAhkFile))
        {
            ;Open New Script
            Run, %MainScriptAhkFile%
            SetProgressBarState(-1) ;Just in case of idk
            ExitApp
        }
    }
    SetProgressBarState(-1) ;Just in case of idk
    ExitApp
}
;____________________________________________________________
;//////////////[Updater updates]///////////////
CheckForUpdaterUpdates()
{
    newversion := GetNewVersion(MainScriptBranch,"/Version/UpdaterVersion.txt")
    if(newversion == "ERROR")
    {
        ExitApp
    }
    if(newversion > UpdaterVersion)
    {
        UpdateUpdater(newversion)
    }
}
UpdateUpdater(newversion) ;[TODO] Update from correct branch and version
{
    FileCreateDir, %AppFolder%\temp
    FileMove, %A_ScriptFullPath%, %AppUpdateFile%, 1
    UrlDownloadToFile, % GithubReposityLink . branch . "/Updater.ahk", %A_ScriptFullPath%
    ExitApp
}
;____________________________________________________________
;//////////////[ProgressBar]///////////////
SetProgressBarState(State) ;Disable by setting "-1"
{
    if(State == -1)
    {
        OpenProgressWindow(False)
        ProgressBarVisible := False
    }
    Else
    {
        if(!ProgressBarVisible)
        {
            OpenProgressWindow(True)
            GuiControl,2:,DownloadProgressBar,%State%
            ProgressBarVisible := True
        }
        Else
        {
            GuiControl,2:,DownloadProgressBar,%State%
        }
    }
}
OpenProgressWindow(State)
{
    if(State)
    {
        Gui 2:Show, w227 h103, Updater
    }
    Else
    {
        Gui 2:Destroy
    }
}
SetProgressBarText(text)
{
    GuiControl,2:,ProgressBarText,%text%
}
;____________________________________________________________
;//////////////[Functions]///////////////
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
GetNewVersion(T_Branch,linkEnd)
{
    ;Build link
    VersionLink := % GithubReposityLink . T_Branch . linkEnd
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
;____________________________________________________________
;____________________________________________________________
GuiEscape:
GuiClose:
CancelInstall:
    ExitApp