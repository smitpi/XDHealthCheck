## Description
Creates daily health check and config reports for your on-premise Citrix farm. To get started, you need to run Install-ParametersFile.
This will capture and save needed farm details, to allow scripts to run automatically.

## Getting Started
- `Install-Module -Name XDHealthCheck -Verbose`
- `Import-Module XDHealthCheck -Verbose -Force`
- `Get-Command -Module XDHealthCheck`

## Functions
- [Get-CitrixConfigurationChange](Get-CitrixConfigurationChange.md) -- Show the changes that was made to the farm
- [Get-CitrixFarmDetail](Get-CitrixFarmDetail.md) -- Get needed Farm details.
- [Get-CitrixLicenseInformation](Get-CitrixLicenseInformation.md) -- Show Citrix License details
- [Get-CitrixObjects](Get-CitrixObjects.md) -- Get details of citrix objects
- [Get-CitrixServerEventLog](Get-CitrixServerEventLog.md) -- Get windows event log details
- [Get-CitrixServerPerformance](Get-CitrixServerPerformance.md) -- Combine perfmon of multiple servers for reporting.
- [Get-CitrixSingleServerPerformance](Get-CitrixSingleServerPerformance.md) -- Get perfmon statistics
- [Get-CitrixWebsiteStatus](Get-CitrixWebsiteStatus.md) -- Get the status of a website
- [Get-RDSLicenseInformation](Get-RDSLicenseInformation.md) -- Report on RDS License Useage
- [Get-StoreFrontDetail](Get-StoreFrontDetail.md) -- Report on Storefront status.
- [Import-ParametersFile](Import-ParametersFile.md) -- Import the config file and creates the needed variables
- [Install-CTXPSModule](Install-CTXPSModule.md) -- Checks and installs needed modules
- [Install-ParametersFile](Install-ParametersFile.md) -- Create a json config file with all needed farm details.
- [Set-XDHealthReportColors](Set-XDHealthReportColors.md) -- Set the color and logo for HTML Reports
- [Start-CitrixAudit](Start-CitrixAudit.md) -- Creates and distributes  a report on catalog, groups and published app config.
- [Start-CitrixHealthCheck](Start-CitrixHealthCheck.md) -- Creates and distributes  a report on citrix farm health.


