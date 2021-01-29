
<#PSScriptInfo

.VERSION 1.0.3

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

.PRIVATEDATA

#> 







<# 

.DESCRIPTION 
Function for Citrix XenDesktop HTML Health Check Report

#> 

Param()



<#PSScriptInfo

.VERSION 1.0.0

.GUID ea771bac-90e2-4db5-b5f9-06fb61b98ba2

.AUTHOR Pierre Smit

.COMPANYNAME

.COPYRIGHT

.TAGS PowerShell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [15/06/2019_14:19] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Setup script for XDHealthCheck Module

#>
function Install-ParametersFile {

$wc = New-Object System.Net.WebClient
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials 
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Install-PackageProvider Nuget -Force
	#Register-PSRepository -Default -Verbose
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

	$ModuleList = Join-Path -Path ((Get-Module XDHealthCheck).ModuleBase).ToString() -ChildPath Public\Setup\modulelist.json
	$mods = Get-Content $ModuleList | ConvertFrom-Json

	foreach ($mod in $mods) {
		$PSModule = Get-Module -Name $mod.Name -ListAvailable | Select-Object -First 1
		if ($PSModule.Name -like '') { 
			Write-Host 'Installing Module:' -ForegroundColor Cyan -NoNewline
			Write-Host $mod.Name -ForegroundColor Yellow
			Install-Module -Name $mod.Name -Scope AllUsers -AllowClobber -Force 
		} else {
			Write-Host 'Using Installed Module:' -ForegroundColor Cyan -NoNewline
			Write-Host $PSModule.Name - $PSModule.Path -ForegroundColor Yellow
		}
	}



Function Set-Parameter {

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
	}
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
		CTXNS            = $CTXNS
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
	} | Select-Object DateCollected, CTXDDC , CTXStoreFront , RDSLicenseServer , RDSLicenseType, CTXNS, TrustedDomains , ReportsFolder , ParametersFolder , DashboardTitle, HeaderColor, RemoveOldReports, SaveExcelReport , SendEmail , EmailFrom , EmailTo , SMTPServer , SMTPServerPort , SMTPEnableSSL

	if (Test-Path -Path "$ParametersFolder\Parameters.json") { Remove-Item "$ParametersFolder\Parameters.json" -Force -Verbose }
	$AllXDData | ConvertTo-Json -Depth 5 | Out-File -FilePath "$ParametersFolder\Parameters.json"

	$Global:PSParameters = $ParametersFolder + '\Parameters.json'
	[System.Environment]::SetEnvironmentVariable('PSParameters', $PSParameters, [System.EnvironmentVariableTarget]::User)
}

function Test-Parameter {

	if ($PSParameters -eq $null) {
		$PSParameters = Read-Host 'Full Path to Parameters.json file'
	}
	Import-Module XDHealthCheck -Force -Verbose
	Import-ParametersFile -JSONParameterFilePath $PSParameters
	########################################
	## Build other variables
	#########################################

	Write-Color -Text 'Checking PS Remoting to servers' -Color DarkCyan -ShowTime

	$DDC = Invoke-Command -ComputerName $CTXDDC.ToString() -Credential $CTXAdmin -ScriptBlock { [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname }
	$StoreFront = Invoke-Command -ComputerName $CTXStoreFront.ToString() -Credential $CTXAdmin -ScriptBlock { [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname }
	$LicenseServer = Invoke-Command -ComputerName $RDSLicenseServer.ToString() -Credential $CTXAdmin -ScriptBlock { [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname }

	if ($DDC -like '') { Write-Error '$XDDDC is not valid' }
	else { Write-Color -Text "$DDC is valid" -Color green -ShowTime }
	if ($StoreFront -like '') { Write-Error '$XDStoreFront is not valid' }
	else { Write-Color -Text "$StoreFront is valid" -Color green -ShowTime }
	if ($LicenseServer -like '') { Write-Error '$RDSLicenseServer is not valid' }
	else { Write-Color -Text "$LicenseServer is valid" -Color green -ShowTime }

	if ($SendEmail) {
		Write-Color -Text 'Checking Sending Emails' -Color DarkCyan -ShowTime

		$smtpClientCredentials = Find-Credential | Where-Object target -Like '*Healthcheck_smtp' | Get-Credential -Store
		if ($smtpClientCredentials -eq $null) {
			$Account = BetterCredentials\Get-Credential -Message 'smtp login for HealthChecks email'
			Set-Credential -Credential $Account -Target 'Healthcheck_smtp' -Persistence LocalComputer -Description 'Account used for XD health checks' -Verbose
		}


		$emailMessage = New-Object System.Net.Mail.MailMessage
		$emailMessage.From = $emailFrom
		$emailMessage.To.Add($emailTo)
		$emailMessage.Subject = 'Test Healthcheck Email'
		$emailMessage.IsBodyHtml = $true
		$emailMessage.Body = 'Test XDHealthcheck Email'


		$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
		$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
		$smtpClient.EnableSsl = $smtpEnableSSL
		$smtpClient.Timeout = 30000000


		$smtpClient.Send( $emailMessage )

	}
	Write-Color -Text '_________________________________________' -Color Green
	Write-Color -Text 'Tests Complete' -Color green -ShowTime
}

function Change-Parameter {

	if ($PSParameters -eq $null) {
		$PSParameters = Read-Host 'Full Path to Parameters.json file'
		if ((Get-Item $PSParameters).Extension -ne 'json') { Write-Error 'Invalid json file'; break }
	}
	$Setting = $null
	$JSONParameter = Get-Content ($PSParameters) | ConvertFrom-Json
	[System.Collections.ArrayList]$Setting = $JSONParameter.PSObject.Properties | Select-Object name, value

	$input = 'y'
	While ($input -ne 'n') {
		$index = 0
		$setting | ForEach-Object { Write-Color $index.ToString(), ') ', $_.name, ':', $_.value -Color DarkCyan, DarkCyan, Yellow, DarkCyan, Green; $index ++ }
		$selection = Read-Host 'Select setting to change'
		Write-Color 'Changing : ', $setting[$selection].Name -Color DarkCyan, Yellow -NoNewLine
		$Setting[$selection].Value = Read-Host ' '
		$input = Read-Host 'Change more settings? (y/n)'
	}
}


#region
Write-Color -Text 'Make a selection from below' -Color DarkGray -LinesBefore 5
Write-Color -Text '___________________________' -Color DarkGray -LinesAfter 1
do {
	Write-Color '1: ', 'Set Healthcheck Script Parameters' -Color Yellow, Green
	Write-Color '2: ', 'Test HealthCheck Script Parameters' -Color Yellow, Green
	Write-Color '3: ', 'Run the first HealthCheck' -Color Yellow, Green
	Write-Color 'Q: ', "Press 'Q' to quit." -Color Yellow, DarkGray -LinesAfter 1

	$selection = Read-Host 'Please make a selection'
	switch ($selection) {
		'1' { Set-Parameter }
		'2' { Test-Parameter }
		'3' { Start-CitrixHealthCheck -JSONParameterFilePath $PSParameters -Verbose }

	}
}
until ($selection.ToLower() -eq 'q')
}



