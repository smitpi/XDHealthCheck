# XDHealthCheck
 
## Description
Creates daily health check and config reports for your on-premise Citrix farm. To get started, you need to run Install-ParametersFile.
This will capture and save needed farm details, to allow scripts to run automatically.
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/XDHealthCheck)
```
Install-Module -Name XDHealthCheck -Verbose
```
- or run this script to install from GitHub [GitHub Repo](https://github.com/smitpi/XDHealthCheck)
```
$CurrentLocation = Get-Item .
$ModuleDestination = (Join-Path (Get-Item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath XDHealthCheck)
git clone --depth 1 https://github.com/smitpi/XDHealthCheck $ModuleDestination 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $ModuleDestination
git filter-branch --prune-empty --subdirectory-filter Output HEAD 2>&1 | Write-Host -ForegroundColor Yellow
Set-Location $CurrentLocation
```
- Then import the module into your session
```
Import-Module XDHealthCheck -Verbose -Force
```
- or run these commands for more help and details.
```
Get-Command -Module XDHealthCheck
Get-Help about_XDHealthCheck
```
Documentation can be found at: [Github_Pages](https://smitpi.github.io/XDHealthCheck)
