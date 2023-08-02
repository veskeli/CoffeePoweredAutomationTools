#NoEnv
#SingleInstance Force
#Persistent

defaultDelay := 100
defaultUsername := A_UserName ; Set the default value to the current user

Gui, Add, Text, , Username:
Gui, Add, Edit, vUsername w150, % defaultUsername
Gui, Add, Text, , Executable Path:
Gui, Add, Edit, vExecutablePath w300
Gui, Add, Button, gSelectApp, Select App
Gui, Add, Text, , Delay (seconds):
Gui, Add, Edit, vDelay w50, % defaultDelay
Gui, Add, Button, gCreateTask Default, Create Task

Gui, Show, , Task Scheduler Setup
return

CreateTask:
    Gui, Submit, NoHide
    executablePath := ExecutablePath
    delaySeconds := Delay
    username := Username

    if (delaySeconds = "") ; If the delay field is empty, set it to the default value
        delaySeconds := defaultDelay

    if (username = "") ; If the username field is empty, set it to the default value (current user)
        username := defaultUsername

    taskName := "MyStartupTask"
    
    RunWait, % "schtasks /create /tn " taskName " /tr """ executablePath """ /sc ONLOGON /delay " delaySeconds " /ru " username, , Hide

    if (ErrorLevel) {
        MsgBox, Failed to create the scheduled task.
    } else {
        MsgBox, Task created successfully. The executable will open with a delay of %delaySeconds% seconds upon login.
    }
return

SelectApp:
    FileSelectFile, executablePath, 1, , Select Executable
    GuiControl,, ExecutablePath, %executablePath%
return

GuiClose:
    ExitApp
return
