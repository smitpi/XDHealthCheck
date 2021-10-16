
<#PSScriptInfo

.VERSION 1.0.5

.GUID 7703f542-0274-4653-b61f-b5ee32980012

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
# .ExternalHelp  XDHealthCheck-help.xml

function Install-ParametersFile {

try {
	$wc = New-Object System.Net.WebClient 
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials 
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

	Install-PackageProvider Nuget -Force
	#Register-PSRepository -Default -Verbose
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
	Write-Host 'PSGalary:' -ForegroundColor Cyan -NoNewline
	Write-Host "Succsessfull" -ForegroundColor Yellow
}catch {Write-Error "Unable to setup PSGallery "}
finally {Write-Error "Unable to setup PSGallery"}

Install-BasePSModules

		[string]$CTXDDC = Read-Host 'A Citrix Data Collector FQDN'
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
		$input = ''
		While ($input -ne 'n') {
			If ($input -ne $null) {
				$FQDN = Read-Host 'FQDN for the domain'
				$NetBiosName = Read-Host 'Net Bios Name for Domain '
				$CusObject = New-Object PSObject -Property @{
					FQDN        = $FQDN
					NetBiosName = $NetBiosName
					Description = $NetBiosName + '_ServiceAccount'
				} | Select-Object FQDN, NetBiosName, Description
				$trusteddomains += $CusObject
				$input = Read-Host 'Add more trusted domains? (y/n)'
			}
		}
<#
		$CTXNS = @()
		$input = ''
		While ($input -ne 'n') {
			If ($input -ne $null) {
				$CusObject = New-Object PSObject -Property @{
					NSIP    = Read-Host 'Netscaler IP (Management)'
					NSAdmin = Read-Host 'Root Username'
				} | Select-Object NSIP, NSAdmin
				$CTXNS += $CusObject
				$input = Read-Host 'Add more Netscalers? (y/n)'
			}
		}#>
		$ReportsFolder = Read-Host 'Path to the Reports Folder'
		$ParametersFolder = Read-Host 'Path to where the Parameters.json will be saved'
		$DashboardTitle = Read-Host 'Title to be used in the reports and Dashboard'

		[System.Collections.ArrayList]$rbgcolor = @('AliceBlue', 'AntiqueWhite', 'Aqua', 'Aquamarine', 'Azure', 'Beige', 'Bisque', 'Black', 'BlanchedAlmond', 'Blue', 'BlueViolet', 'Brown', 'BurlyWood', 'CadetBlue', 'Chartreuse', 'Chocolate', 'Coral', 'CornflowerBlue', 'Cornsilk', 'Crimson', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGoldenrod', 'DarkGray', 'DarkGreen', 'DarkGrey', 'DarkKhaki', 'DarkMagenta', 'DarkOliveGreen', 'DarkOrange', 'DarkOrchid', 'DarkRed', 'DarkSalmon', 'DarkSeaGreen', 'DarkSlateBlue', 'DarkSlateGray', 'DarkSlateGrey', 'DarkTurquoise', 'DarkViolet', 'DeepPink', 'DeepSkyBlue', 'DimGray', 'DimGrey', 'DodgerBlue', 'FireBrick', 'FloralWhite', 'ForestGreen', 'Fuchsia', 'Gainsboro', 'GhostWhite', 'Gold', 'Goldenrod', 'Gray', 'Green', 'GreenYellow', 'Grey', 'Honeydew', 'HotPink', 'IndianRed', 'Indigo', 'Ivory', 'Khaki', 'Lavender', 'LavenderBlush', 'LawnGreen', 'LemonChiffon', 'LightBlue', 'LightCoral', 'LightCyan', 'LightGoldenrodYellow', 'LightGray', 'LightGreen', 'LightGrey', 'LightPink', 'LightSalmon', 'LightSeaGreen', 'LightSkyBlue', 'LightSlateGray', 'LightSlateGrey', 'LightSteelBlue', 'LightYellow', 'Lime', 'LimeGreen', 'Linen', 'Magenta', 'Maroon', 'MediumAquamarine', 'MediumBlue', 'MediumOrchid', 'MediumPurple', 'MediumSeaGreen', 'MediumSlateBlue', 'MediumSpringGreen', 'MediumTurquoise', 'MediumVioletRed', 'MidnightBlue', 'MintCream', 'MistyRose', 'Moccasin', 'NavajoWhite', 'Navy', 'OldLace', 'Olive', 'OliveDrab', 'Orange', 'OrangeRed', 'Orchid', 'PaleGoldenrod', 'PaleGreen', 'PaleTurquoise', 'PaleVioletRed', 'PapayaWhip', 'PeachPuff', 'Peru', 'Pink', 'Plum', 'PowderBlue', 'Purple', 'Red', 'RosyBrown', 'RoyalBlue', 'SaddleBrown', 'Salmon', 'SandyBrown', 'SeaGreen', 'Seashell', 'Sienna', 'Silver', 'SkyBlue', 'SlateBlue', 'SlateGray', 'SlateGrey', 'Snow', 'SpringGreen', 'SteelBlue', 'Tan', 'Teal', 'Thistle', 'Tomato', 'Turquoise', 'Violet', 'Wheat', 'White', 'WhiteSmoke', 'Yellow', 'YellowGreen')
		$HeaderColor = $rbgcolor | Out-GridView -OutputMode Single
		While ($rbgcolor.Contains($HeaderColor) -eq $false) {
			$HeaderColor = Read-Host 'Reports Header Color'
		}
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
			$input = ''
			While ($input -ne 'n') {
				If ($input -ne $null) {
					$emailtoA = Read-Host 'Email Address of the Recipient'
					$emailtoN = Read-Host 'Full Name of the Recipient'
					$ToAddress += $emailtoN + ' <' + $emailtoA + '>'
				}
				$input = Read-Host 'Add more recipients? (y/n)'
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
#			CTXNS            = $CTXNS
			TrustedDomains   = $trusteddomains
			ReportsFolder    = $ReportsFolder
			ParametersFolder = $ParametersFolder
			DashboardTitle   = $DashboardTitle
			HeaderColor      = $HeaderColor
			RemoveOldReports = $RemoveOldReports
			SaveExcelReport  = $SaveExcelReport
			SendEmail        = $SendEmail
			EmailFrom        = $FromAddress
			EmailTo          = $ToAddress
			SMTPServer       = $smtpServer
			SMTPServerPort   = $smtpServerPort
			SMTPEnableSSL    = $smtpEnableSSL
		} | Select-Object DateCollected, CTXDDC , CTXStoreFront , RDSLicenseServer , RDSLicenseType, TrustedDomains , ReportsFolder , ParametersFolder , DashboardTitle, HeaderColor, RemoveOldReports, SaveExcelReport , SendEmail , EmailFrom , EmailTo , SMTPServer , SMTPServerPort , SMTPEnableSSL

		if (Test-Path -Path "$ParametersFolder\Parameters.json") { Remove-Item "$ParametersFolder\Parameters.json" -Force -Verbose }
		$AllXDData | ConvertTo-Json -Depth 5 | Out-File -FilePath "$ParametersFolder\Parameters.json"

		$Global:PSParameters = $ParametersFolder + '\Parameters.json'
		[System.Environment]::SetEnvironmentVariable('PSParameters', $PSParameters, [System.EnvironmentVariableTarget]::User)
		Import-ParametersFile -JSONParameterFilePath $PSParameters

        Write-Color 'Testing PS Remote'
        try {
        Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock {$env:COMPUTERNAME}
        Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock {$env:COMPUTERNAME}
		} catch {Write-Warning "Please setup ps remoting to the DDC and StoreFront "}
        


}



