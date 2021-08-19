
<#PSScriptInfo

.VERSION 1.0.0

.GUID 233fdfa0-0f67-48c2-b6e1-0b6b0c0e9c5f

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT 

.TAGS citrix

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [19/08/2021_12:44] Initital Script Creating

#>

<# 

.DESCRIPTION 
 Start the gui 

#> 

Param()


Function Start-XDHealthCheckGui {
$MyScriptPath = Join-Path -Path ((Get-Module XDHealthCheck).ModuleBase).ToString() -ChildPath 'Private\XDHealthCheck-Gui.ps1'
Start-Process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-NoProfile -NoLogo -ExecutionPolicy Bypass -File `"$MyScriptPath`"" -NoNewWindow -Wait -ErrorAction Stop
} #end Function
