
<#PSScriptInfo

.VERSION 1.0.13

.GUID eeec293e-564f-4b3e-a252-74b1e96493df

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
Created [05/05/2019_09:00]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:25]
Updated [09/06/2019_09:18]
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


Function Get-CitrixWebsiteStatus {
<#
.SYNOPSIS
Get the status of a website

.DESCRIPTION
Get the status of a website

.PARAMETER Websitelist
List of websites to check

.EXAMPLE
Get-CitrixWebsiteStatus -Websitelist 'https://store.example.com'

#>
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[array]$Websitelist)

	$websites = @()
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Website Details"

	foreach ($web in $Websitelist) {
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		$WebResponse = Invoke-WebRequest -Uri $web -UseBasicParsing | Select-Object -Property StatusCode, StatusDescription

		$CTXObject = New-Object PSObject -Property @{
			"WebSite Name"    = $web
			StatusCode        = $WebResponse.StatusCode
			StatusDescription = $WebResponse.StatusDescription
		}
		$websites += $CTXObject
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Website Details"

	$websites | Select-Object  "WebSite Name" , StatusCode, StatusDescription



} #end Function

