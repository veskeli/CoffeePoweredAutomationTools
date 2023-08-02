; Replace "APP_ID" with the Steam App ID of the game you want to open
SteamAppID := "APP_ID"

; Function to open the Steam game
OpenSteamGame(steamAppID) {
    Run, steam://rungameid/%steamAppID%
}

; Example usage: Open the game with the specified Steam App ID
OpenSteamGame(SteamAppID)
