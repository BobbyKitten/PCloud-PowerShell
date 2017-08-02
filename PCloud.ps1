﻿function Get-PCloudTocken {
    if ($(Test-Path .\PCloud.tocken) -eq $true) {
        $PCloud_auth = $(Get-Content .\PCloud.tocken)
        return $PCloud_auth
    }
    return "No tocken"
}

function New-PCloudTocken {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Username,
        [Parameter(Mandatory=$true)]
        [string]$Password
    )
    $unswer = Invoke-WebRequest -Uri "api.pcloud.com/userinfo?getauth=1&logout=1&username=$Username&password=$Password" | ConvertFrom-Json
    if ($unswer.result -eq 0) {
        echo $unswer.auth > .\PCloud.tocken
        return $unswer.auth
    }
    return $unswer.error
}

function Get-PCloudFiles {
    [CmdletBinding()]
    Param(
        [string]$Path = "/",
        [Switch]$Recursive,
        [switch]$NoFiles
    )
    $tocken = Get-PCloudTocken
    if ($tocken -eq $null) { return $null }
    $url = "https://api.pcloud.com/listfolder?recursive=1&path=$Path&auth=$tocken"
    if ($Recursive -eq $true) { $url = $url + "&recursive=1" }
    if ($NoFiles -eq $true) { $url = $url + "&nofiles=1" }
    $unswer = Invoke-WebRequest -Uri $url | ConvertFrom-Json
    if ($unswer.result -eq 0) { return $unswer.metadata.contents }
    return $unswer.error
}