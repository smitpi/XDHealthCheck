
<#PSScriptInfo

.VERSION 1.0.8

.GUID a90021c2-9c0b-462b-a0c2-5bffaadab328

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT 

.TAGS Citrix

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [09/06/2019_12:53]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports
Updated [01/07/2020_14:43] Script Fle Info was updated
Updated [01/07/2020_15:42] Script Fle Info was updated
Updated [01/07/2020_16:07] Script Fle Info was updated
Updated [01/07/2020_16:13] Script Fle Info was updated
Updated [06/03/2021_20:58] Script Fle Info was updated
Updated [15/03/2021_23:28] Script Fle Info was updated

#> 

















<#

.DESCRIPTION 
Function for Citrix XenDesktop HTML Health Check Report

#>


# .ExternalHelp  XDHealthCheck-help.xml


Function Get-CitrixServerPerformance {
<#
.SYNOPSIS
Combine perfmon of multiple servers for reporting.

.DESCRIPTION
Combine perfmon of multiple servers for reporting.

.PARAMETER Serverlist
List of servers to get the permon details

.PARAMETER RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

.EXAMPLE
Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin
#>	
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[array]$Serverlist,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)

	$CitrixServerPerformance = @()
	foreach ($Server in $Serverlist) {
		$SingleServer = Get-CitrixSingleServerPerformance -Server $Server -RemoteCredentials $RemoteCredentials
		$CusObject = New-Object PSObject -Property @{
			DateCollected      = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			Servername         = $SingleServer.ServerName
			'CPU %'            = $SingleServer.'CPU %'
			'Memory %'         = $SingleServer.'Memory %'
			'CDrive % Free'    = $SingleServer.'CDrive % Free'
			'DDrive % Free'    = $SingleServer.'DDrive % Free'
			Uptime             = $SingleServer.Uptime
			'Stopped Services' = $SingleServer.StoppedServices
		} | Select-Object ServerName, 'CPU %', 'Memory %', 'CDrive % Free', 'DDrive % Free', Uptime, 'Stopped Services'
		$CitrixServerPerformance += $CusObject
	}

	$CitrixServerPerformance
} #end Function

