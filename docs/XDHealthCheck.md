---
Module Name: XDHealthCheck
Module Guid: 39f9295c-353e-4bb7-aee5-0c600dfd5eba
Download Help Link: 
Help Version: 0.2.4
Locale: en-US
---

# XDHealthCheck Module
## Description
Creates daily health check, and config reports for your on premise Citrix farm. 
 - To get started, you need to run Install-ParametersFile. 
 - This will capture and save needed farm details, to allow scripts to run automatically.

## XDHealthCheck Cmdlets
### [Get-CitrixConfigurationChange](Get-CitrixConfigurationChange.md)
Show the changes that was made to the farm

### [Get-CitrixFarmDetail](Get-CitrixFarmDetail.md)
Get needed Farm details.

### [Get-CitrixLicenseInformation](Get-CitrixLicenseInformation.md)
Show Citrix License details

### [Get-CitrixObjects](Get-CitrixObjects.md)
Get details about catalogs, delivery groups and published apps

### [Get-CitrixServerEventLog](Get-CitrixServerEventLog.md)
Get windows event log details

### [Get-CitrixServerPerformance](Get-CitrixServerPerformance.md)
Show perfmon stats

### [Get-CitrixSingleServerPerformance](Get-CitrixSingleServerPerformance.md)
Get perfmon detail

### [Get-CitrixWebsiteStatus](Get-CitrixWebsiteStatus.md)
Report on Website Status

### [Get-RDSLicenseInformation](Get-RDSLicenseInformation.md)
Report on RDS Licenses

### [Get-StoreFrontDetail](Get-StoreFrontDetail.md)
Report on StoreFront Status

### [Import-ParametersFile](Import-ParametersFile.md)
Import the config file and creates the needed variables

### [Install-CTXPSModule](Install-CTXPSModule.md)
Checks and installs needed modules

### [Install-ParametersFile](Install-ParametersFile.md)
Create a json config with all needed farm details.

### [Start-CitrixAudit](Start-CitrixAudit.md)
Creates and distributes  a report on catalog, groups and published app config.

### [Start-CitrixHealthCheck](Start-CitrixHealthCheck.md)
Creates and distributes  a report on citrix farm health.

