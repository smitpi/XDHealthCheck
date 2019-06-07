
<#PSScriptInfo

.VERSION 1.0.1

.GUID c7ea71fa-ee5a-4a79-9b88-8dc528714142

.AUTHOR Pierre Smit

.COMPANYNAME  

.COPYRIGHT

.TAGS Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [24/05/2019_19:23]
Updated [06/06/2019_19:24] 

.PRIVATEDATA

#> 



<#

.DESCRIPTION 
Citrix XenDesktop HTML Health Check Report

#>

Param()


#Requires -RunAsAdministrator

cls
[string]$ScriptPath = $PSScriptRoot
Set-Location $ScriptPath

Write-Host 'Installing needed Modules' -ForegroundColor Cyan
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -notlike 'Trusted') { Set-PSRepository -Name PSGallery -InstallationPolicy Trusted }
if ([bool](Get-Module -Name PSWriteColor) -eq $false) { Install-Module -Name PSWriteColor -RequiredVersion 0.85 -Repository PSGallery -Scope AllUsers -AllowClobber -SkipPublisherCheck }

Write-Color -Text 'Installing BetterCredentials Module' -Color DarkCyan -ShowTime
if ([bool](Get-Module -Name BetterCredentials) -eq $false) { Install-Module -Name BetterCredentials -RequiredVersion 4.5 -Repository PSGallery -Scope AllUsers -AllowClobber -SkipPublisherCheck }

Write-Color -Text 'Installing ImportExcel Module' -Color DarkCyan -ShowTime
if ([bool](Get-Module -Name ImportExcel) -eq $false) { Install-Module -Name ImportExcel -RequiredVersion 6.0.0 -Repository PSGallery -Scope AllUsers -AllowClobber -SkipPublisherCheck }

Write-Color -Text 'Installing PSWriteHTML Module' -Color DarkCyan -ShowTime
if ([bool](Get-Module -Name PSWriteHTML) -eq $false) { Install-Module -Name PSWriteHTML -RequiredVersion 0.0.32 -Repository PSGallery -Scope AllUsers -AllowClobber -SkipPublisherCheck }

Write-Color -Text 'Installing Anybox Module' -Color DarkCyan -ShowTime
if ([bool](Get-Module -Name Anybox) -eq $false) { Install-Module -Name Anybox -Repository PSGallery -Scope AllUsers -AllowClobber -SkipPublisherCheck }

Write-Color -Text 'Installing CTXHealthCheck Module' -Color DarkCyan -ShowTime
Install-Module -Name CTXHealthCheck -Repository PSGallery -Scope AllUsers -AllowClobber

Import-Module PSWriteColor
Import-Module BetterCredentials

Write-Color -Text "Script Root Folder - $ScriptPath" -Color Cyan -ShowTime
[string]$setupemail = Read-Host -Prompt 'Would you like to setup SMTP Emails (y/n)'

if ($setupemail[0] -like 'y') {
	$smtpClientCredentials = Find-Credential | where target -Like "*Healthcheck_smtp" | Get-Credential -Store
if ($smtpClientCredentials -eq $null) {
	$Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
	Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}

[xml]$TempParm = Get-Content .\Parameters-Template.xml -Verbose
}
else {
	[xml]$TempParm = Get-Content .\Parameters-TemplateNoEmail.xml -Verbose
}

Write-Color -Text 'Setting up credentials' -Color DarkCyan -ShowTime
$CTXAdmin = Find-Credential | where target -Like "*Healthcheck" | Get-Credential -Store
if ($CTXAdmin -eq $null) {
	$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
	Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}


Write-Color -Text 'Setting up Parameters.xml' -Color DarkCyan -ShowTime

$TempParm.settings.Variables.Variable | foreach {
	[string]$getnew = Read-Host $_.'#comment'
	$_.value = $getnew
}

$global:ParametersFolder = $TempParm.settings.Variables.Variable[5].Value.ToString()

$xmlfile = New-Item -Path $ParametersFolder  -Name Parameters.xml -ItemType File -Force -Verbose
$TempParm.Save($xmlfile.FullName)

[System.Environment]::SetEnvironmentVariable('PSParameters',"$ParametersFolder\Parameters.xml",[System.EnvironmentVariableTarget]::User)

Write-Color -Text '_________________________________________' -Color Green
Write-Color -Text 'Setup Complete' -Color green -ShowTime
Write-Color -Text 'Run Test-Parameters.ps1 to check settings' -Color green -ShowTime -LinesBefore 1
