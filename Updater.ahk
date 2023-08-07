#Requires AutoHotkey v2.0+
#SingleInstance Force
ListLines(false)
SetWorkingDir(A_ScriptDir)
SplitPath(A_ScriptName, , , , &GameScripts)
Persistent
;____________________________________________________________
;//////////////[Updater]///////////////
UpdaterVersion := "0.44"
global UpdaterVersion
;Braches [main] [Experimental] [PreRelease]
ProgressBarVisible := False
global ProgressBarVisible
;____________________________________________________________
;//////////////[Folders]///////////////
ScriptName := "CoffeeTools"
AppFolderName := "CoffeePoweredAutomationTools"
AppFolder := A_AppData . "\" . AppFolderName
AppSettingsFolder := AppFolder . "\Settings"
MainScriptFile := AppFolder . "\" . ScriptName
MainScriptAhkFile := AppFolder . "\" . ScriptName . ".ahk"
AppUpdaterSettingsFile := AppFolder . "\UpdaterInfo.ini"
;//////////////[ini]///////////////
AppSettingsIni := AppSettingsFolder . "\Settings.ini"
;//////////////[Assets]///////////////
RandomCoffeeQuotesFile := AppSettingsFolder . "\RandomCoffeeQuotes.txt"
;//////////////[Update]///////////////
AppUpdateFile := AppFolder . "\temp\Updater.ahk"
ShowRunningLatestMessage := True
;//////////////[Links]///////////////
GithubReposityLink := "https://raw.githubusercontent.com/veskeli/CoffeePoweredAutomationTools/"
;//////////////[Script Dir]///////////////
ScriptFullPath := ""
T_SkipShortcut := "false"
FixUserLocation := "false"
ShortcutState := "1"
AppInstallLocation := ""
MainScriptBranch := "main"
;Global
global MainScriptAhkFile
global ShowRunningLatestMessage
global GithubReposityLink
global MainScriptBranch
;____________________________________________________________
;____________________________________________________________
;//////////////[Progress Bar]///////////////
oGui2 := Gui()
oGui2.SetFont("s9", "Segoe UI")
ogcProgressBarText := oGui2.Add("Text", "x8 y2 w217 h43 vProgressBarText", "Updating")
ogcDownloadProgressBar := oGui2.Add("Progress", "vDownloadProgressBar x8 y48 w215 h20 -Smooth", "33")
ogcButtonCancel := oGui2.Add("Button", "+Disabled x144 y72 w80 h23", "Cancel")
ogcButtonCancel.OnEvent("Click", GuiEscape.Bind("Normal"))
oGui2.OnEvent("Close", GuiEscape)
oGui2.OnEvent("Escape", GuiEscape)
;____________________________________________________________
;____________________________________________________________
;//////////////[Update Script]///////////////
if FileExist(AppUpdaterSettingsFile)
{
    BRedownloadAssets := IniRead(AppUpdaterSettingsFile, "Options", "RedownloadAssets", False)
    version := IniRead(AppUpdaterSettingsFile, "Options", "Version", False)
    MainScriptFile := IniRead(AppUpdaterSettingsFile, "Options", "ScriptFullPath", False)
    MainScriptBranch := IniRead(AppUpdaterSettingsFile, "Options", "Branch", False)
    ShowRunningLatestMessage := IniRead(AppUpdaterSettingsFile, "Options", "ShowRunningLatestMessage", False)
    global BRedownloadAssets
    global version
    global MainScriptFile
    global MainScriptBranch
    FileDelete(AppUpdaterSettingsFile)

    if(BRedownloadAssets)
    {
        RedownloadAssets()
    }
    else
    {
        TryUpdateScript(true,MainScriptBranch)
    }
}
Else
{
    MsgBox("No pending updates...", "Updater", "T25")
    /*
    MsgBox, 4, Updater, No pending updates. Would you like to reinstall script?
    IfMsgBox Yes
    {
        UpdateScript(true,MainScriptBranch)
    }
    */
}
CheckForUpdaterUpdates() ;[TODO] Not working
ExitApp()
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
            MsgBox("New Version Error!`nError while getting new version", "Update ERROR!", "T15")
            return
        }
        if(T_CheckForUpdates) ;If normal Check and update
        {
            if(newversion > version)
            {
                if(T_Branch == "main")
                {
                    UpdateText := "New version is: " . newversion . "`nOld is: " . version .  "`nUpdate now?"
                }
                else if(T_Branch == "PreRelease")
                {
                    UpdateText := "New Pre-Release is: " . newversion . "`nOld is: " . version .  "`nUpdate now?"
                }
                else if(T_Branch == "Experimental")
                {
                    UpdateText := "New Experimental version is: " . newversion . "`nOld is: " . version .  "`nUpdate now?"
                }
                msgResult := MsgBox(UpdateText, "Update", 4)
                if (msgResult = "Yes")
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
                    MsgBox("Already latest version!", "Already latest version!", "T25")
                }
            }
        }
        else    ;Force update/Download
        {
            MsgBox("Force Download Called!?!")
            ;TForceUpdate(newversion,T_Branch)
        }
    }
    else
    {
        ExitApp()
    }
}
;Activate Download
StartUpdate(newversion,branch)
{
    CloseMainScript()
    ;Update Script
    UpdateScript(newversion,branch)
}
CloseMainScript()
{
    ;Check That if script is running
    SetTitleMatchMode(2)
    DetectHiddenWindows(true)
    If WinExist("CoffeeTools.ahk" . " ahk_class AutoHotkey")
    {
        ;Stop Script
        WinClose()
    }
}
UpdateScript(newversion,branch) ;[TODO] Get correct file based on version (Currently gets latest from github)
{
    ;Save branch
    IniWrite(branch, AppSettingsIni, "Branch", "Instance1")
    ;Set Progressbar
    DownloadText := "Downloading new version: " . newversion
    SetProgressBarText(DownloadText)
    SetProgressBarState(5)
    ;Delete old file
    FileDelete(MainScriptFile)
    SetProgressBarState(50)

    DownloadLink := GithubReposityLink . branch . "/CoffeeTools.ahk"
    SetProgressBarState(75)
    ;Download new file
    Download(DownloadLink,MainScriptFile)
    SetProgressBarState(90)
    ;Download Assets
    DownloadAssets()
    SetProgressBarState(100)
    Loop
    {
        if (FileExist(MainScriptAhkFile))
        {
            ;Open New Script
            Run(MainScriptAhkFile)
            SetProgressBarState(-1) ;Just in case of idk
            ExitApp()
        }
    }
    SetProgressBarState(-1) ;Just in case of idk
    ExitApp()
}
;____________________________________________________________
;//////////////[Assets]///////////////
RedownloadAssets()
{
    CloseMainScript()
    SetProgressBarText("Deleting old assets")
    SetProgressBarState(5)
    ;Delete old assets
    if(FileExist(RandomCoffeeQuotesFile))
        FileDelete(RandomCoffeeQuotesFile)
    ;Download Assets
    SetProgressBarText("Downloading assets")
    SetProgressBarState(50)
    DownloadAssets()
    Run(MainScriptAhkFile)
    SetProgressBarState(-1)
    ExitApp()
}
DownloadAssets()
{
    if(!FileExist(RandomCoffeeQuotesFile))
        Download(GithubReposityLink . MainScriptBranch . "/Other/texts/RandomCoffeeQuotes.txt",RandomCoffeeQuotesFile)
    SetProgressBarState(100)
}
;____________________________________________________________
;//////////////[Updater updates]///////////////
CheckForUpdaterUpdates()
{
    newversion := GetNewVersion(MainScriptBranch,"/Version/UpdaterVersion.txt")
    if(newversion == "ERROR")
    {
        ExitApp()
    }
    if(newversion > UpdaterVersion)
    {
        UpdateUpdater(newversion)
    }
}
UpdateUpdater(newversion) ;[TODO] Update from correct branch and version
{
    DirCreate(AppFolder "\temp")
    FileMove(A_ScriptFullPath, AppUpdateFile, 1)
    Download(GithubReposityLink . MainScriptBranch . "/Updater.ahk",A_ScriptFullPath)
    ExitApp()
}
;____________________________________________________________
;//////////////[ProgressBar]///////////////
SetProgressBarState(State) ;Disable by setting "-1"
{
    global ProgressBarVisible
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
            ogcDownloadProgressBar.Value := State
            ProgressBarVisible := True
        }
        Else
        {
            ogcDownloadProgressBar.Value := State
        }
    }
}
OpenProgressWindow(State)
{
    if(State)
    {
        oGui2.Title := "Updater"
        oGui2.Show("w227 h103")
    }
    Else
    {
        oGui2.Destroy()
    }
}
SetProgressBarText(text)
{
    ogcProgressBarText.Value := text
}
;____________________________________________________________
;//////////////[Functions]///////////////
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
GetNewVersion(T_Branch,linkEnd)
{
    ;Build link
    VersionLink := GithubReposityLink . T_Branch . linkEnd
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
GuiEscape(*)
{
    ExitApp()
}