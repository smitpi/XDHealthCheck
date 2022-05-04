
<#PSScriptInfo

.VERSION 0.1.0

.GUID 3b2c53b1-a6b7-4de5-9f07-1d0a35df166e

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT 

.TAGS ctx

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [03/05/2022_18:50] Initial Script Creating

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Connects and collects data from the monitoring OData feed. 

#> 


<#
.SYNOPSIS
Connects and collects data from the monitoring OData feed.

.DESCRIPTION
Connects and collects data from the monitoring OData feed.

.EXAMPLE
Get-CitrixMonitoringData

#>
<#
.SYNOPSIS
Connects and collects data from the monitoring OData feed.

.DESCRIPTION
Connects and collects data from the monitoring OData feed.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER hours
Limit the report to this time frame

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-CitrixMonitoringData {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/XDHealthCheck/Get-CitrixMonitoringData")]
	    [OutputType([System.Object[]])]
                PARAM(
                    [Parameter(Mandatory = $true)]
                    [ValidateNotNull()]
                    [ValidateNotNullOrEmpty()]
                    [string]$AdminServer,
                    [Parameter(Mandatory = $true)]
                    [ValidateNotNull()]
                    [ValidateNotNullOrEmpty()]
                    [int32]$hours
				)

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Monitoring data connect"


	$now = Get-Date -Format yyyy-MM-ddTHH:mm:ss
	$past = ((Get-Date).AddHours(-$hours)).ToString('yyyy-MM-ddTHH:mm:ss')

	$urisettings = @{
		#AllowUnencryptedAuthentication = $true
		UseDefaultCredentials = $true
	}
$ChechOdataVer = (Invoke-WebRequest -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data" -UseDefaultCredentials).headers['OData-Version']

if ($ChechOdataVer -like "4*"){
[pscustomobject]@{
        Sessions = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/Sessions?$filter = StartDate ge datetime`'$($past)`' and StartDate le datetime`'$($now)`'" @urisettings ).value
        Connections = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/Connections?$filter = StartDate ge datetime`'$($past)`' and StartDate le datetime`'$($now)`'" @urisettings ).value
        ConnectionFailureLogs = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/ConnectionFailureLogs?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'" @urisettings ).value
        MachineFailureLogs = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/MachineFailureLogs?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'" @urisettings ).value
        Users = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/Users" @urisettings ).value
        Machines = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/Machines" @urisettings ).value
        Catalogs = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/Catalogs" @urisettings ).value
        Applications = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/Applications" @urisettings ).value
        DesktopGroups = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/DesktopGroups" @urisettings ).value
        ResourceUtilization = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/ResourceUtilization?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'" @urisettings ).value
        ResourceUtilizationSummary = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/ResourceUtilizationSummary?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'" @urisettings ).value
        SessionMetrics = (Invoke-RestMethod -Uri "http://$($AdminAdddessss)/Citrix/Monitor/OData/v4/Data/SessionMetrics?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'" @urisettings ).value
}
} else { Write-Error "OData version to old, update the farm to a newer version."}

} #end Function
