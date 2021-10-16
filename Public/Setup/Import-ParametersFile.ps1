
<#PSScriptInfo

.VERSION 1.0.6

.GUID bcf1a3eb-5df0-40d1-9e90-1c67e328d550

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
Created [25/06/2019_14:04] Initial Script Creating
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


Function Import-ParametersFile {
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".json") })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.json",
        [Parameter(Mandatory = $false, Position = 1)]
        [switch]$RedoCredentials = $false
	)

	$JSONParameter = Get-Content ($JSONParameterFilePath) | ConvertFrom-Json
	if ($null -eq $JSONParameter) { Write-Error "Valid Parameters file not found"; break }

	Write-Colour "Using Variables from Parameters.json: ", $JSONParameterFilePath.ToString() -ShowTime -Color DarkCyan, DarkYellow -LinesAfter 1
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
	$JSONParameter.PSObject.Properties | Where-Object { $_.name -notlike 'TrustedDomains' } | ForEach-Object { Write-Color $_.name, ":", $_.value  -Color Yellow, DarkCyan, Green -ShowTime; New-Variable -Name $_.name -Value $_.value -Force -Scope global }
	New-Variable -Name 'JSONParameterFilePath' -Value $JSONParameterFilePath -Scope global -force

	Write-Colour "Creating credentials for Trusted domains:" -ShowTime -Color DarkCyan -LinesBefore 2
	$Global:Trusteddomains = @()
	foreach ($domain in $JSONParameter.TrustedDomains) {
		$serviceaccount = Find-Credential | Where-Object target -Like ("*" + $domain.Description.tostring()) | Get-Credential -Store
		if ($null -eq $serviceaccount) {
			$serviceaccount = BetterCredentials\Get-Credential -Message ("Service Account for domain: " + $domain.NetBiosName.ToString())
			Set-Credential -Credential $serviceaccount -Target $domain.Description.ToString() -Persistence LocalComputer -Description ("Service Account for domain: " + $domain.NetBiosName.ToString())
		}
		Write-Color -Text $domain.FQDN, ":", $serviceaccount.username  -Color Yellow, DarkCyan, Green -ShowTime
		$CusObject = New-Object PSObject -Property @{
			FQDN        = $domain.FQDN
			Credentials = $serviceaccount
		}
		$Global:Trusteddomains += $CusObject
	}
	$global:CTXAdmin = Find-Credential | Where-Object target -Like "*CTXAdmin" | Get-Credential -Store
	if ($null -eq $CTXAdmin) {
		$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX Admin"
		Set-Credential -Credential $AdminAccount -Target "CTXAdmin" -Persistence LocalComputer -Description "Account used for Citrix queries" -Verbose
	}

	$global:NSAdmin = Find-Credential | Where-Object target -Like "*NSAdmin" | Get-Credential -Store
	if ($null -eq $CTXAdmin) {
		$NSAccount = BetterCredentials\Get-Credential -Message "Admin Account for Netscaler"
		Set-Credential -Credential $NSAccount -Target "NSAdmin" -Persistence LocalComputer -Description "Account used for Citrix Netscaler" -Verbose
	}
	Write-Colour "Netscaler Admin Credentials: ", $NSAdmin.UserName -ShowTime -Color yellow, Green -LinesBefore 1
	Write-Colour "Citrix Admin Credentials: ", $CTXAdmin.UserName -ShowTime -Color yellow, Green

	if ($SendEmail) {
		$global:SMTPClientCredentials = Find-Credential | Where-Object target -Like "*Healthcheck_smtp" | Get-Credential -Store
		if ($null -eq $SMTPClientCredentials) {
			$Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
			Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for XD health checks" -Verbose
		}
		Write-Colour "SMTP Credentials: ", $SMTPClientCredentials.UserName -ShowTime -Color yellow, Green -LinesBefore 2

	}

	if ($RedoCredentials) {
		foreach ($domain in $JSONParameter.TrustedDomains) {Find-Credential | Where-Object target -Like ("*" + $domain.Description.tostring()) | Remove-Credential -Verbose}
        Find-Credential | Where-Object target -Like "*CTXAdmin" | Remove-Credential -Verbose
		Find-Credential | Where-Object target -Like "*NSAdmin" | Remove-Credential -Verbose
	}

} #end Function

