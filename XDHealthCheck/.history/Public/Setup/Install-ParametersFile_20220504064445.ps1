
<#PSScriptInfo

.VERSION 1.0.5

.GUID 7703f542-0274-4653-b61f-b5ee32980012

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
Created [01/07/2020_14:43] Initital Script Creating
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
Create a json config file with all needed farm details.

.DESCRIPTION
Create a json config file with all needed farm details.

.EXAMPLE
Install-ParametersFile

#>
function Install-ParametersFile {
	[Cmdletbinding()]
	param ()

	[string]$CTXDDC = Read-Host 'A Citrix Data Collector FQDN'
	$CTXStoreFront = @()
	$ClientInput = ''
	While ($ClientInput -ne 'n') {
		
		$CTXStoreFront += $CusObject
			$ClientInput = Read-Host 'Add more trusted domains? (y/n)'
		}
	}
	[string]$CTXStoreFront = Read-Host 'A Citrix StoreFront FQDN'
	[string]$RDSLicenseServer = Read-Host 'RDS LicenseServer FQDN'

	Write-Color -Text 'Add RDS License Type' -Color DarkGray -LinesAfter 1
	Write-Color '1: ', 'Per Device' -Color Yellow, Green
	Write-Color '2: ', 'Per User' -Color Yellow, Green
	$selection = Read-Host 'Please make a selection'
	switch ($selection) {
		'1' { [string]$RDSLicenseType = 'Per Device' }
		'2' { [string]$RDSLicenseType = 'Per User' }
	}
	$trusteddomains = @()
	$ClientInput = ''
	While ($ClientInput -ne 'n') {
		If ($null -ne $ClientInput) {
			$FQDN = Read-Host 'FQDN for the domain'
			$NetBiosName = Read-Host 'Net Bios Name for Domain '
			$CusObject = New-Object PSObject -Property @{
				FQDN        = $FQDN
				NetBiosName = $NetBiosName
				Description = $NetBiosName + '_ServiceAccount'
			} | Select-Object FQDN, NetBiosName, Description
			$trusteddomains += $CusObject
			$ClientInput = Read-Host 'Add more trusted domains? (y/n)'
		}
	}

	$ReportsFolder = Read-Host 'Path to the Reports Folder'
	$ParametersFolder = Read-Host 'Path to where the Parameters.json will be saved'
	$DashboardTitle = Read-Host 'Title to be used in the reports and Dashboard'
	$RemoveOldReports = Read-Host 'Remove Reports older than (in days)'

	Write-Color -Text 'Save reports to an excel report' -Color DarkGray -LinesAfter 1
	Write-Color '1: ', 'Yes' -Color Yellow, Green
	Write-Color '2: ', 'No' -Color Yellow, Green
	$selection = Read-Host 'Please make a selection'
	switch ($selection) {
		'1' { $SaveExcelReport = $true }
		'2' { $SaveExcelReport = $false }
	}

	Write-Color -Text 'Send Report via email' -Color DarkGray -LinesAfter 1
	Write-Color '1: ', 'Yes' -Color Yellow, Green
	Write-Color '2: ', 'No' -Color Yellow, Green
	$selection = Read-Host 'Please make a selection'
	switch ($selection) {
		'1' { $SendEmail = $true }
		'2' { $SendEmail = $false }
	}

	if ($SendEmail -eq 'true') {
		$emailFromA = Read-Host 'Email Address of the Sender'
		$emailFromN = Read-Host 'Full Name of the Sender'
		$FromAddress = $emailFromN + ' <' + $emailFromA + '>'

		$ToAddress = @()
		$ClientInput = ''
		While ($ClientInput -ne 'n') {
			If ($null -ne $ClientInput) {
				$emailtoA = Read-Host 'Email Address of the Recipient'
				$emailtoN = Read-Host 'Full Name of the Recipient'
				$ToAddress += $emailtoN + ' <' + $emailtoA + '>'
			}
			$ClientInput = Read-Host 'Add more recipients? (y/n)'
		}

		$smtpServer = Read-Host 'IP or name of SMTP server'
		$smtpServerPort = Read-Host 'Port of SMTP server'
		Write-Color -Text 'Use ssl for SMTP' -Color DarkGray -LinesAfter 1
		Write-Color '1: ', 'Yes' -Color Yellow, Green
		Write-Color '2: ', 'No' -Color Yellow, Green
		$selection = Read-Host 'Please make a selection'
		switch ($selection) {
			'1' { $smtpEnableSSL = $true }
			'2' { $smtpEnableSSL = $false }
		}
	}
	$AllXDData = New-Object PSObject -Property @{
		DateCollected    = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		CTXDDC           = $CTXDDC
		CTXStoreFront    = $CTXStoreFront
		RDSLicenseServer = $RDSLicenseServer
		RDSLicenseType   = $RDSLicenseType
		TrustedDomains   = $trusteddomains
		ReportsFolder    = $ReportsFolder
		ParametersFolder = $ParametersFolder
		DashboardTitle   = $DashboardTitle
		RemoveOldReports = $RemoveOldReports
		SaveExcelReport  = $SaveExcelReport
		SendEmail        = $SendEmail
		EmailFrom        = $FromAddress
		EmailTo          = $ToAddress
		SMTPServer       = $smtpServer
		SMTPServerPort   = $smtpServerPort
		SMTPEnableSSL    = $smtpEnableSSL
	} | Select-Object DateCollected, CTXDDC , CTXStoreFront , RDSLicenseServer , RDSLicenseType, TrustedDomains , ReportsFolder , ParametersFolder , DashboardTitle, RemoveOldReports, SaveExcelReport , SendEmail , EmailFrom , EmailTo , SMTPServer , SMTPServerPort , SMTPEnableSSL

	if (Test-Path -Path "$ParametersFolder\Parameters.json") { Rename-Item "$ParametersFolder\Parameters.json" -NewName "Parameters_$(Get-Date -Format ddMMyyyy_HHmm).json" }
	else { $AllXDData | ConvertTo-Json -Depth 5 | Out-File -FilePath "$ParametersFolder\Parameters.json" -Force -Verbose }

	Import-ParametersFile -JSONParameterFilePath "$ParametersFolder\Parameters.json"

}



