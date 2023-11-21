#Requires AutoHotkey v2.0
;____________________________________________________________
;//////////////[Def variables]///////////////
NvidiaControlPanelToolsVersion := "0.11"
NCPTProgressText := "null"
global NCPTControlPanelLocation := ""
/*
//////////////[Profile setup]///////////////
------- Default profile:
Section: "DefaultProfile"
Keys:
"Height"
------- Other profiles:
Section: "ResolutionProfiles"
Keys:
"ProfileCount"
"[Number]" contains [Name]
"[Number]Height"
*/
;____________________________________________________________
;//////////////[Gui]///////////////
NvidiaControlPanelToolsLoadTab()
{
    global NCPTSettingsFile := AppPluginsFolder "/NvidiaControlPanelTools/NvidiaControlPanelTools.ini"
    global NCPTResolutionProfileFile := AppPluginsFolder "/NvidiaControlPanelTools/ResolutionProfiles.ini"
    DirCreate(AppPluginsFolder "/NvidiaControlPanelTools")
    global NCPTDefaultControlPanelSection := "DefaultControlPanel"

    Tab.UseTab("NvidiaControlPanelTools")

    myGui.SetFont("s13")
    myGui.Add("Text", "x16 y24 w403 h22 +0x200", "Uses mouse movement and clicks when executing.")
    myGui.SetFont()

    ;Change resolution
    myGui.Add("GroupBox", "x8 y48 w486 h57", "Change Resolution")
    myGui.Add("Text", "x24 y72 w101 h23", "Change Resolution:")

    global NCPTComboBox1 := myGui.Add("DropDownList", "x128 y72 w170") ;["490","478"]
    NCPTComboBox1.enabled := false

    global NCPTogcButtonSet := ogcButtonSet := myGui.Add("Button", "x304 y72 w80 h23", "Set")
    NCPTogcButtonSet.OnEvent("Click",NCPTChangeResolution.Bind(false))
    global NCPTogcButtonSetDefault := myGui.Add("Button", "x384 y72 w80 h23", "Set Default")
    NCPTogcButtonSetDefault.OnEvent("Click",NCPTChangeResolution.Bind(true))

    ;Resolution profiles
    myGui.Add("GroupBox", "x504 y32 w318 h95", "Set Resolution Profile")
    global NCPTogcButtonCreatenewresolutionprofile := myGui.Add("Button", "x520 y56 w154 h23", "Create new resolution profile")
    NCPTogcButtonCreatenewresolutionprofile.OnEvent("Click",NCPTShowNewProfileGui.Bind(false))
    global NCPTogcButtonEditexistingresolutionprofile := myGui.Add("Button", "x520 y88 w157 h23", "Delete Selected Profile") ;"Edit existing resolution profile"
    NCPTogcButtonEditexistingresolutionprofile.OnEvent("Click",NCPTEditCurrentExistingProfile.Bind())
    NCPTogcButtonEditexistingresolutionprofile.enabled := false
    global NCPTogcButtonSetDefaultprofile := myGui.Add("Button", "x680 y56 w109 h23", "Set Default profile")
    NCPTogcButtonSetDefaultprofile.OnEvent("Click",NCPTShowNewProfileGui.Bind(true))

    ;Default settings
    myGui.Add("GroupBox", "x504 y136 w317 h74", "Default settings")
    myGui.Add("Text", "x512 y152 w127 h23 +0x200", "Nvidia Control Panel exe:")
    global NCPTEdit1 := myGui.Add("Edit", "x648 y152 w160 h21")
    NCPTEdit1.OnEvent("Change",NCPTDefaultLocationTextChanged.Bind())
    global NCPTogcButtonSave := myGui.Add("Button", "x728 y176 w80 h23 +Disabled", "Save")
    NCPTogcButtonSave.OnEvent("Click",NCPTSaveDefaultControlPanelLocation.Bind())
    ;global NCPTogcButtonPick := myGui.Add("Button", "x648 y176 w80 h23 +Disabled", "Pick")
    global NCPTControlPanelStatus := myGui.Add("Text", "x512 y176 w120 h23 +0x200", "Status: null")


    ;functions
    NCPTCheckControlPanelLocation()
    NCPTCheckDefaultResolutionProfile()
    NCPTUpdateResolutionProfilesDropdown()
}
/**
 * Check if control panel exe is found
**/
NCPTCheckControlPanelLocation()
{
    global NCPTControlPanelLocation
    local settingFileExist := false
    if(FileExist(NCPTSettingsFile))
    {
        settingFileExist := true
        local defaultLocation := IniRead(NCPTSettingsFile,NCPTDefaultControlPanelSection,"Location","")
        if(FileExist(defaultLocation))
        {
            NCPTControlPanelLocation := defaultLocation
            NCPTEdit1.text := NCPTControlPanelLocation
            NCPTDefaultlocationStatus(true)
            return
        }
    }

    if(FileExist("C:\Program Files\NVIDIA Corporation\Control Panel Client\nvcplui.exe"))
    {
        NCPTControlPanelLocation := "C:\Program Files\NVIDIA Corporation\Control Panel Client\nvcplui.exe"
        NCPTEdit1.text := NCPTControlPanelLocation
    }
    else if(FileExist("C:\Program Files\WindowsApps\NVIDIACorp.NVIDIAControlPanel_8.1.964.0_x64__56jybvy8sckqj\nvcplui.exe"))
    {
        NCPTControlPanelLocation := "C:\Program Files\WindowsApps\NVIDIACorp.NVIDIAControlPanel_8.1.964.0_x64__56jybvy8sckqj\nvcplui.exe"
        NCPTEdit1.text := NCPTControlPanelLocation
    }

    if(NCPTControlPanelLocation == "")
        NCPTDefaultlocationStatus(false)
    else
    {
        NCPTDefaultlocationStatus(true)
        if(!settingFileExist)
        {
            IniWrite(NCPTControlPanelLocation,NCPTSettingsFile,NCPTDefaultControlPanelSection,"Location")
        }
    }
}
/**
 * Check Defualt Resolution profile
**/
NCPTCheckDefaultResolutionProfile()
{
    ;DefaultProfile
    local NCPTDefaultProfile := IniRead(NCPTResolutionProfileFile,"DefaultProfile","Set",0)
    if(NCPTDefaultProfile == 1)
    {
        ;Read default profile
        NCPTogcButtonSetDefaultprofile.text := "Edit Default profile"
        NCPTogcButtonSetDefault.Enabled := true
    }
    else
    {
        NCPTogcButtonSetDefault.Enabled := false
    }
}
/**
 * Set Resolution
**/
NCPTChangeResolution(UseDefault,*)
{
    local selection := 0
    if(UseDefault)
    {
        selection := IniRead(NCPTResolutionProfileFile,"DefaultProfile","Height")
    }
    else
    {
        local getCount := IniRead(NCPTResolutionProfileFile,"ResolutionProfiles",NCPTComboBox1.Value "Height")
        selection := getCount
    }
    local CPWidth := 1000
    local CPHeight := 700

    if(selection == 0)
    {
        MsgBox("Profile not selected or correct!?!")
        return
    }

    if(FileExist(NCPTControlPanelLocation))
        Run(NCPTControlPanelLocation)
    else
    {
        MsgBox("Nvidia control panel location not set correctly!?!")
        return
    }

    ;Progress
    NCPTShowProgress()
    NCPTUpdateProgress("Waiting for Nvidia Control Panel")
    ;Wait for window to open
    loop 1000{
        if(WinExist("NVIDIA Control Panel"))
            break
        sleep 100
    }
    if(WinExist("NVIDIA Control Panel"))
        WinMove(0,0,CPWidth,CPHeight,"NVIDIA Control Panel")
    else
    {
        MsgBox("NVIDIA Control Panel Not found!")
        return
    }

    NCPTUpdateProgress("Finding Correct Tab")
    hCtl := ControlGetHwnd("Change resolution","NVIDIA Control Panel")
    ControlClick(hCtl)

    NCPTUpdateProgress("Finding Correct Resolution")
    MouseMove(412, 470)
    sleep 25
    loop 15
    {
        Click("WheelUp")
    }

    NCPTUpdateProgress("Selecting correct resolution")
    sleep(50)
    MouseMove(412,selection)
    sleep 2
    Click()
    sleep 275

    ;TODO: Make sure using highest hz
    ;local ListItems := ControlGetItems("ComboBox3","NVIDIA Control Panel")


    NCPTUpdateProgress("Saving resolution changes")
    ;hApply := ControlGetHwnd("&Apply","NVIDIA Control Panel")
    ;ControlClick(hApply)

    Click(829, 617) ;Apply

    sleep 350
    WinWait("ahk_class #32770")
    sleep 150
    Click(276, 86)

    NCPTUpdateProgress("Ready (Closing control panel)")
    sleep 200
    WinClose("NVIDIA Control Panel")
    sleep 200
    NCPTUpdateProgress("Ready (Closing control panel)")
    sleep 600
    NCPTCloseProgress()
}
/**
 * Simple gui with progress text
**/
NCPTShowProgress()
{
    global NCPTProgressGUI := Gui()
    NCPTProgressGUI.Opt("-MinimizeBox -MaximizeBox +AlwaysOnTop")
    NCPTProgressGUI.SetFont("s14")
    NCPTProgressGUI.Add("Text", "x8 y8 w120 h32 +0x200", "Current Task:")
    NCPTProgressGUI.SetFont("s14")
    global NCPTProgressGUIText := NCPTProgressGUI.Add("Text", "x136 y8 w359 h31 +0x200", NCPTProgressText)
    ogcButtonCancel := NCPTProgressGUI.Add("Button", "x128 y48 w80 h23 +Disabled", "Cancel")
    NCPTProgressGUI.OnEvent('Close', (*) => NCPTCloseProgress())
    NCPTProgressGUI.Title := "NVIDIA Control Panel Status"
    NCPTProgressGUI.Show("w503 h79")
}
/**
 * Close progress gui
**/
NCPTCloseProgress()
{
    NCPTProgressText := "null"
    NCPTProgressGUI.Destroy()
}
/**
 * Update progress gui text
**/
NCPTUpdateProgress(NewText)
{
    NCPTProgressGUIText.Text := NewText
}
/**
 * If Default location text is changed enable save button
**/
NCPTDefaultLocationTextChanged(*)
{
    if(NCPTControlPanelLocation == NCPTEdit1.text)
    {
        NCPTogcButtonSave.Enabled := false
    }
    else
    {
        NCPTogcButtonSave.Enabled := true
    }
}
/**
 * Try save file location if found
**/
NCPTSaveDefaultControlPanelLocation(*)
{
    if(FileExist(NCPTEdit1.text))
    {
        NCPTDefaultlocationStatus(true)
        NCPTControlPanelLocation := NCPTEdit1.text
        IniWrite(NCPTControlPanelLocation,NCPTSettingsFile,NCPTDefaultControlPanelSection,"Location")
        NCPTogcButtonSave.Enabled := false
    }
    else
    {
        MsgBox("File not found!")
    }
}
/**
 * Set status
 * @param Status is boolean
**/
NCPTDefaultlocationStatus(Status)
{
    if(Status)
    {
        NCPTControlPanelStatus.text := "Status: Ready"
        NCPTogcButtonSet.enabled := true
        NCPTogcButtonSetDefault := true
    }
    else
    {
        NCPTControlPanelStatus.text := "Status: Not found!"
        NCPTogcButtonSet.enabled := false
        NCPTogcButtonSetDefault := false
    }
}
NCPTShowNewProfileGui(SetDefaultProfile := false,*)
{
    global NCPTNewProfileGui := Gui()

    NCPTNewProfileGui.Add("Text", "x8 y8 w70 h23 +0x200", "Profile name:")
    global NCPTNewProfileNameEdit := NCPTNewProfileGui.Add("Edit", "x88 y8 w135 h21")

    NCPTNewProfileGui.Add("Text", "x8 y32 w94 h23 +0x200", "Set default height:")
    global NCPTNewProfileHeight := NCPTNewProfileGui.Add("Edit", "x104 y32 w120 h21")

    ogcButtonSet := NCPTNewProfileGui.Add("Button", "x64 y56 w80 h23", "Set")
    ogcButtonSet.OnEvent("Click",NCPTSaveNewProfile.Bind(SetDefaultProfile))
    ogcButtonCancel := NCPTNewProfileGui.Add("Button", "x144 y56 w80 h23", "Cancel")
    ogcButtonCancel.OnEvent("Click",(*) => NCPTCloseNewProfileGui())
    NCPTNewProfileGui.OnEvent('Close', (*) => NCPTCloseNewProfileGui())
    NCPTNewProfileGui.Title := "Set Resolution Profile"
    NCPTNewProfileGui.Show("w232 h87")

    ;Check if creating default profile
    if(SetDefaultProfile)
    {
        NCPTNewProfileNameEdit.Text := "Default"
        NCPTNewProfileNameEdit.Enabled := false
    }
}
NCPTSaveNewProfile(Default := false,*)
{
    if(NCPTNewProfileHeight.Text == "" or NCPTNewProfileNameEdit == "")
        return
    if(Default)
    {
        IniWrite(NCPTNewProfileHeight.Text,NCPTResolutionProfileFile,"DefaultProfile","Height")
        IniWrite(true,NCPTResolutionProfileFile,"DefaultProfile","Set")
        NCPTogcButtonSetDefaultprofile.text := "Edit Default profile"
    }
    else
    {
        ;Get count and save new one
        local count := IniRead(NCPTResolutionProfileFile,"ResolutionProfiles","ProfileCount",0)
        count++
        IniWrite(count,NCPTResolutionProfileFile,"ResolutionProfiles","ProfileCount")
        ;Save profile
        IniWrite(NCPTNewProfileHeight.Text,NCPTResolutionProfileFile,"ResolutionProfiles",count "Height")
        IniWrite(NCPTNewProfileNameEdit.Text,NCPTResolutionProfileFile,"ResolutionProfiles",count)
        ;Update dropdown
        NCPTUpdateResolutionProfilesDropdown()
    }
    NCPTCloseNewProfileGui()
}
/**
 * Get all profile names and update dropdown
**/
NCPTUpdateResolutionProfilesDropdown()
{
    ;Clear DDL
    NCPTComboBox1.delete()
    ;Get all profiles
    local count := IniRead(NCPTResolutionProfileFile,"ResolutionProfiles","ProfileCount",0)
    if(count == 0)
    {
        NCPTComboBox1.Enabled := false
        NCPTogcButtonSet.Enabled := false
        NCPTogcButtonEditexistingresolutionprofile.Enabled := false
        return
    }

    ;Loop all profile names
    local NewDropdownContent := Array()
    loop count
    {
        local content := IniRead(NCPTResolutionProfileFile,"ResolutionProfiles",A_Index)
        NewDropdownContent.Push(content)
    }

    ;Update dropdown
    NCPTComboBox1.Add(NewDropdownContent)
    NCPTComboBox1.Enabled := true
    NCPTComboBox1.Choose(1)

    ;update buttons
    NCPTogcButtonSet.Enabled := true
    NCPTogcButtonEditexistingresolutionprofile.Enabled := true
}
NCPTCloseNewProfileGui(*)
{
    NCPTNewProfileGui.Destroy()
}
/**
 * TODO: Edit
 * Currently remove selected profile
**/
NCPTEditCurrentExistingProfile(*)
{
    NCPTRemoveProfile(NCPTComboBox1.Value)
}
/**
 * Remove resolution profile
 * @param count Profile ID
**/
NCPTRemoveProfile(count)
{
    ;Save all profiles to arrays
    local CurrentProfiles := Array()
    local CurrentProfileHeights := Array()

    local ProfCount := IniRead(NCPTResolutionProfileFile,"ResolutionProfiles","ProfileCount",0)
    if(ProfCount == 0)
        return

    loop ProfCount
    {
        ;Read inis
        local contentName := IniRead(NCPTResolutionProfileFile,"ResolutionProfiles",A_Index)
        local contentHeight := IniRead(NCPTResolutionProfileFile,"ResolutionProfiles",A_Index "Height")

        ;Delete ini key
        IniDelete(NCPTResolutionProfileFile,"ResolutionProfiles",A_Index)
        IniDelete(NCPTResolutionProfileFile,"ResolutionProfiles",A_Index "Height")

        ;Skip one to be removed
        if(A_Index == count)
            continue

        ;Add to arrays
        CurrentProfiles.Push(contentName)
        CurrentProfileHeights.Push(contentHeight)
    }
    ;save new profile count
    local NewProfCount := CurrentProfiles.Length
    IniWrite(NewProfCount,NCPTResolutionProfileFile,"ResolutionProfiles","ProfileCount")
    ;save all profiles
    loop NewProfCount
    {
        IniWrite(CurrentProfiles[A_Index],NCPTResolutionProfileFile,"ResolutionProfiles",A_Index)
        IniWrite(CurrentProfileHeights[A_Index],NCPTResolutionProfileFile,"ResolutionProfiles",A_Index "Height")
    }

    ;Update Dropdown
    NCPTUpdateResolutionProfilesDropdown()
}