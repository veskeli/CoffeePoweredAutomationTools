# Coffee Tools
+ Last updated on version 0.243

Script Settings

```Autohotkey
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

SetWinDelay(-1) ; Remove short delay done automatically after every windowing command except IfWinActive and IfWinExist

SetKeyDelay(-1, -1) ; Remove short delay done automatically after every keystroke sent by Send or ControlSend

SetMouseDelay(-1) ; Remove short delay done automatically after Click and MouseMove/Click/Drag
```
Folders
```Autohotkey
VersionTitle := "Plugin Support"

ScriptName := "CoffeeTools"

AppFolderName := "CoffeePoweredAutomationTools"

AppFolder := A_AppData . "\" . AppFolderName

AppPluginsFolder := AppFolder . "\Plugins"

AppSettingsFolder := AppFolder . "\Settings"

AppUpdaterFile := AppFolder . "\Updater.ahk"

AppUpdaterSettingsFile := AppFolder . "\UpdaterInfo.ini"

LauncherAhkFile := AppFolder . "\Launcher.ahk"

MainScriptAhkFile := AppFolder . "\" . ScriptName . ".ahk"
```
Variables
```Autohotkey
CurrentScriptBranch := "main"

CloseToTray := false

PluginsLoaded := false
```
Tabs
```Autohotkey
HomeTAB := true

SettingsTAB := true

OtherScriptsTAB := false ;Set to true

WindowsTAB := false ;Set to true
```
Links
```Autohotkey
GithubPage := "https://github.com/veskeli/CoffeePoweredAutomationTools"
```
Ini
```Autohotkey
AppSettingsIni := AppSettingsFolder . "\Settings.ini"

AppGameScriptSettingsIni := AppSettingsFolder . "\GameScriptSettings.ini"

AppHotkeysIni := AppSettingsFolder . "\Hotkeys.ini"

AppVersionIdListIni := AppFolder . "\temp\VersionIdList.ini"

AppPreVersionsIni := AppFolder . "\temp\PreVersions.ini"
```
Text
```Autohotkey
RandomCoffeeQuotesFile := AppSettingsFolder . "\RandomCoffeeQuotes.txt"

LoadedPluginsFile := AppSettingsFolder . "\LoadedPlugins.txt"
```
Globals
```Autohotkey
global Version

global ScriptName

global AppUpdaterSettingsFile

global CurrentScriptBranch

global AppUpdaterFile

global RandomCoffeeQuotesFile

global CloseToTray
```