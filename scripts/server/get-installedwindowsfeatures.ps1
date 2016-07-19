Import-Module servermanager

Get-WindowsFeature | Where-Object { $_.Installed -eq $true }