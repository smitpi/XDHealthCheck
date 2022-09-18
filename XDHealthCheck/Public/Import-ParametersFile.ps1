
<#PSScriptInfo

.VERSION 1.0.6

.GUID 66a0e008-b123-4c96-bbbd-d5d6d046465a

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Import the config file and creates the needed variables 

#> 



<#
.SYNOPSIS
Import the config file and creates the needed variables

.DESCRIPTION
Import the config file and creates the needed variables

.PARAMETER JSONParameterFilePath
Path to the json config file, created by Install-ParametersFile

.PARAMETER RedoCredentials
Deletes the saved credentials, and allow you to recreate them.

.EXAMPLE
Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath

#>
Function Import-ParametersFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Import-ParametersFile')]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + '\Parameters.json',
		[Parameter(Mandatory = $false, Position = 1)]
		[switch]$RedoCredentials = $false
	)

	$JSONParameter = Get-Content ($JSONParameterFilePath) | ConvertFrom-Json
	if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }

	Write-Color 'Using Variables from Parameters.json: ', $JSONParameterFilePath.ToString() -ShowTime -Color DarkCyan, DarkYellow -LinesAfter 1
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
	$JSONParameter.PSObject.Properties | Where-Object { $_.name -notlike 'TrustedDomains' } | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime; New-Variable -Name $_.name -Value $_.value -Force -Scope global }
	New-Variable -Name 'JSONParameterFilePath' -Value $JSONParameterFilePath -Scope global -Force

	# $global:CTXAdmin = Find-Credential | Where-Object target -Like '*CTXAdmin' | Get-Credential -Store
	# if ($null -eq $CTXAdmin) {
	# 	$AdminAccount = BetterCredentials\Get-Credential -Message 'Admin Account: DOMAIN\Username for CTX Admin'
	# 	Set-Credential -Credential $AdminAccount -Target 'CTXAdmin' -Persistence LocalComputer -Description 'Account used for Citrix queries' -Verbose
	# }
	# Write-Color 'Citrix Admin Credentials: ', $CTXAdmin.UserName -ShowTime -Color yellow, Green

	if ($SendEmail) {
		$global:SMTPClientCredentials = Find-Credential | Where-Object target -Like '*Healthcheck_smtp' | Get-Credential -Store
		if ($null -eq $SMTPClientCredentials) {
			$Account = BetterCredentials\Get-Credential -Message 'smtp login for HealthChecks email'
			Set-Credential -Credential $Account -Target 'Healthcheck_smtp' -Persistence LocalComputer -Description 'Account used for XD health checks' -Verbose
		}
		Write-Color 'SMTP Credentials: ', $SMTPClientCredentials.UserName -ShowTime -Color yellow, Green -LinesBefore 2

	}

	if ($RedoCredentials) {
		foreach ($domain in $JSONParameter.TrustedDomains) { Find-Credential | Where-Object target -Like ('*' + $domain.Description.tostring()) | Remove-Credential -Verbose }
		Find-Credential | Where-Object target -Like '*CTXAdmin' | Remove-Credential -Verbose
		Find-Credential | Where-Object target -Like '*NSAdmin' | Remove-Credential -Verbose
	}

} #end Function

