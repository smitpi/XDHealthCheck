
<#PSScriptInfo

.VERSION 1.0.0

.GUID ea771bac-90e2-4db5-b5f9-06fb61b98ba2

.AUTHOR Pierre Smit

.COMPANYNAME

.COPYRIGHT

.TAGS Powershell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [15/06/2019_14:19] Initital Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Setup script for XDHealthCheck Module

#>

Param()



function Install-XDHealthCheckParameter {

	Write-Host 'Installing needed Modules' -ForegroundColor Cyan
	if ((Get-PSRepository -Name PSGallery).InstallationPolicy -notlike 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }

	if ([bool](Get-Module -Name PSWriteColor) -eq $false) {
		Install-Module -Name PSWriteColor -Scope CurrentUser -Repository PSGallery -AllowClobber -SkipPublisherCheck -Force
		Import-Module -Name PSWriteColor -Force
		}

	Write-Color -Text 'Installing BetterCredentials Module' -Color DarkCyan -ShowTime
	if ([bool](Get-Module -Name BetterCredentials) -eq $false) {
        Install-Module -Name BetterCredentials -Scope CurrentUser -Repository PSGallery -AllowClobber -SkipPublisherCheck -Force
        Import-Module BetterCredentials
        }

	Write-Color -Text 'Installing ImportExcel Module' -Color DarkCyan -ShowTime
	if ([bool](Get-Module -Name ImportExcel) -eq $false) { Install-Module -Name ImportExcel -Scope CurrentUser -Repository PSGallery -AllowClobber -SkipPublisherCheck -Force }

	Write-Color -Text 'Installing PSWriteHTML Module' -Color DarkCyan -ShowTime
	if ([bool](Get-Module -Name PSWriteHTML) -eq $false) { Install-Module -Name PSWriteHTML -Scope CurrentUser -Repository PSGallery -AllowClobber -SkipPublisherCheck -Force }

	Write-Color -Text 'Installing UniversalDashboard Module' -Color DarkCyan -ShowTime
	if ([bool](Get-Module -Name UniversalDashboard.Community) -eq $false) { Install-Module -Name UniversalDashboard.Community -Scope CurrentUser -Repository PSGallery -AllowClobber -SkipPublisherCheck -Force }


	Function Set-Parameter {


		[string]$CTXDDC = Read-Host 'A Citrix Data Collector FQDN'
		[string]$CTXStoreFront = Read-Host 'A Citrix StoreFront FQDN'
		[string]$RDSLicensServer = Read-Host 'RDS LicenseServer FQDN'

		Write-Color -Text 'Add RDS License Type' -Color DarkGray -LinesAfter 1
		Write-Color "1: ", "Per Device"  -Color Yellow, Green
		Write-Color "2: ", "Per User"  -Color Yellow, Green
		$selection = Read-Host "Please make a selection"
		switch ($selection) {
			'1' { [string]$RDSLicensType = 'Per Device' }
			'2' { [string]$RDSLicensType = 'Per User' }
		}

		$ReportsFolder = Read-Host 'Path to the Reports Folder'
		$ParametersFolder = Read-Host 'Path to where the Parameters.xml will be saved'
		$DashboardTitle = Read-Host 'Title to be used in the reports and Dashboard'

		Write-Color -Text 'Save reports to an excel report' -Color DarkGray -LinesAfter 1
		Write-Color "1: ", "Yes"  -Color Yellow, Green
		Write-Color "2: ", "No"  -Color Yellow, Green
		$selection = Read-Host "Please make a selection"
		switch ($selection) {
			'1' { $SaveExcelReport = $true }
			'2' { $SaveExcelReport = $false }
		}

		Write-Color -Text 'Send Report via email' -Color DarkGray -LinesAfter 1
		Write-Color "1: ", "Yes"  -Color Yellow, Green
		Write-Color "2: ", "No"  -Color Yellow, Green
		$selection = Read-Host "Please make a selection"
		switch ($selection) {
			'1' { $SendEmail = $true }
			'2' { $SendEmail = $false }
		}

		if ($SendEmail -eq 'true') {
			$emailFromA = Read-Host 'Email Address of the Sender'
			$emailFromN = Read-Host 'Full Name of the Sender'
			$FromAddress = $emailFromN + " <" + $emailFromA + ">"

			$ToAddress = @()
			$input = ''
			While ($input -ne "n") {
				If ($input -ne $null) {
					$emailtoA = Read-Host 'Email Address of the Resipient'
					$emailtoN = Read-Host 'Full Name of the Recipient'
					$ToAddress += $emailtoN + " <" + $emailtoA + ">"
				}
				$input = Read-Host "Add more recipients? (y/n)"
			}

			$smtpServer = Read-Host 'IP or name of SMTP server'
			$smtpServerPort = Read-Host 'Port of SMTP server'
			Write-Color -Text 'Use ssl for SMTP' -Color DarkGray -LinesAfter 1
			Write-Color "1: ", "Yes"  -Color Yellow, Green
			Write-Color "2: ", "No"  -Color Yellow, Green
			$selection = Read-Host "Please make a selection"
			switch ($selection) {
				'1' { $smtpEnableSSL = $true }
				'2' { $smtpEnableSSL = $false }
			}
		}
		$AllXDData = New-Object PSObject -Property @{
			DateCollected    = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			CTXDDC           =	$CTXDDC
			CTXStoreFront    =	$CTXStoreFront
			RDSLicensServer  =	$RDSLicensServer
			RDSLicensType    =	$RDSLicensType
			ReportsFolder    =	$ReportsFolder
			ParametersFolder =	$ParametersFolder
			DashboardTitle   =	$DashboardTitle
			SaveExcelReport  =	$SaveExcelReport
			SendEmail        =	$SendEmail
			emailFrom        =  $FromAddress
			emailTo          =  $ToAddress
			smtpServer       =	$smtpServer
            smtpServerPort   =  $smtpServerPort
            smtpEnableSSL    =  $smtpEnableSSL
		} | select DateCollected,CTXDDC ,CTXStoreFront ,RDSLicensServer ,RDSLicensType ,ReportsFolder ,ParametersFolder ,DashboardTitle,SaveExcelReport ,SendEmail ,emailFrom ,emailTo ,smtpServer ,smtpServerPort ,smtpEnableSSL

        if (Test-Path -Path "$ParametersFolder\Parameters.xml") { Remove-Item "$ParametersFolder\Parameters.xml" -Force -Verbose }
		$AllXDData | Export-Clixml -Path "$ParametersFolder\Parameters.xml" -Depth 3 -NoClobber -Force

		$Global:PSParameters = $ParametersFolder + "\Parameters.xml"
		[System.Environment]::SetEnvironmentVariable('PSParameters', $PSParameters, [System.EnvironmentVariableTarget]::User)



    }

	function Test-Parameter {

		if ($PSParameters -eq $null) {
			$PSParameters = Read-Host 'Full Path to Parameters.xml file'
			if ((Get-Item $PSParameters).Extension -ne 'xml') { Write-Error 'Invalid xml file'; break }
        }
        $Parameters = Import-Clixml $PSParameters
        $Parameters
		$Parameters.PSObject.Properties | ForEach-Object { New-Variable -Name $_.name -Value $_.value -Force -Scope local }
		Write-Color -Text 'Checking Credentials' -Color DarkCyan -ShowTime
		########################################
		## Getting Credentials
		#########################################

		$XDAdmin = Find-Credential | Where-Object target -Like "*Healthcheck" | Get-Credential -Store
		if ($XDAdmin -eq $null) {
			$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for XD HealthChecks"
			Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for XD health checks" -Verbose
		}


		########################################
		## Build other variables
		#########################################

		Write-Color -Text 'Checking PS Remoting to servers' -Color DarkCyan -ShowTime

		$DDC = Invoke-Command -ComputerName $CTXDDC.ToString() -Credential $XDAdmin -ScriptBlock { [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname }
		$StoreFront = Invoke-Command -ComputerName $CTXStoreFront.ToString() -Credential $XDAdmin -ScriptBlock { [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname }
		$LicensServer = Invoke-Command -ComputerName $RDSLicensServer.ToString() -Credential $XDAdmin -ScriptBlock { [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname }

		if ($DDC -like '') { Write-Error '$XDDDC is not valid' }
		else { Write-Color -Text "$DDC is valid" -Color green -ShowTime }
		if ($StoreFront -like '') { Write-Error '$XDStoreFront is not valid' }
		else { Write-Color -Text "$StoreFront is valid" -Color green -ShowTime }
		if ($LicensServer -like '') { Write-Error '$RDSLicensServer is not valid' }
		else { Write-Color -Text "$LicensServer is valid" -Color green -ShowTime }

		if ($SendEmail) {
			Write-Color -Text 'Checking Sending Emails' -Color DarkCyan -ShowTime

			$smtpClientCredentials = Find-Credential | Where-Object target -Like "*Healthcheck_smtp" | Get-Credential -Store
			if ($smtpClientCredentials -eq $null) {
				$Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
				Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for XD health checks" -Verbose
			}


			$emailMessage = New-Object System.Net.Mail.MailMessage
			$emailMessage.From = $emailFrom
			$emailMessage.To.Add($emailTo)
			$emailMessage.Subject = "Test Healthcheck Email"
			$emailMessage.IsBodyHtml = $true
			$emailMessage.Body = "Test XDHealthcheck Email"


			$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
			$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
			$smtpClient.EnableSsl = $smtpEnableSSL
			$smtpClient.Timeout = 30000000


			$smtpClient.Send( $emailMessage )

		}
		Write-Color -Text '_________________________________________' -Color Green
		Write-Color -Text 'Tests Complete' -Color green -ShowTime
	}

	#region
	Write-Color -Text 'Make a selection from below' -Color DarkGray -LinesBefore 5
	Write-Color -Text '___________________________' -Color DarkGray -LinesAfter 1
	do {
		Write-Color "1: ", "Set Healthcheck Script Parameters"  -Color Yellow, Green
		Write-Color "2: ", "Test HealthCheck Script Parameters"  -Color Yellow, Green
		Write-Color "3: ", "Run the first HealthCheck"  -Color Yellow, Green
		Write-Color "Q: ", "Press 'Q' to quit."  -Color Yellow, DarkGray -LinesAfter 1

		$selection = Read-Host "Please make a selection"
		switch ($selection) {
			'1' { Set-Parameter }
			'2' { Test-Parameter }
			'3' { Initialize-CitrixHealthCheck -XMLParameterFilePath $PSParameters -Verbose }

		}
	}
	until ($selection.ToLower() -eq 'q')
}


