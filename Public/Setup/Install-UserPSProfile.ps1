
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
function Install-UserPSProfile {

	if ((Test-Path $profile) -eq $false ) {
		Write-Warning 'Profile does not exist, creating file.'
		New-Item -ItemType File -Path $Profile -Force
		$psfolder = (Get-Item $profile).DirectoryName
	} else { $psfolder = (Get-Item $profile).DirectoryName }


	## Create folders for powershell profile
	if ((Test-Path -Path $profile) -eq $false) { New-Item -Path $profile -ItemType file -Force -ErrorAction SilentlyContinue }
	if ((Test-Path -Path $psfolder\Scripts) -eq $false) { New-Item -Path "$psfolder\Scripts" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	if ((Test-Path -Path $psfolder\Modules) -eq $false) { New-Item -Path "$psfolder\Modules" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	if ((Test-Path -Path $psfolder\Reports) -eq $false) { New-Item -Path "$psfolder\Reports" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	if ((Test-Path -Path $psfolder\Config) -eq $false) { New-Item -Path "$psfolder\Config" -ItemType Directory -Force -ErrorAction SilentlyContinue }


	$text = @"
cls
if ((Test-Path `$profile) -eq `$false ) {
	Write-Warning "Profile does not exist, creating file."
	New-Item -ItemType File -Path `$Profile -Force
	`$psfolder = (Get-Item `$profile).DirectoryName
}
else { `$psfolder = (Get-Item `$profile).DirectoryName }

## Some Session Information
Write-Host "Welcome to Computer         :" -ForegroundColor Green -NoNewline
Write-Host (Invoke-Expression hostname) -ForegroundColor Cyan
Write-Host "Execution Policy            :" -ForegroundColor Green -NoNewline
Write-Host (Get-ExecutionPolicy) -ForegroundColor Cyan
Write-Host "Powershell Folder           :" -ForegroundColor Green -NoNewline
Write-Host `$psfolder -ForegroundColor Yellow


`$Modpaths = (`$env:PSModulePath).Split(";")


Write-Host " "
Write-Host "List of Module Paths: " -ForegroundColor yellow
Write-Host " "
foreach (`$Modpath in `$Modpaths ) { Write-Host `$Modpath -ForegroundColor Cyan }
Write-Host " "
Write-Host "Starting Session for: " -ForegroundColor Green -NoNewline
Write-Host (Invoke-Expression whoami) -ForegroundColor Yellow
Write-Host " "
Write-Host " "

Set-Location  `$psfolder\Scripts

"@

	Set-Content -Value $text -Path $profile
	. $profile
}
