# 2015/07/15 Dennis de Laat
# This script walks through the solution folder recursively and transforms every .config file. After that
# it will remove the transformation config files.

param([String]$environment="accept", [String]$solutionDir="C:\temp\Working")

Write-Output "Environment: $environment"

clear
Push-Location $PSScriptRoot

Write-Output "PSScriptRoot: $PSScriptRoot"

function ProcessFiles($path)
{
    Write-Output "ProcessFiles path: $path"

    foreach ($item in Get-ChildItem $path)
    {
        if (Where {$item -like $_}) { continue }

        if ($item.FullName.EndsWith("config"))
        {
            if ($item.Name.contains("$environment.config"))
            {
                $sourceFile = $item.FullName.Replace("$environment.config", "config")
                $destinationName = $item.Name.Replace("$environment.config", "config")
                $transformFile = $item.FullName
                $basePattern = $item.Name.Split(".")[0]

                # Transform
                Start-Process -FilePath "$pwd\ctt.exe" -ArgumentList "s:$sourceFile t:$transformFile d:$sourceFile" -NoNewWindow -Wait
                Write-Output "Transformed file $transformFile to $sourceFile"

                # Remove not needed transformation files
                $currentDir = Split-Path $item.FullName
                foreach ($config in Get-ChildItem $currentDir -Filter $basePattern*.config)
                {
                    if (!$config.Name.Equals($destinationName))
                    {
                        Remove-Item $config.FullName
                        Write-Output "Delete file $config.FullName"
                    }
                }
            }
        }

        # Recursively through directories
        if (Test-Path $item.FullName -PathType Container)
        {
            ProcessFiles $item.FullName
        }
    }
} 

ProcessFiles $solutionDir