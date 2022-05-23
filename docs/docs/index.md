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
- [Get-CitrixConnectionFailures](https://smitpi.github.io/XDHealthCheck/#Get-CitrixConnectionFailures) -- Creates a report from monitoring data about machine and connection failures
- [Get-CitrixEnvTestResults](https://smitpi.github.io/XDHealthCheck/#Get-CitrixEnvTestResults) -- Perform and report on tests on catalogs, delivery groups, hypervisor and Infrastructure
- [Get-CitrixFarmDetail](https://smitpi.github.io/XDHealthCheck/#Get-CitrixFarmDetail) -- Get needed Farm details.
- [Get-CitrixLicenseInformation](https://smitpi.github.io/XDHealthCheck/#Get-CitrixLicenseInformation) -- Show Citrix License details
- [Get-CitrixMonitoringData](https://smitpi.github.io/XDHealthCheck/#Get-CitrixMonitoringData) -- Connects and collects data from the monitoring OData feed.
- [Get-CitrixObjects](https://smitpi.github.io/XDHealthCheck/#Get-CitrixObjects) -- Get details of citrix objects
- [Get-CitrixResourceUtilizationSummary](https://smitpi.github.io/XDHealthCheck/#Get-CitrixResourceUtilizationSummary) -- Resource Utilization Summary for machines
- [Get-CitrixServerEventLog](https://smitpi.github.io/XDHealthCheck/#Get-CitrixServerEventLog) -- Get windows event log details
- [Get-CitrixServerPerformance](https://smitpi.github.io/XDHealthCheck/#Get-CitrixServerPerformance) -- Collects perform data for the core servers.
- [Get-CitrixSessionIcaRtt](https://smitpi.github.io/XDHealthCheck/#Get-CitrixSessionIcaRtt) -- Creates a report of users sessions with a AVG IcaRttMS
- [Get-CitrixVDAUptime](https://smitpi.github.io/XDHealthCheck/#Get-CitrixVDAUptime) -- Calculate the uptime of VDA Servers.
- [Get-CitrixWorkspaceAppVersions](https://smitpi.github.io/XDHealthCheck/#Get-CitrixWorkspaceAppVersions) -- Reports on the versions of workspace app your users are using to connect
- [Get-RDSLicenseInformation](https://smitpi.github.io/XDHealthCheck/#Get-RDSLicenseInformation) -- Report on RDS License Usage
- [Import-ParametersFile](https://smitpi.github.io/XDHealthCheck/#Import-ParametersFile) -- Import the config file and creates the needed variables
- [Install-ParametersFile](https://smitpi.github.io/XDHealthCheck/#Install-ParametersFile) -- Create a json config file with all needed farm details.
- [Set-XDHealthReportColors](https://smitpi.github.io/XDHealthCheck/#Set-XDHealthReportColors) -- Set the color and logo for HTML Reports
- [Start-CitrixAudit](https://smitpi.github.io/XDHealthCheck/#Start-CitrixAudit) -- Creates and distributes  a report on Catalog, groups and published app config.
- [Start-CitrixHealthCheck](https://smitpi.github.io/XDHealthCheck/#Start-CitrixHealthCheck) -- Creates and distributes  a report on citrix farm health.
