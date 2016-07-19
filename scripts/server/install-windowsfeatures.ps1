Param(
    ## Either a PATH to a file in which each line contains one feature name i.e.
    ##
    ## Windows-TIFF-IFilter
    ## XPS-Viewer
    ##
    ## or a STRING of comma separated feature names
    ##
    [Parameter(Position=1, Mandatory=$True)]
    [string] $Features
)

$featuresToInstall = $null

Import-Module ServerManager

if(Test-Path $Features)
{
    $featuresToInstall = $(Get-Content $Features)
}
else
{
    $featuresToInstall = $Features.Split(',')
}

foreach ($featureToInstall in $featuresToInstall)
{
    $feature = (Get-WindowsFeature $featureToInstall)
    if (($feature) -and (!$feature.Installed))
    {
        Install-WindowsFeature $featureToInstall
    }
}