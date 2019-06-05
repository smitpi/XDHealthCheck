
<#PSScriptInfo

.VERSION 1.0.0

.GUID c7ea71fa-ee5a-4a79-9b88-8dc528714142

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA

.COPYRIGHT

.TAGS Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Date Created - 24/05/2019_19:23

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
Set-Location -Path $ScriptPath
Copy-Item (Get-Item ..\..\..\CTXHealthCheck) -Destination 'C:\Program Files\WindowsPowerShell\Modules' -Recurse -Force -Verbose

Import-Module 'C:\Program Files\WindowsPowerShell\Modules\CTXHealthCheck' -Force -Verbose
Import-Module PSWriteColor
Import-Module BetterCredentials

Write-Color -Text "Script Root Folder - $ScriptPath" -Color Cyan -ShowTime
if ((Test-Path .\Parameters.xml) -eq $true) { Remove-Item .\Parameters.xml -Verbose }
[string]$setupemail = Read-Host -Prompt 'Would you like to setup SMTP Emails (y/n)'
if ($setupemail[0] -like 'y') {
	$smtpClientCredentials = Find-Credential | where target -Like "*Healthcheck_smtp" | Get-Credential -Store
if ($smtpClientCredentials -eq $null) {
	$Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
	Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}

$xmlfile =	New-Item -Path . -Name Parameters.xml -ItemType File -Verbose
[xml]$TempParm = Get-Content .\Parameters-Template.xml -Verbose
}
else {
	$xmlfile =	New-Item -Path . -Name Parameters.xml -ItemType File -Verbose
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
$TempParm.Save($xmlfile.FullName)

Write-Color -Text '_________________________________________' -Color Green
Write-Color -Text 'Setup Complete' -Color green -ShowTime
Write-Color -Text 'Run Test-Parameters.ps1 to check settings' -Color green -ShowTime -LinesBefore 1

