# XDHealthCheck
## about_XDHealthCheck

# SHORT DESCRIPTION
Creates daily health check, and config reports for your on-premise Citrix farm. 

# LONG DESCRIPTION
Creates daily health check, and config reports for your on-premise Citrix farm. 
- To get started, you need to run Install-ParametersFile. 
- This will capture and save needed farm details, to allow scripts to run automatically.

# NOTES
Get-CitrixConfigurationChange -- Show the changes that was made to the farm
Get-CitrixFarmDetail -- Get needed Farm details.
Get-CitrixLicenseInformation -- Show Citrix License details
Get-CitrixObjects -- Get details of citrix objects
Get-CitrixServerEventLog -- Get windows event log details
Get-CitrixServerPerformance -- Combine perfmon of multiple servers for reporting.
Get-CitrixSingleServerPerformance -- Get perfmon statistics
Get-CitrixWebsiteStatus -- Get the status of a website
Get-RDSLicenseInformation -- Report on RDS License Useage
Get-StoreFrontDetail -- Report on Storefront status.
Import-ParametersFile -- Import the config file and creates the needed variables
Install-CTXPSModule -- Checks and installs needed modules
Install-ParametersFile -- Create a json config file with all needed farm details.
Set-XDHealthReportColors -- Set the color and logo for HTML Reports
Start-CitrixAudit -- Creates and distributes  a report on catalog, groups and published app config.
Start-CitrixHealthCheck -- Creates and distributes  a report on citrix farm health.


# SEE ALSO
https://github.com/smitpi/XDHealthCheck
https://smitpi.github.io/XDHealthCheck/
