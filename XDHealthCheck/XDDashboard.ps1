
<#PSScriptInfo

.VERSION 1.0.2

.GUID 144e3fd9-5999-4364-bdd6-99e1a6451adf

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
Created [06/06/2019_04:01]
Updated [06/06/2019_19:25]
Updated [09/06/2019_09:18]

.PRIVATEDATA

#>





<#

.DESCRIPTION
Universal Dashboard
#Requires -Modules XDHealthCheck

#>
PARAM(
	[Parameter(Mandatory = $false, Position = 0)]
	[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".xml") })]
	[string]$XMLParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.xml")

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
##########################################
#region xml imports
##########################################

Write-Colour "Using these Variables"
$XMLParameter = Import-Clixml $XMLParameterFilePath
if ($null -eq $XMLParameter) { Write-Error "Valid Parameters file not found"; break }
$XMLParameter
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
$XMLParameter.PSObject.Properties | ForEach-Object { New-Variable -Name $_.name -Value $_.value -Force -Scope local }
#endregion
########################################
#region Getting Credentials
#########################################

$CTXAdmin = Find-Credential | Where-Object target -Like "*Healthcheck" | Get-Credential -Store
if ($null -eq $CTXAdmin) {
	$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
	Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}
#endregion


########################################
## build pages
#########################################

$ConfigurationFile = Get-Content (Join-Path $PSScriptRoot dbconfig.json) | ConvertFrom-Json
Try { Import-Module (Join-Path $PSScriptRoot $ConfigurationFile.dashboard.rootmodule) -ErrorAction Stop }
Catch {	Write-Warning "Valid function module not found"; }

. (Join-Path $PSScriptRoot "themes\*.ps1")

$PageFolder = Get-ChildItem (Join-Path $PSScriptRoot pages)

$Pages = Foreach ($Page in $PageFolder) {
	. (Join-Path $PSScriptRoot "pages\$Page")
}
$UDTitle = $DashboardTitle + " | Dashboard"

$Initialization = New-UDEndpointInitialization -Module @(Join-Path $PSScriptRoot $ConfigurationFile.dashboard.rootmodule) -Variable @($XMLParameter.PSObject.Properties | ForEach-Object { $_.Name })

$DashboardParams = @{
	Title                  = $UDTitle
	Theme                  = $Myredtheme
	Pages                  = $Pages
	EndpointInitialization = $Initialization
}

$MyDashboard = New-UDDashboard @DashboardParams

Get-UDDashboard
Get-UDDashboard | Stop-UDDashboard
Start-UDDashboard -Port $ConfigurationFile.dashboard.port -Dashboard $MyDashboard -Name $UDTitle -AutoReload
Start-Process http://localhost:10000
