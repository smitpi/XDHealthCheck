
<#PSScriptInfo

.VERSION 1.0.13

.GUID 7a62533c-d105-4718-9440-00957643908f

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
Updated [24/05/2019_19:24]
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

Param()



Function Get-CitrixLicenseInformation {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials,
		[Parameter(Mandatory = $false, Position = 2)]
		[switch]$RunAsPSRemote = $false)


	function get-license {
		param($AdminServer, $VerbosePreference)
		Add-PSSnapin Citrix*
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] License Details"

		$LicenseServer = Get-BrokerSite -AdminAddress $AdminServer | Select-Object LicenseServerName
		[string]$licurl = "https://" + $LicenseServer.LicenseServerName + ":8083"
		$cert = Get-LicCertificate -AdminAddress $licurl
		$ctxlic = Get-LicInventory -AdminAddress $licurl -CertHash $cert.CertHash | Where-Object { $_.LicensesInUse -ne 0 }
		$AllDetails = @()
		foreach ($lic in $ctxlic) {
			$Licenses = New-Object PSObject -Property @{
				LicenseProductName = $lic.LocalizedLicenseProductName
				LicenseModel       = $lic.LocalizedLicenseModel
				LicensesInstalled  = $lic.LicensesAvailable
				LicensesInUse      = $lic.LicensesInUse
				LicensesAvailable  = ([int]$lic.LicensesAvailable - [int]$lic.LicensesInUse)
			} | Select-Object LicenseProductName, LicenseModel, LicensesInstalled, LicensesInUse, LicensesAvailable
			$AllDetails += $Licenses
		}
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [End] License Details"
			$AllDetails
		}

	$LicDetails = @()
	if ($RunAsPSRemote -eq $true) { $LicDetails = Invoke-Command -ComputerName $AdminServer -ScriptBlock ${Function:get-license} -ArgumentList @($AdminServer, $VerbosePreference) -Credential $RemoteCredentials }
	else { $LicDetails = get-license -AdminAddress $AdminServer }
	$LicDetails | Select-Object LicenseProductName, LicenseModel, LicensesInstalled, LicensesInUse, LicensesAvailable


} #end Function

