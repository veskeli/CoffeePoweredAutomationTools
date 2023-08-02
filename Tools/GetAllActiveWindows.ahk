#Persistent
Gui +LastFound
hwnd := WinExist()

Gui Add, ListBox, r20 w400 h300 vMyListBox, ; Create a list box control
Gui Add, Button, gGetSelectedWindow, Get Selected Window ; Create a button to get the selected window
Gui Add, Button, gRefreshWindowList, Refresh Window List ; Create a button to refresh the window list

RefreshWindowList() ; Initial population of the window list

Gui Show, , Open Windows List ; Show the GUI

return

GetSelectedWindow:
    GuiControlGet, selectedWindow, , MyListBox ; Get the selected window from the list box
    if (selectedWindow) {
        WinActivate, ahk_id %selectedWindow% ; Activate the selected window
    }
return

RefreshWindowList()
{
    ; Clear the list box
    GuiControl,, MyListBox, |
        
    ; Get all open windows
    WinGet, windowList, List

    ; Add each window title to the list box
    Loop, % windowList
    {
        thisHwnd := windowList%A_Index%
        WinGetTitle, windowTitle, ahk_id %thisHwnd%
        if (windowTitle <> "") {
            GuiControl,, MyListBox, %windowTitle%
        }
    }
}

GuiClose:
    ExitApp
return
