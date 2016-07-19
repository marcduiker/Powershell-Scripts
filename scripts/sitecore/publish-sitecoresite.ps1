<#
    This function publishes Sitecore content, layout and templates for the given $SiteUrl.
    Valid values for the optional $PublishMode argument are 'full', 'smart' and 'incremental'.
    If $PublishMode is empty it will default to 'smart'.
    If $TimeOutInSeconds is empty it will default to 900.

    Example usage:
    .\publish-sitecore-site.ps1 www.site.com incremental
#>

Param(
        [Parameter(Position=0, Mandatory=$true)]
        [string] $SiteUrl,
        [Parameter(Position=1)]
        [ValidateSet('full', 'smart', 'incremental')]
        [string] $PublishMode = 'smart',
        [Parameter(Position=2)]
        [string[]] $Languages = @('en'),
        [Parameter(Position=3)]
        [ValidateRange(0, 9999999)]
        [int] $ConnectionTimeOutInSeconds = 300,
        [Parameter(Position=4)]
        [ValidateRange(0, 9999999)]
        [int] $MaxTimeOutInSeconds = 900
    )


$urlWithPublishMode = "$SiteUrl/services/publish/$PublishMode"
$curlPath = .\get-curlpath.ps1
$curlCommand= "$curlPath --show-error --silent --connect-timeout $ConnectionTimeOutInSeconds --max-time $MaxTimeOutInSeconds --form ""languages=@(en)"" $urlWithPublishMode"

Write-Output "INFO: Starting Invoke-Expression: $curlCommand"

Invoke-Expression $curlCommand