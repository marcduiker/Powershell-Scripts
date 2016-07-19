<#
    This script searches for *.update files in the build folder and deploys them using cURL/Sitecore.Ship.
#>

Param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$SiteUrl,
    [Parameter(Position=1, Mandatory=$true)]
    [string]$DropFolderUNCPath,
    [Parameter(Position=2)]
    [ValidateRange(0, 9999999)]
    [int]$ConnectionTimeOutInSeconds = 300,
    [Parameter(Position=3)]
    [ValidateRange(0, 9999999)]
    [int]$MaxTimeOutInSeconds = 900
)

function Deploy-SitecorePackage
{
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$SiteUrl,
        [Parameter(Position=1, Mandatory=$true)]
        [string]$UpdatePackagePath,
        [Parameter(Position=2)]
        [ValidateRange(0, 9999999)]
        [int]$ConnectionTimeOutInSeconds = 300,
        [Parameter(Position=3)]
        [ValidateRange(0, 9999999)]
        [int]$MaxTimeOutInSeconds = 900
    )

    $fileUploadUrl = "$SiteUrl/services/package/install/fileupload"
    $curlExe = 'curl.exe'
    $curlPath = "$PSScriptRoot\tools\curl-7.33.0-win64-nossl\$curlExe" # This is the local development path.
    if (-not (Test-Path "$curlPath"))
    {
        $curlPath = "$PSScriptRoot\$curlExe" # This is the path on the CI server.
    }

    $curlCommand= "$curlPath --show-error --silent --connect-timeout $ConnectionTimeOutInSeconds --max-time $MaxTimeOutInSeconds --form ""filename=@$UpdatePackagePath"" $fileUploadUrl"

    Write-Output "INFO: Starting Invoke-Expression: $curlCommand"

    Invoke-Expression $curlCommand
}

function Find-UpdatePacakges
{
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$BuildFolder,
        [Parameter(Position=1, Mandatory=$true)]
        [string]$SearchPattern
    )
        
    Get-ChildItem -Path "$BuildFolder" -File -Filter $SearchPattern -Recurse
}

$recentBuildFolderFullPath = Resolve-Path "$DropFolderUNCPath"
$searchPattern = '*.update'
Write-Output "INFO: Searching for $searchPattern files in $recentBuildFolderFullPath."
$updateFiles = Find-UpdatePacakges -BuildFolder "$recentBuildFolderFullPath" -SearchPattern $searchPattern

$fileCount = ($updateFiles | measure).Count

if ($fileCount -ne 0)
{
    Write-Output "INFO: Found $fileCount matches in $recentBuildFolderFullPath."

    foreach ($updateFile in $updateFiles)
    {
        $updateFileFullName = $updateFile.FullName
        Write-Output "INFO: Calling deploy function for $updateFileFullName"
                
        $result = Deploy-SitecorePackage -SiteUrl $SiteUrl -UpdatePackagePath "$updateFileFullName" -ConnectionTimeOutInSeconds $ConnectionTimeOutInSeconds -MaxTimeOutInSeconds $MaxTimeOutInSeconds
        
        Write-Output "INFO: $result"
    }
}
else
{
    Write-Output "INFO: No files found in $recentBuildFolderFullPath that matches $searchPattern."
}
