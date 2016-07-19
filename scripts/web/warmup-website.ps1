<#
    This script performs a webrequest to a website to warm it up.
#>

Param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$SiteUrl,
    [Parameter(Position=1)]
    [int]$TimeOutInSeconds = 600
)

Invoke-WebRequest -Uri $SiteUrl -TimeoutSec $TimeOutInSeconds -UseBasicParsing