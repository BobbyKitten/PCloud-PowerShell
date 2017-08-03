function Get-PCloudTocken {
    if ($(Test-Path .\PCloud.tocken) -eq $true) {
        $PCloud_auth = $(Get-Content .\PCloud.tocken)
        return $PCloud_auth
    }
    Write-Warning "There is no tocken!"
    return $nill
}

function New-PCloudTocken {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Username,
        [Parameter(Mandatory=$true)]
        [string]$Password,
        [switch]$SaveTocken
    )
    $unswer = Invoke-WebRequest -Uri "api.pcloud.com/userinfo?getauth=1&logout=1&username=$Username&password=$Password" | ConvertFrom-Json
    if ($unswer.result -eq 0) {
        if ($SaveTocken -eq $true) {
            echo $unswer.auth > .\PCloud.tocken
        }
        return $unswer.auth
    }
    return $unswer.error
}

function Get-PCloudFiles {
    [CmdletBinding()]
    Param(
        [string]$Path = "/",
        [string]$FolderId = "-1",
        [switch]$NoFiles
    )
    $tocken = Get-PCloudTocken
    if ($tocken -eq $null) { return $null }
    $url = "https://api.pcloud.com/listfolder?auth=$tocken"
    # Select if we will use path or FolderId
    if ($FolderId -eq "-1") { $url = $url + "&path=$Path" } else { $url = $url + "&folderid=$FolderId" }
    # Remove files, just folders, just hardcore!
    if ($NoFiles -eq $true) { $url = $url + "&nofiles=1" }
    $unswer = Invoke-WebRequest -Uri $url | ConvertFrom-Json
    if ($unswer.result -eq 0) {
        for ($i = 0; $i -lt $unswer.metadata.contents.Length; $i = $i + 1) { $unswer.metadata.contents[$i].PSObject.Properties.Remove('contents') } 
        return $unswer.metadata.contents }
    return $unswer.error
}

function Upload-PCloudFile {
    [CmdletBinding()]
    Param (
        [string]$Path = "/",
        [string]$FolderId = "-1",
        [Parameter(Mandatory=$true)]
        [string]$File,
        [string]$FileName = "",
        [switch]$RenameIfExists
    )
    $tocken = Get-PCloudTocken
    if ($tocken -eq $null) { return "error!" }
    $uri = "https://api.pcloud.com/uploadfile?auth=$tocken&filename=$FileName"
    # Select if we will use path or FolderId
    if ($FolderId -eq "-1") { $uri += "&path=$Path" } else { $uri += "&folderid=$FolderId" }
    # If file exists, then rename it
    if ($RenameIfExists -eq $true) { $uri = $uri + "&renameifexists=1" }

    #Upload File
    $wc = New-Object System.Net.WebClient
    [byte[]]$result = $wc.UploadFile($uri, $File)
    return [System.Text.Encoding]::ASCII.GetString($result)
}

function Download-PCloudFile {
    [CmdletBinding()]
    Param (
        [string]$FileName = "",
        [string]$FileId = "-1",
        [Parameter(Mandatory=$true)]
        [string]$FileOut
    )
    $tocken = Get-PCloudTocken
    if ($tocken -eq $null) { return "error!" }

    $url_getlink = "https://api.pcloud.com/getfilelink?auth=$tocken"
    
    if ($FileId -eq "-1") { $url_getlink += "&path=$FileName" } else { $url_getlink += "&fileid=$FileId" }
    
    $links = Invoke-WebRequest -Uri $url_getlink | ConvertFrom-Json

    if ($links.result -eq 0) {
        $wc = New-Object System.Net.WebClient
        $server_name = $links.hosts[0]
        $server_path = $links.path
        [byte[]]$result = $wc.DownloadFile("http://$server_name$server_path", $FileOut)
        return "Success"
    }

    return $links.error
}

function New-PCloudFolder {
    Write-Warning "Work in progress"
}

function Set-PCloudFolderName {
    Write-Warning "Work in progress"
}

function Remove-PCloudFolder {
    Write-Warning "Work in progress"
}

function Get-PCloudFileCheckSum {
    Write-Warning "Work in progress"
}

function Remove-PCloudFile {
    Write-Warning "Work in progress"
}

function Copy-PCloudFile {
    Write-Warning "Work in progress"
}

function Set-PCloudFileProperty {
    [CmdletBinding()]
    Param (
    [string]$Name
    )
    Write-Warning "Work in progress"
}

function LogOut-PCloud {

}

function Get-PCloudTockens {

}
