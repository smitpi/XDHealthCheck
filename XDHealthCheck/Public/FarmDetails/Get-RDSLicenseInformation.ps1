
<#PSScriptInfo

.VERSION 1.0.15

.GUID 284fb68d-acc2-4b5f-aa04-3d0fb6fbcdc0

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT 

.TAGS Citrix

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [05/05/2019_09:01]
Updated [13/05/2019_04:37]
Updated [13/05/2019_04:38]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:26]
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
<#
.SYNOPSIS
Report on RDS License Useage

.DESCRIPTION
Report on RDS License Useage

.PARAMETER LicenseServer
Name of a RDS License Server

.PARAMETER RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

.EXAMPLE
Get-RDSLicenseInformation -LicenseServer $RDSLicenseServer  -RemoteCredentials $CTXAdmin

#>
Function Get-RDSLicenseInformation {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$LicenseServer,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] RDS Details"
	$RDSLicense = Invoke-Command -ComputerName $LicenseServer -Credential $RemoteCredentials -ScriptBlock { Get-CimInstance Win32_TSLicenseKeyPack -ErrorAction SilentlyContinue | Select-Object -Property TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses }
	$CTXObject = New-Object PSObject -Property @{
		"Per Device" = $RDSLicense | Where-Object { $_.TypeAndModel -eq "RDS Per Device CAL" }
		"Per User"   = $RDSLicense | Where-Object { $_.TypeAndModel -eq "RDS Per User CAL" }
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] RDS Details"
	$CTXObject



} #end Function

