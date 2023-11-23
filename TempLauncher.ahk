#Requires AutoHotkey v2.0+
#SingleInstance Force
ListLines(false)
SetWorkingDir(A_ScriptDir)
SplitPath(A_ScriptName, , , , &GameScripts)
Persistent
;____________________________________________________________
;//////////////[Launcher]///////////////
LauncherVersion := "0.14"



;//////////////[Folders]///////////////
ScriptName := "CoffeeTools"
AppFolderName := "CoffeePoweredAutomationTools"
AppFolder := A_ScriptDir ;A_AppData . "\" . AppFolderName
AppPluginsFolder := AppFolder . "\Plugins"
AppSettingsFolder := AppFolder . "\Settings"
MainScriptFile := AppFolder . "\" . ScriptName
MainScriptAhkFile := AppFolder . "\" . ScriptName . ".ahk"
AppUpdaterSettingsFile := AppFolder . "\UpdaterInfo.ini"
MainScriptAhkFileWithPlugins := AppFolder . "\" . ScriptName . "WithPlugins.ahk"
LauncherAhkFile := AppFolder . "\Launcher.ahk"



;//////////////[ini]///////////////
LoadedPluginsFile := AppSettingsFolder . "\LoadedPlugins.txt"



;//////////////[Global]///////////////
global LauncherVersion
global AppFolderName
global AppFolder
global AppSettingsFolder
global MainScriptAhkFileWithPlugins



;____________________________________________________________
;____________________________________________________________
;//////////////[Run]///////////////
BuildApp := false
;Check folder for plugins and add them to array
Temp_Plugins := Array()
Temp_LoadedPlugins := Array()
IsEmpty := true
loop files, AppPluginsFolder . "\*.ahk"
{
    Temp_Plugins.Push(A_LoopFileName)
    IsEmpty := false
}
;if no plugins skip to run
if(IsEmpty)
{
    goto RunDefault
}
;Check for loaded plugins
if(FileExist(LoadedPluginsFile) && True == False)
{
    TextFile := FileRead(LoadedPluginsFile)
    loop parse TextFile, "`n"
    {
        Temp_LoadedPlugins.Push(A_LoopField) ;Add loaded plugins to array
    }
}
else
{
    ;If no loaded plugins then skip to build
    BuildApp := true
    goto Build
}
;Compare plugins
for plugin in Temp_Plugins
{
    for loadedPlugin in Temp_LoadedPlugins
    {
        if(plugin == loadedPlugin)
        {
            break
        }
        else if(Temp_LoadedPlugins.Length() == A_Index) ;if no match build app
        {
            BuildApp := true
        }
    }
    if(BuildApp) ;skip check if build app == true
    {
        break
    }
}
;Build/Rebuild app if new plugins
Build:
if(BuildApp)
{
    ;Delete old
    if(FileExist(MainScriptAhkFileWithPlugins))
        FileDelete(MainScriptAhkFileWithPlugins)
    NewFile := ""
    ;Add #Include
    for plugin in Temp_Plugins
    {
        if(A_Index == 1)
        {
            NewFile := "#Include " . AppPluginsFolder . "\" . plugin
        }
        else
        {
            NewFile := NewFile . "`n" . "#Include " . AppPluginsFolder . "\" . plugin
        }
    }
    MainFile := FileRead(MainScriptAhkFile)
    ;Save Main Script Start And End
    MainFileStart := ""
    MainFileEnd := ""
    SaveToStart := true
    ChangedPluginVariable := false
    loop parse, MainFile, "`n"
    {
        if(InStr(A_LoopField,"<---End_Include--->"))
        {
            MainFileEnd := A_LoopField
            continue
        }
        else if(InStr(A_LoopField,"PluginsLoaded :=") && !ChangedPluginVariable)
        {
            MainFileStart := MainFileStart . "`n" . "PluginsLoaded := true"
            ChangedPluginVariable := true
        }
        else if(InStr(A_LoopField,"<---Start_Include--->"))
        {
            MainFileStart := MainFileStart . "`n" . A_LoopField
            SaveToStart := false
        }
        else
        {
            if(A_Index == 1)
            {
                MainFileStart := A_LoopField
            }
            else
            {
                if(SaveToStart)
                {
                    MainFileStart := MainFileStart . "`n" . A_LoopField
                }
                else
                {
                    MainFileEnd := MainFileEnd . "`n" . A_LoopField
                }
            }
        }
    }
    ;Add Main Start
    NewFile := NewFile . "`n" . MainFileStart
    ;Add Include Menu Elements
    for plugin in Temp_Plugins
    {
        pluginGui := StrReplace(plugin,".ahk")
        NewFile := NewFile . "`n" . pluginGui . "LoadTab()"
    }
    ;Add Main End
    NewFile := NewFile . "`n" . MainFileEnd
    ;Create File
    FileAppend(NewFile,MainScriptAhkFileWithPlugins)
    ;Add loaded plugins to file
    LoadedPluginsText := ""
    for plugin in Temp_Plugins
    {
        if(A_Index == 1)
        {
            LoadedPluginsText := plugin
        }
        else
        {
            LoadedPluginsText := LoadedPluginsText . "`n" . plugin
        }
    }
    if(FileExist(LoadedPluginsFile))
        FileDelete(LoadedPluginsFile)
    FileAppend(LoadedPluginsText,LoadedPluginsFile)
}
;Run app
RunApp:
if(FileExist(MainScriptAhkFileWithPlugins))
{
    Run(MainScriptAhkFileWithPlugins) ;Run scripts with plugins
}
else
{
    Run(MainScriptAhkFile) ;Run script (Safe mode)
}
ExitApp
RunDefault:
{
    Run(MainScriptAhkFile) ;Run script (Safe mode)
    ExitApp
}