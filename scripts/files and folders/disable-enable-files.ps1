<#
    This script can be used to rename Sitecore config files for an CD environment.

    This script searches in the $SolutionPath for files matching filenames in the cd-configuration.json file that 
    is expected to be located in the same folder as this script.
    Files matching the filenames in the FilesToDisable node will be renamed to .disabled.
    Files matching the filenames in the FilesToEnable node will be have the .disabled extension removed.
#>

Param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$SolutionPath,
    [Parameter(Position=1, Mandatory=$true)]
    [string]$ConfigurationFileName
)

function Get-MatchingFiles
{
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$SolutionPath,
        [Parameter(Position=1, Mandatory=$true)]  
        $FileNameArray,
        [Parameter(Position=2, mandatory=$true)]
        [string]$RelativeLocation
        
    )
    
    foreach ($file in $FileNameArray)
    {
        $regexPattern += $file.filename + '|'
    }

    if ($regexPattern.Length -gt 0)
    {
        $regexPattern = $regexPattern.SubString(0, $regexPattern.Length - 1)
    }
    
    # Only look for matching files in the App_Config folder.
    return Get-ChildItem -Directory -Path "$SolutionPath" -Filter "$RelativeLocation" | Get-ChildItem -File -Recurse | Where-Object { $_.Name -match "$regexPattern" }
        
}

function Disable-EnabledConfigFiles($FileArray)
{
    foreach ($file in $FileArray)
    {
        if ($file)
        {
            $fileFullPath = $file.FullName
            if (-not $file.FullName.EndsWith($disabled))
            {
                $disabledName = $file.Name + $disabled
                Write-Output "INFO: Renaming $fileFullPath to $disabledName ..." 
                Rename-Item -Path "$fileFullPath" -NewName $disabledName
            }
        }
    }
}

function Enable-DisabledConfigFiles($FileArray)
{
    foreach ($file in $FileArray)
    {
        if ($file)
        {
            $fileFullPath = $file.FullName
            $enabledName = $file.Name.Substring(0, $file.Name.Length - $disabled.Length)
            Write-Output "INFO: Renaming $fileFullPath to $enabledName ..." 
            Rename-Item -Path "$fileFullPath" -NewName $enabledName
        }
    }
}

$disabled = '.disabled';

$FileNamesJsonFile = "$PSScriptRoot\$ConfigurationFileName"

# Read json file to get arrays of files to disable and enable.
$jsonFile = Get-Content -Raw -Path "$FileNamesJsonFile" | ConvertFrom-Json

# Get config file names from configuration
$configFilesLocation = $jsonFile.ConfigFiles.Location
$configFilesToDisableFromJson = $jsonFile.ConfigFiles.FilesToDisable
$configFilesToEnableFromJson = $jsonFile.ConfigFiles.FilesToEnable

# Search config files in the SolutionPath
[System.IO.FileInfo[]]$configFilesToDisable
if ($configFilesToDisableFromJson)
{
    [System.IO.FileInfo[]]$configFilesToDisable = Get-MatchingFiles -SolutionPath "$SolutionPath" -FileNameArray $configFilesToDisableFromJson -RelativeLocation "$configFilesLocation"
}

[System.IO.FileInfo[]]$configFilesToEnable
if ($configFilesToEnableFromJson)
{
    [System.IO.FileInfo[]]$configFilesToEnable = Get-MatchingFiles -SolutionPath "$SolutionPath" -FileNameArray $configFilesToEnableFromJson -RelativeLocation "$configFilesLocation"
}

# Get assembly file names from configuration
$assemblyFilesLocation = $jsonFile.AssemblyFiles.Location
$assemblyFilesToDisableFromJson = $jsonFile.AssemblyFiles.FilesToDisable
$assemblyFilesToEnableFromJson = $jsonFile.AssemblyFiles.FilesToEnable

# Search assemblies in the SolutionPath
[System.IO.FileInfo[]]$assemblyFilesToDisable
if ($assemblyFilesToDisableFromJson)
{
    [System.IO.FileInfo[]]$assemblyFilesToDisable = Get-MatchingFiles -SolutionPath "$SolutionPath" -FileNameArray $assemblyFilesToDisableFromJson -RelativeLocation "$assemblyFilesLocation"
}

[System.IO.FileInfo[]]$assemblyFilesToEnable
if ($assemblyFilesToEnableFromJson)
{
    [System.IO.FileInfo[]]$assemblyFilesToEnable = Get-MatchingFiles -SolutionPath "$SolutionPath" -FileNameArray $assemblyFilesToEnableFromJson -RelativeLocation "$assemblyFilesLocation"
}

# Concatenate FileInfo arrays
[System.IO.FileInfo[]]$filesToDisable = $configFilesToDisable + $assemblyFilesToDisable
[System.IO.FileInfo[]]$filesToEnable = $configFilesToEnable + $assemblyFilesToEnable

if ($filesToDisable.Count -gt 0)
{
    Disable-EnabledConfigFiles -FileArray $filesToDisable
}

if ($filesToEnable.Count -gt 0)
{
    Enable-DisabledConfigFiles -FileArray $filesToEnable
}