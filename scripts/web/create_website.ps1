# M. Duiker - Tahzoo
#
# This script will copy the folder ($Global:SourceFolder) and it's contents and creates a new AppPool and Website in IIS. 
#
# This script requires administrative rights.
# This script contains functions which requires PowerShell 4 (Windows 8.1 or Windows Server 2012 R2).
# If running this script is not allowed the ExecutionPolicy is probably set to Restricted.
# Execute the following command to allow running local scripts:
# Set-ExecutionPolicy RemoteSigned 


# Global variables
# These variables require to be modified for each environment. 
$Global:WebsiteHostName = 'www.project.nl'
$Global:SourceFolder = 'SourceFolder'
$Global:WebsiteName = 'ProjectName'
$Global:IISRootPath = 'c:\inetpub\wwwroot'
$Global:AppPoolName = 'ProjectName'
$Global:WebsiteFolder ='Website'

# These variables do not need to be modified for each environment.
$Global:LogToFile = "$PSScriptRoot\website_install_log.txt"
$Global:WebsiteSourcePath = "$PSScriptRoot\$Global:SourceFolder"
$Global:WebsiteTargetPath = "$Global:IISRootPath\$Global:WebsiteName"

function Log($message)
{
    $timeStamp = Get-Date -UFormat '%Y%m%d-%H:%M:%S'
    $messageWithTimeStamp = $timeStamp + ' ' + $message 
    Write-Host $messageWithTimeStamp -ForegroundColor Cyan
    if($Global:LogToFile)
    {
        Write-Output $messageWithTimeStamp | Out-File -FilePath $Global:LogToFile -Append
    }
}

function CheckPrerequisites($websiteSourcePath, $websitePhysicalPath)
{
    Import-Module WebAdministration -Force
    if (!(Test-Path $websiteSourcePath))
    {
        Log "No folder found with source files at $websiteSourcePath. Exiting..."
        Exit
    }
    if (!(Test-Path $websitePhysicalPath))
    {
        Log "Target folder not found. Expected $websitePhysicalPath. Exiting..."
        Exit
    }
}

function CreateAppPool($appPoolName)
{
    if (!(Test-Path "IIS:\AppPools\$appPoolName"))
    {
        Log "Creating IIS application pool: $appPoolName..."
        New-WebAppPool $appPoolName -Force
    }
    else
    {
        Log "Application pool $appPoolName already exists."   
    }
}

function CreateWebsite($webAppName, $physicalPath, $appPool, $hostName)
{
    if (!(Test-Path $physicalPath))
    {
        Log "Creating website directory: $physicalPath..."
        New-Item -ItemType Directory -Force -Path $physicalPath
    }
    
    if (Test-Path "$physicalPath\$Global:WebsiteFolder")
    {
        Log "$Global:WebsiteFolder exists and will be used as physical path..."
        $physicalPath = $physicalWithWebsiteFolder
    }
    
    if (!(Test-Path "IIS:\Sites\$webAppName"))
    {
        Log "Creating IIS website: $webAppName..."
        New-Website -Name $webAppName -PhysicalPath $physicalPath -ApplicationPool $appPool -HostHeader $hostName -Force
    }
    else
    {
        Log "Website $webAppName already exists."
    }
}


function CopyWebsiteFiles($sourcePath, $targetPath)
{
    # Since files/folders arre copied into an existing folder structure (the clean Sitecore installation) the -Force paramter is required.
    Log "Copying files from $sourcePath to $targetPath"
    Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Container -Force
}

function Main()
{
    Log 'Start install'
    CheckPrerequisites "$Global:WebsiteSourcePath" "$Global:WebsiteTargetPath"
    CopyWebsiteFiles "$Global:WebsiteSourcePath" $Global:IISRootPath
    CreateAppPool $Global:AppPoolName
    CreateWebsite $Global:WebsiteName "$Global:WebsiteTargetPath" $Global:AppPoolName $Global:WebsiteHostName
    Log 'Install complete'
}

# Start
Main