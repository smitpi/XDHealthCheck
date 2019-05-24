
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
Import-Module .\Modules\PSWriteColor\0.85\PSWriteColor.psm1

Write-Color -Text "Script Root Folder - $ScriptPath" -Color Cyan -ShowTime
$xmlfile = get-item .\Parameters.xml
[xml]$TempParm = Get-Content '.\Parameters.xml' -Verbose

set-location -Path $ScriptPath
#Set-Location ..\..\..
Write-Color -Text "Script Root Folder - $ScriptPath" -Color Cyan -ShowTime

Write-Color -Text 'Setting up credentials' -Color DarkCyan -ShowTime
$CTXAdmin = Find-Credential | where target -Like "*Healthcheck" | Get-Credential -Store
if ($CTXAdmin -eq $null) {
    $AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
    Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}

$smtpClientCredentials = Find-Credential | where target -Like "*Healthcheck_smtp" | Get-Credential -Store
if ($smtpClientCredentials -eq $null) {
    $Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
    Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}

Write-Color -Text 'Setting up Parameters.xml' -Color DarkCyan -ShowTime

$TempParm.settings.Variables.Variable | foreach {
[string]$getnew = read-host $_.'#comment'
$_.value = $getnew
}
$TempParm.Save($xmlfile.FullName)

Write-Color -Text 'Setting up needed modules' -Color Cyan -ShowTime
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Write-Color -Text 'Installing BetterCredentials Module' -Color DarkCyan -ShowTime
Install-Module -Name BetterCredentials -RequiredVersion 4.5 -Repository PSGallery -Scope AllUsers -AllowClobber -SkipPublisherCheck

Write-Color -Text 'Installing ImportExcel Module' -Color DarkCyan -ShowTime
Install-Module -Name ImportExcel -RequiredVersion 6.0.0 -Repository PSGallery -Scope AllUsers -AllowClobber -SkipPublisherCheck

Write-Color -Text 'Installing PSWriteHTML Module' -Color DarkCyan -ShowTime
Install-Module -Name PSWriteHTML -RequiredVersion 0.0.32 -Repository PSGallery -Scope AllUsers -AllowClobber -SkipPublisherCheck

Write-Color -Text 'Installing CTXHealthCheck Module' -Color DarkCyan -ShowTime
Copy-Item (Get-Item .\Modules\CTXHealthCheck) -Destination 'C:\Program Files\WindowsPowerShell\Modules' -Recurse -Force
Import-Module CTXHealthCheck -Force -Verbose

Write-Color -Text 'Setup Complete' -Color Yellow -ShowTime
Write-Color -Text 'Run ValidateParameters.ps1 to check settings' -Color DarkYellow -ShowTime -NoNewLine

