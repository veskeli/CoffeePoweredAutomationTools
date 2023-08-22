#Requires AutoHotkey v2.0+
#SingleInstance Force
ListLines(false)
SetWorkingDir(A_ScriptDir)
SplitPath(A_ScriptName, , , , &GameScripts)
Persistent
;____________________________________________________________
;//////////////[Updater]///////////////
UpdaterVersion := "0.5"
global UpdaterVersion
;Braches [main] [Experimental] [PreRelease]
ProgressBarVisible := False
global ProgressBarVisible
;____________________________________________________________
;//////////////[Folders]///////////////
global ScriptName := "CoffeeTools"
global AppFolderName := "CoffeePoweredAutomationTools"
global AppFolder := A_AppData . "\" . AppFolderName
global AppSettingsFolder := AppFolder . "\Settings"
global MainScriptFile := AppFolder . "\" . ScriptName
global MainScriptAhkFile := AppFolder . "\" . ScriptName . ".ahk"
global LauncherAhkFile := AppFolder . "\Launcher.ahk"
;//////////////[ini]///////////////
AppUpdaterSettingsFile := AppFolder . "\UpdaterInfo.ini"
AppSettingsIni := AppSettingsFolder . "\Settings.ini"
;//////////////[Assets]///////////////
RandomCoffeeQuotesFile := AppSettingsFolder . "\RandomCoffeeQuotes.txt"
;//////////////[Update]///////////////
AppUpdateFile := AppFolder . "\temp\Updater.ahk"
AppTempFolder := AppFolder . "\temp"
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
;//////////////[Variable]///////////////
global ProgressBarStepSize := 50
global ShowRunningLatestMessage
global GithubReposityLink
global MainScriptBranch
global UserCanceledUpdate := false


;//////////////[Main update files]///////////////
;Main Script
global ScriptUpdate := false
;Launcher
global LauncherUpdate := false
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
;//////////////[Check for redownload assets]///////////////
if FileExist(AppUpdaterSettingsFile) ;Read Settings
{
    ;Redownload Assets
    BRedownloadAssets := IniRead(AppUpdaterSettingsFile, "Options", "RedownloadAssets", False)

    FileDelete(AppUpdaterSettingsFile) ;Delete settings file

    if(BRedownloadAssets)
    {
        RedownloadAssets()
    }
}



;//////////////[Check for updates]///////////////
MainScriptBranch := "main" ;[TODO] Brach control
;MainScript
global MainScriptVersion := ReadVersionFromAhkFile("Version",MainScriptAhkFile)
global NewMainScriptVersion := GetNewVersionFromGithub(MainScriptBranch,"/Version/CoffeePoweredAutomationToolsVersion.txt")
if(MainScriptVersion != "")
{
    if(NewMainScriptVersion != "ERROR")
    {
        if(NewMainScriptVersion > MainScriptVersion)
        {
            ScriptUpdate := true
        }
    }
}
;Launcher
global LauncherVersion := ReadVersionFromAhkFile("LauncherVersion",LauncherAhkFile)
global NewLauncherVersion := GetNewVersionFromGithub(MainScriptBranch,"/Version/LauncherVersion.txt")
if(LauncherVersion != "")
{
    if(NewLauncherVersion != "ERROR")
    {
        if(NewLauncherVersion > LauncherVersion)
        {
            LauncherUpdate := true
        }
    }
}



;//////////////[Ask for main script updates]///////////////
if(ScriptUpdate)
    ScriptUpdate := AskToDownloadUpdates("Coffee Tools",MainScriptVersion,NewMainScriptVersion)
if(LauncherUpdate)
    LauncherUpdate := AskToDownloadUpdates("Launcher",LauncherVersion,NewLauncherVersion)



;Update Files
UpdateMainFiles(MainScriptBranch)



;//////////////[Updater Updates]///////////////
CheckForUpdaterUpdates()



ExitApp()
;____________________________________________________________
;____________________________________________________________
;//////////////[Update Main File]///////////////
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
AskToDownloadUpdates(T_ScriptName,T_CurrentVersion,T_NewVersion,T_Branch := "main")
{
    ;[TODO] Check for settings (Auto install)
    UpdateText := "Update for " T_ScriptName "!`n`n"
    if(T_Branch == "main")
    {
        UpdateText := UpdateText "New version is: " . T_CurrentVersion . "`nOld is: " . T_NewVersion .  "`nUpdate now?"
    }
    else if(T_Branch == "PreRelease")
    {
        UpdateText := UpdateText "New Pre-Release is: " . T_CurrentVersion . "`nOld is: " . T_NewVersion .  "`nUpdate now?"
    }
    else if(T_Branch == "Experimental")
    {
        UpdateText := UpdateText "New Experimental version is: " . T_CurrentVersion . "`nOld is: " . T_NewVersion .  "`nUpdate now?"
    }
    msgResult := MsgBox(UpdateText, "Update for " T_ScriptName "!", 4)
    if (msgResult = "Yes")
    {
        global UserCanceledUpdate := false
        return true
    }
    Else
    {
        global UserCanceledUpdate := true
        return false
    }
    return false
}
;____________________________________________________________
;____________________________________________________________
;//////////////[Update Main Files]///////////////
/**
 * New workflow
 *
 * Uses these variables to update files:
 * * ScriptUpdate
 * * LauncherUpdate
**/
UpdateMainFiles(branch)
{
    StartProgressBar()
    ;Download files
    if(ScriptUpdate)
        UpdateFileFromGithub(GithubReposityLink branch "/CoffeeTools.ahk",MainScriptAhkFile) ;Main script update
    if(LauncherUpdate)
        UpdateFileFromGithub(GithubReposityLink branch "/Launcher.ahk",LauncherAhkFile) ;Launcher update
    SetProgressBarState(-1)
}
/**
 * @param Link Link to file
 * @param FilePath Path to file location
**/
UpdateFileFromGithub(Link,FilePath)
{
    ;Move existing file to temp
    if(FileExist(FilePath))
    {
        SplitPath FilePath, &name
        FileMove(FilePath,AppTempFolder "/" name,true)
    }
    ;Download new file
    ;[TODO] Try and Catch
    Download(Link,FilePath)
    ProgressProgressBar()
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
    if(FileExist(LauncherAhkFile))
        FileDelete(LauncherAhkFile)
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
    if(!FileExist(LauncherAhkFile))
        Download(GithubReposityLink . MainScriptBranch . "/Launcher.ahk" ,LauncherAhkFile)
    SetProgressBarState(100)
}
;____________________________________________________________
;//////////////[Updater updates]///////////////
CheckForUpdaterUpdates()
{
    newversion := GetNewVersionFromGithub(MainScriptBranch,"/Version/UpdaterVersion.txt")
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
/**
 * @param CustomSteps How many custom steps
**/
StartProgressBar(CustomSteps := 0)
{
    ProgressBarStepSize := 0
    AllVars := CustomSteps
    if(ScriptUpdate)
        AllVars++
    if(LauncherUpdate)
        AllVars++
    if(AllVars != 0)
    {
        ProgressBarStepSize := 100 / AllVars
        SetProgressBarState(0)
    }
    else
    {
        if(UserCanceledUpdate)
            return
        ;[TODO] Better msg
        DetailedMessage := ""
        DetailedMessage := DetailedMessage "`nMain Script version: " MainScriptVersion " Newest: " NewMainScriptVersion
        DetailedMessage := DetailedMessage "`nLauncher version: " LauncherVersion " Newest: " NewLauncherVersion
        MsgBox("No updates found!`n`nDetailed:" DetailedMessage,"No updates found!")
    }
}
/**
 * Next step in progressbar
**/
ProgressProgressBar()
{
    SetProgressBarState(ogcDownloadProgressBar.Value + ProgressBarStepSize)
}
/**
 * Only use in SetProgressBarState()
**/
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
/**
 * @param Link Link to text file
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
;____________________________________________________________
;____________________________________________________________
GuiEscape(*)
{
    ExitApp()
}