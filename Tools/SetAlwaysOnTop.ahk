#Persistent

Gui, +LastFound
hwnd := WinExist()

Gui Add, ComboBox, r20 w400 vMyComboBox, ; Create a combobox (dropdown) control
Gui Add, Button, gSetAlwaysOnTop, Set Always On Top ; Create a button to set the selected window as always on top
Gui Add, Button, gRefreshWindowList, Refresh Window List ; Create a button to refresh the window list

RefreshWindowListFunc() ; Initial population of the window list

Gui Show, , Select Window for Always On Top ; Show the GUI

return

SetAlwaysOnTop:
    GuiControlGet, selectedWindow, , MyComboBox ; Get the selected window from the dropdown
    if (selectedWindow) {
        WinSet, AlwaysOnTop, On, ahk_id %selectedWindow% ; Set the selected window as always on top
    }
return

RefreshWindowList:
    RefreshWindowListFunc()
return

RefreshWindowListFunc() {
    ; Clear the dropdown
    GuiControl,, MyComboBox,

    ; Get all open windows
    WinGet, windowList, List

    ; Add each window title to the dropdown
    Loop, % windowList
    {
        thisHwnd := windowList%A_Index%
        WinGetTitle, windowTitle, ahk_id %thisHwnd%
        if (windowTitle <> "") {
            GuiControl,, MyComboBox, %windowTitle%
        }
    }
}

GuiClose:
    ExitApp
return

/*
Not Working as intented but can be used as example
*/