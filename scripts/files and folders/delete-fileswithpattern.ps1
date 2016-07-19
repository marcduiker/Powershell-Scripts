<#
    This script searches for files mathing the $RegexPattern and deletes them from the $SolutionPath.

    Example to remove Synthesis.Startup.config and Synthesis.ControlPanel.config from a build location:

    .\delete-files-with-pattern.ps1 "C:\Build\ProjectA\" @('Synthesis.Startup.config','Synthesis.ControlPanel.config')
#>

Param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$SolutionPath,
    [Parameter(Position=1, Mandatory=$true)]
    [string[]]$FilesToRemoveArray
)

# Convert the array to a pipe delimited string so it can be used as regex search pattern.
$regexSearchPattern = $FilesToRemoveArray -join '|'

Write-Output "INFO: Search pattern: $regexSearchPattern"

$filesToDelete = Get-ChildItem -File -Path "$SolutionPath" -Recurse | Where-Object { $_.Name -match "$regexSearchPattern" }

foreach ($fileToDelete in $filesToDelete)
{
   $fullPath = $fileToDelete.FullName
   Write-Output "INFO: Deleting $fullPath"
   Remove-Item $fullPath -Force
}

