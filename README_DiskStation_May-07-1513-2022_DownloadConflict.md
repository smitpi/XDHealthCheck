# XDHealthCheck
 
## Description
Creates daily health check and config reports for your on-premise Citrix farm. To get started, you need to run Install-ParametersFile.
This will capture and save needed farm details, to allow scripts to run automatically.
 
## Getting Started
- Install from PowerShell Gallery [PS Gallery](https://www.powershellgallery.com/packages/XDHealthCheck)
```powershell=
Install-Module -Name XDHealthCheck -Verbose
```
- or from GitHub [GitHub Repo](https://github.com/smitpi/XDHealthCheck)
```powershell=
git clone https://github.com/smitpi/XDHealthCheck (Join-Path (get-item (Join-Path (Get-Item $profile).Directory 'Modules')).FullName -ChildPath XDHealthCheck)
```
- Then import the module into your session
```powershell=
Import-Module XDHealthCheck -Verbose -Force
```
- or run these commands for more help and details.
```powershell=
Get-Command -Module XDHealthCheck
Get-Help about_XDHealthCheck
```
Documentation can be found at: [Github_Pages](https://smitpi.github.io/XDHealthCheck)
 
## Functions
- [Get-CitrixConfigurationChange](https://smitpi.github.io/XDHealthCheck/#Get-CitrixConfigurationChange) -- Show the changes that was made to the farm
- [Get-CitrixFarmDetail](https://smitpi.github.io/XDHealthCheck/#Get-CitrixFarmDetail) -- Get needed Farm details.
- [Get-CitrixLicenseInformation](https://smitpi.github.io/XDHealthCheck/#Get-CitrixLicenseInformation) -- Show Citrix License details
- [Get-CitrixObjects](https://smitpi.github.io/XDHealthCheck/#Get-CitrixObjects) -- Get details of citrix objects
- [Get-CitrixServerEventLog](https://smitpi.github.io/XDHealthCheck/#Get-CitrixServerEventLog) -- Get windows event log details
- [Get-CitrixServerPerformance](https://smitpi.github.io/XDHealthCheck/#Get-CitrixServerPerformance) -- Combine perfmon of multiple servers for reporting.
- [Get-CitrixSingleServerPerformance](https://smitpi.github.io/XDHealthCheck/#Get-CitrixSingleServerPerformance) -- Get perfmon statistics
- [Get-CitrixWebsiteStatus](https://smitpi.github.io/XDHealthCheck/#Get-CitrixWebsiteStatus) -- Get the status of a website
- [Get-RDSLicenseInformation](https://smitpi.github.io/XDHealthCheck/#Get-RDSLicenseInformation) -- Report on RDS License Useage
- [Get-StoreFrontDetail](https://smitpi.github.io/XDHealthCheck/#Get-StoreFrontDetail) -- Report on Storefront status.
- [Import-ParametersFile](https://smitpi.github.io/XDHealthCheck/#Import-ParametersFile) -- Import the config file and creates the needed variables
- [Install-CTXPSModule](https://smitpi.github.io/XDHealthCheck/#Install-CTXPSModule) -- Checks and installs needed modules
- [Install-ParametersFile](https://smitpi.github.io/XDHealthCheck/#Install-ParametersFile) -- Create a json config file with all needed farm details.
- [Set-XDHealthReportColors](https://smitpi.github.io/XDHealthCheck/#Set-XDHealthReportColors) -- Set the color and logo for HTML Reports
- [Start-CitrixAudit](https://smitpi.github.io/XDHealthCheck/#Start-CitrixAudit) -- Creates and distributes  a report on catalog, groups and published app config.
- [Start-CitrixHealthCheck](https://smitpi.github.io/XDHealthCheck/#Start-CitrixHealthCheck) -- Creates and distributes  a report on citrix farm health.
