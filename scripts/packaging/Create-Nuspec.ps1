function Update-NuspecValues
{
    [cmdletbinding()]    
    param(
        [xml]$Nuspec,
        [string]$PackageId,
        [string]$Version,
        [string]$Title,
        [string]$Authors,
        [string]$Owners,
        [bool]$RequireLicenseAcceptance = $false,
        [string]$Description,
        [string]$Language = "en-US",
        [string]$Tags
    )

    $Nuspec.package.metadata.id = $PackageId
    $Nuspec.package.metadata.version = $Version
    $Nuspec.package.metadata.title = $Title
    $Nuspec.package.metadata.authors = $Authors
    $Nuspec.package.metadata.owners = $Owners
    $Nuspec.package.metadata.requireLicenseAcceptance = [string]$RequireLicenseAcceptance
    $Nuspec.package.metadata.description = $Description
    $Nuspec.package.metadata.language = $Language
    $Nuspec.package.metadata.tags = $Tags

    $Nuspec
}

function Find-Files
{
    [cmdletbinding()]
    param(
        [string]$Path,
        [string]$Pattern
    )

    Get-ChildItem -Path "$path" -File -Filter "$pattern" | Where-Object { $_.Name.ToLower().EndsWith("dll") }
}

fucntion Create-FolderStructure
{
    [cmdletbinding()]
    param(
        [string]$TargetPath
    )

    $relsFolder = New-Item -Path "$TargetPath" -Name "_rels" -ItemType "directory"
    $libFolder = New-Item -Path "$TargetPath" -Name "lib" -ItemType "directory"
    $packageFolder = New-Item -Path "$TargetPath" -Name "package" -ItemType "directory"
    $servicesFolder = New-Item -Path "$packageFolder" -Name "services" -ItemType "directory"
    $metadataFolder = New-Item -Path "$servicesFolder" -Name "metadata" -ItemType "directory"
    $corePropertiesFolder = New-Item -Path "$metadataFolder" -Name "core-properties" -ItemType "directory"

    # Get content for [UID].psmdcp file
    $psmdcpValue = null # TODO
    
    # Generate GUID without hyphens
    $guid = [guid]::NewGuid().ToString("N")
     New-Item -Path "$corePropertiesFolder" -Name "$guid.psmdcp" -ItemType "file" -Value psmdcpValue

    # Files to add in the root of the package
    $contentTypesValue = @"
<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml" /><Default Extension="nuspec" ContentType="application/octet" /><Default Extension="dll" ContentType="application/octet" /><Default Extension="psmdcp" ContentType="application/vnd.openxmlformats-package.core-properties+xml" /></Types>
"@
    
    New-Item -Path "$TargetPath" -Name "[Content_Types].xml" -ItemType "file" -Value $contentTypesValue
    
    # Get content for nuspec
    # Create the nuspec

}

$nuspecTemplate = @"
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
    <metadata>
        <id></id>
        <version></version>
        <title></title>
        <authors></authors>
        <owners></owners>
        <requireLicenseAcceptance>false</requireLicenseAcceptance>
        <description></description>
        <summary></summary>
        <language>en-US</language>
        <tags></tags>
        <dependencies />
    </metadata>
</package>
"@

[xml]$nuspecXml = $nuspecTemplate

# Read config

# Determine the Version

# Iterate through the assemblies to create the nuspec files

Find-Files -Path "c:\dev\sitecore\instances\sc81rev160302\Website\bin" -Pattern "Sitecore*" 

#$updatedNuspec = Update-NuspecValues -Nuspec $nuspecXml -PackageId "Sitecore.Kernel"