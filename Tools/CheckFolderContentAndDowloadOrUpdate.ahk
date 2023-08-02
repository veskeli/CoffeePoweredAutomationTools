#Persistent
SetBatchLines, -1

; Replace the following variables with your GitHub repository details
githubUsername := "YourGitHubUsername"
repositoryName := "YourRepositoryName"
branchName := "main" ; Replace with the branch you want to compare
folderPath := "path/to/folder" ; The path to the folder in the repository

localFolderPath := "C:\Path\to\local\folder" ; Replace with the local folder where you want to save the files

; Set GitHub API URL
apiUrl := "https://api.github.com/repos/" . githubUsername . "/" . repositoryName . "/contents/" . folderPath . "?ref=" . branchName

; Get the list of files from the GitHub repository
response := GetGitHubApiResponse(apiUrl)

; Loop through the files from the GitHub repository
for index, file in response
{
    fileName := file.name
    localFilePath := localFolderPath . "\" . fileName

    ; Check if the file exists locally
    if FileExist(localFilePath)
    {
        ; File exists locally, compare the content with GitHub version
        fileUrl := file.download_url
        githubContent := GetFileContentFromGitHub(fileUrl)
        localContent := ReadFile(localFilePath)

        ; If contents are different, update the local file
        if (githubContent <> localContent)
        {
            FileDelete, %localFilePath% ; Delete the old local file
            URLDownloadToFile, % fileUrl, % localFilePath ; Download the new file from GitHub
        }
    }
    else
    {
        ; File is missing locally, download it from GitHub
        fileUrl := file.download_url
        URLDownloadToFile, % fileUrl, % localFilePath
    }
}

ExitApp

GetGitHubApiResponse(apiUrl) {
    WinHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WinHttp.Open("GET", apiUrl)
    WinHttp.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:81.0) Gecko/20100101 Firefox/81.0")
    WinHttp.Send()

    WinHttp.WaitForResponse()

    if (WinHttp.Status() != 200) {
        MsgBox, GitHub API returned an error: %WinHttp.Status%
        return
    }

    responseText := WinHttp.ResponseText()
    WinHttp := ""

    ; Use the JsonObj library to parse the JSON response
    Json := new JsonObj(responseText)
    response := Json.parse()
    return response
}

GetFileContentFromGitHub(fileUrl) {
    WinHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WinHttp.Open("GET", fileUrl)
    WinHttp.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:81.0) Gecko/20100101 Firefox/81.0")
    WinHttp.Send()

    WinHttp.WaitForResponse()

    if (WinHttp.Status() != 200) {
        MsgBox, GitHub API returned an error: %WinHttp.Status%
        return
    }

    responseText := WinHttp.ResponseText()
    WinHttp := ""
    return responseText
}

ReadFile(filePath) {
    FileRead, fileContents, %filePath%
    return fileContents
}
