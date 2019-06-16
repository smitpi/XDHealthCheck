
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

function Install-XDHealthCheckParameter {
Clear-Host
	Write-Host 'Installing needed Modules' -ForegroundColor Cyan
	if ((Get-PSRepository -Name PSGallery).InstallationPolicy -notlike 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }

	if ([bool](Get-Module -Name PSWriteColor) -eq $false) {
		Install-Module -Name PSWriteColor -Scope CurrentUser -Repository PSGallery -AllowClobber -SkipPublisherCheck
		Import-Module -Name PSWriteColor -Force
		}

	Write-Color -Text 'Installing BetterCredentials Module' -Color DarkCyan -ShowTime
	if ([bool](Get-Module -Name BetterCredentials) -eq $false) {
    Install-Module -Name BetterCredentials -Scope CurrentUser -Repository PSGallery -AllowClobber -SkipPublisherCheck
    Import-Module BetterCredentials
    }

	Write-Color -Text 'Installing ImportExcel Module' -Color DarkCyan -ShowTime
	if ([bool](Get-Module -Name ImportExcel) -eq $false) { Install-Module -Name ImportExcel -Scope CurrentUser -Repository PSGallery -AllowClobber -SkipPublisherCheck }

	Write-Color -Text 'Installing PSWriteHTML Module' -Color DarkCyan -ShowTime
	if ([bool](Get-Module -Name PSWriteHTML) -eq $false) { Install-Module -Name PSWriteHTML -Scope CurrentUser -Repository PSGallery -AllowClobber -SkipPublisherCheck }

	function Set-Parameter {

		[string]$setupemail = Read-Host -Prompt 'Would you like to setup SMTP Emails (y/n)'

		if ($setupemail[0] -like 'y') {
			[xml]$TempParm = Get-Content  $PSScriptRoot\Parameters-Template.xml
			$null = Find-Credential | Where-Object target -Like "*Healthcheck_smtp" | Remove-Credential
			$smtpClientCredentials = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
			Set-Credential -Credential $smtpClientCredentials -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for XD health checks" -Verbose
		} else { [xml]$TempParm = Get-Content  $PSScriptRoot\Parameters-TemplateNoEmail.xml }

		Write-Color -Text 'Setting up credentials' -Color DarkCyan -ShowTime
		$XDAdmin = Find-Credential | Where-Object target -Like "*Healthcheck" | Get-Credential -Store
		if ($XDAdmin -eq $null) {
			$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for XD HealthChecks"
			Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for XD health checks" -Verbose
		}

		Write-Color -Text 'Setting up Parameters.xml' -Color DarkCyan -ShowTime

		$TempParm.settings.Variables.Variable | ForEach-Object {
			[string]$getnew = Read-Host $_.SetupQuestion
			$_.value = $getnew
		}

		$ParametersFolder = $TempParm.settings.Variables.Variable[5].Value.ToString()
		$Global:PSParameters = $ParametersFolder + "\Parameters.xml"
		$xmlfile = New-Item -Path $ParametersFolder  -Name Parameters.xml -ItemType File -Force -Verbose
		$TempParm.Save($xmlfile.FullName)

		[System.Environment]::SetEnvironmentVariable('PSParameters', $PSParameters, [System.EnvironmentVariableTarget]::User)

		Write-Color -Text '_________________________________________' -Color Green
		Write-Color -Text 'Setup Complete' -Color green -ShowTime
	}
	function Test-Parameter {
    Clear-Host

		if ($PSParameters -eq $null) {
			$PSParameters = Read-Host 'Full Path to Parameters.xml file'
        }
		[xml]$Parameters = Get-Content $PSParameters

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

		$Parameters.Settings.Variables.Variable | Format-Table
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"

		$Parameters.Settings.Variables.Variable | ForEach-Object {
			# Set Variables contained in XML file
			$VarValue = $_.Value
			$CreateVariable = $True # Default value to create XML content as Variable
			switch ($_.Type) {
				# Format data types for each variable
				'[string]' { $VarValue = [string]$VarValue } # Fixed-length string of Unicode characters
				'[char]' { $VarValue = [char]$VarValue } # A Unicode 16-bit character
				'[byte]' { $VarValue = [byte]$VarValue } # An 8-bit unsigned character
				'[bool]' { If ($VarValue.ToLower() -eq 'false') { $VarValue = [bool]$False } ElseIf ($VarValue.ToLower() -eq 'true') { $VarValue = [bool]$True } } # An boolean True/False value
				'[int]' { $VarValue = [int]$VarValue } # 32-bit signed integer
				'[long]' { $VarValue = [long]$VarValue } # 64-bit signed integer
				'[decimal]' { $VarValue = [decimal]$VarValue } # A 128-bit decimal value
				'[single]' { $VarValue = [single]$VarValue } # Single-precision 32-bit floating point number
				'[double]' { $VarValue = [double]$VarValue } # Double-precision 64-bit floating point number
				'[DateTime]' { $VarValue = [DateTime]$VarValue } # Date and Time
				'[Array]' { $VarValue = [Array]$VarValue.Split(',') } # Array
				'[Command]' { $VarValue = Invoke-Expression $VarValue; $CreateVariable = $False } # Command
			}
			If ($CreateVariable) { New-Variable -Name $_.Name -Value $VarValue -Scope $_.Scope -Force }
		}


		Write-Color -Text 'Checking PS Remoting to servers' -Color DarkCyan -ShowTime

		$DDC = Invoke-Command -ComputerName $CTXDDC.ToString() -Credential $XDAdmin -ScriptBlock { [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname }
		$StoreFront = Invoke-Command -ComputerName $CTXStoreFront -Credential $XDAdmin -ScriptBlock { [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname }
		$LicensServer = Invoke-Command -ComputerName $RDSLicensServer -Credential $XDAdmin -ScriptBlock { [System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname }

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
			$emailMessage.Body = "Test Healthcheck Email"


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
	Write-Color -Text 'Make a selection from below' -Color DarkGray
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


