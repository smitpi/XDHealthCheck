
<#PSScriptInfo

.VERSION 1.0.1

.GUID 9da8c9af-0838-424c-a18f-31253725c945

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT 

.TAGS Powershell

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [06/03/2021_18:58] Initital Script Creating
Updated [06/03/2021_20:58] Script Fle Info was updated

#> 



<# 

.DESCRIPTION 
Gui Menu for users

#> 

Param()


Function Start-XDMenu {
	#region Setup
	Remove-Module PSScriptMenuGui -ErrorAction SilentlyContinue
	try {
		Import-Module PSScriptMenuGui -ErrorAction Stop
	} catch {
		Write-Warning $_
		Write-Verbose 'Attempting to import from parent directory...' -Verbose
		Import-Module '..\'
	}
	#endregion

	$CSVPath = Join-Path -Path ((Get-Module XDHealthCheck).ModuleBase).ToString() -ChildPath 'Private\FunctionsMenu.csv'
	$params = @{
		csvPath               = $CSVPath
		windowTitle           = 'XD HealthCheck'
		buttonForegroundColor = 'Azure'
		buttonBackgroundColor = '#eb4034'
		hideConsole           = $true
		noExit                = $true
		Verbose               = $false
	}
	Show-ScriptMenuGui @params



} #end Function
