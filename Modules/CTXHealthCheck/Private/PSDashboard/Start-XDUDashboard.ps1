
<#PSScriptInfo

.VERSION 1.0.2

.GUID 144e3fd9-5999-4364-bdd6-99e1a6451adf

.AUTHOR Pierre Smit

.COMPANYNAME  

.COPYRIGHT

.TAGS Powershell

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

#> 

Param()
#Set-Location $PSScriptRoot

[XML]$XMLParameter = Get-Content $CTXParameters
$XMLParameter.Settings.Variables.Variable | ft
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"

$XMLParameter.Settings.Variables.Variable | foreach {
	# Set Variables contained in XML file
	$VarValue = $_.Value
	$CreateVariable = $True # Default value to create XML content as Variable
	switch ($_.Type) {
		# Format data types for each variable
		'[string]' { $VarValue = [string]$VarValue } # Fixed-length string of Unicode characters
		'[char]' { $VarValue = [char]$VarValue } # A Unicode 16-bit character
		'[byte]' { $VarValue = [byte]$VarValue } # An 8-bit unsigned character
		'[bool]' { If ($VarValue.ToLower() -eq 'false') { $VarValue = [bool]$False } ElseIf ($VarValue.ToLower() -eq 'true') { $VarValue = [bool]$True } } # An boolean True/False value
		'[int]' { $VarValue = [int]$VarValue } # 32-bit signed integer
		'[long]' { $VarValue = [long]$VarValue } # 64-bit signed integer
		'[decimal]' { $VarValue = [decimal]$VarValue } # A 128-bit decimal value
		'[single]' { $VarValue = [single]$VarValue } # Single-precision 32-bit floating point number
		'[double]' { $VarValue = [double]$VarValue } # Double-precision 64-bit floating point number
		'[DateTime]' { $VarValue = [DateTime]$VarValue } # Date and Time
		'[Array]' { $VarValue = [Array]$VarValue.Split(',') } # Array
		'[Command]' { $VarValue = Invoke-Expression $VarValue; $CreateVariable = $False } # Command
	}
	If ($CreateVariable) { New-Variable -Name $_.Name -Value $VarValue -Scope $_.Scope -Force }
}

$CTXAdmin = Find-Credential | where target -Like "*Healthcheck" | Get-Credential -Store
if ($CTXAdmin -eq $null) {
	$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
	Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}

########################################
## build pages
#########################################

$CTXFunctions = New-UDEndpointInitialization -Module @("CTXHealthCheck", "PoshRSJob") -Variable @("ReportsFolder", "ParametersFolder", "CTXAdmin", "PSParameters","CTXDDC","DashboardTitle") -Function @("Get-FullUserDetail", "Initialize-CitrixAudit", "Initialize-CitrixHealthCheck")

$Theme = New-UDTheme -Name "absa" -Definition @{
  UDNavBar = @{
      BackgroundColor = "rgb(202, 0, 28)"
      FontColor = "rgb(0, 0, 0)"
  }
  UDFooter = @{
      BackgroundColor = "rgb(202, 0, 28)"
      FontColor = "rgb(0, 0, 0)"
  }

} -Parent "default"

<#
 UDDashboard
UDNavBar
UDFooter
UDCard
UDChart
UDCounter
UDMonitor
UDGrid
UDTable
UDInput
 #>

########################################
## Build dashboard
#########################################
$Pages = Get-ChildItem (Join-Path $PSScriptRoot "Pages") | ForEach-Object {
. $_.FullName
}

Get-UDDashboard | Stop-UDDashboard

$Title = $DashboardTitle + " | Dashboard"
$Dashboard = New-UDDashboard -Title $Title -Pages $Pages -EndpointInitialization $CTXFunctions -Theme $Theme
Start-UDDashboard -Dashboard $Dashboard -Port 10008
Start-Process http://localhost:10008

