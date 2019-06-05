
<#PSScriptInfo

.VERSION 1.0.0

.GUID fa7fec42-8046-43a1-ae32-0fecd229b795

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

#region 
[string]$ScriptPath = $PSScriptRoot
[xml]$Parameters = Get-Content .\Modules\CTXHealthCheck\Private\Setup\Parameters.xml # Read content of XML file
Import-Module CTXHealthCheck -Force -Verbose
Initialize-CitrixHealthCheck
 -XMLParameter $Parameters -ScriptPath $ScriptPath -Verbose
#endregion

