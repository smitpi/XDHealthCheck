
<#PSScriptInfo

.VERSION 1.0.10

.GUID 284fb68d-acc2-4b5f-aa04-3d0fb6fbcdc0

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

.PRIVATEDATA

#> 





















<#

.DESCRIPTION 
Xendesktop Farm Details

#>

Param()



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

