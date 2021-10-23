---
Module Name: XDHealthCheck
Module Guid: 39f9295c-353e-4bb7-aee5-0c600dfd5eba
Download Help Link: NA
Help Version: 0.2.6
Locale: en-US
---

# XDHealthCheck Module
## Description
Creates daily health check, and config reports for your on premise Citrix farm. 
- To get started, you need to run Install-ParametersFile. 
- This will capture and save needed farm details, to allow scripts to run automatically.

HTML Reports
- When creating a HTML report:
- The logo can be changed by replacing the variable 
 - $Global:Logourl =''
- The colors of the report can be changed, by replacing:
 - $global:colour1 = "#061820"
 - $global:colour2 = "#FFD400"
- Or permanently replace it by editing the following file
- <Module base>\Private\Reports-Variables.ps1

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
Combine perfmon of multiple servers for reporting.

### [Get-CitrixSingleServerPerformance](Get-CitrixSingleServerPerformance.md)
Get perfmon statistics

### [Get-CitrixWebsiteStatus](Get-CitrixWebsiteStatus.md)
Get the status of a website

### [Get-RDSLicenseInformation](Get-RDSLicenseInformation.md)
Report on RDS License Usage

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

