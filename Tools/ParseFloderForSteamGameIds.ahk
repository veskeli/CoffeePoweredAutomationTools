#Persistent

; Replace "C:\Path\to\your\games\folder" with the path to the folder containing your games
gamesFolder := "C:\Path\to\your\games\folder"

; Function to parse the folder and get the Steam App IDs
GetSteamAppIDs(gamesFolder) {
    AppIDs := ""
    Loop, Files, %gamesFolder%\*.*
    {
        filename := A_LoopFileLongPath
        AppID := ExtractAppIDFromFileName(filename)
        if (AppID)
            AppIDs .= AppID . "`n"
    }
    return AppIDs
}

; Function to extract the App ID from the game filename using a regular expression
ExtractAppIDFromFileName(filename) {
    RegExMatch(filename, "i)(\d{3,})", AppID)
    return (AppID) ? AppID1 : ""
}

; Example usage: Parse the folder and get the Steam App IDs
SteamAppIDs := GetSteamAppIDs(gamesFolder)
MsgBox, Steam App IDs:`n%SteamAppIDs%
