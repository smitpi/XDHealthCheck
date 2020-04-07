
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
	[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.json"
)

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
##########################################
#region xml imports
##########################################

$XMLParameter = Import-Clixml $JSONParameterFilePath
if ($null -eq $XMLParameter) { Write-Error "Valid Parameters file not found"; break }

$ReportsFoldertmp = $XMLParameter.ReportsFolder.ToString()
if ((Test-Path -Path $ReportsFoldertmp\logs) -eq $false) { New-Item -Path "$ReportsFoldertmp\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }

Write-Colour "Using Variables from Parameters.xml: ", $JSONParameterFilePath.ToString() -ShowTime -Color DarkCyan, DarkYellow -LinesAfter 1
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
$XMLParameter.PSObject.Properties | Where-Object { $_.name -notlike 'TrustedDomains' } | ForEach-Object { Write-Color $_.name, ":", $_.value  -Color Yellow, DarkCyan, Green -ShowTime; New-Variable -Name $_.name -Value $_.value -Force -Scope local }

Write-Colour "Creating credentials for Trusted domains:" -ShowTime -Color DarkCyan -LinesBefore 2
$Trusteddomains = @()
foreach ($domain in $XMLParameter.TrustedDomains) {
	$serviceaccount = Find-Credential | Where-Object target -Like ("*" + $domain.Discription.tostring()) | Get-Credential -Store
	if ($null -eq $serviceaccount) {
		$serviceaccount = BetterCredentials\Get-Credential -Message ("Service Account for domain: " + $domain.NetBiosName.ToString())
		Set-Credential -Credential $serviceaccount -Target $domain.Discription.ToString() -Persistence LocalComputer -Description ("Service Account for domain: " + $domain.NetBiosName.ToString())
	}
	Write-Color -Text $domain.FQDN, ":", $serviceaccount.username  -Color Yellow, DarkCyan, Green -ShowTime
	$CusObject = New-Object PSObject -Property @{
		FQDN        = $domain.FQDN
		Credentials = $serviceaccount
	}
	$Trusteddomains += $CusObject
}
$CTXAdmin = Find-Credential | Where-Object target -Like "*Healthcheck" | Get-Credential -Store
if ($null -eq $CTXAdmin) {
	$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
	Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}
Write-Colour "Citrix Admin Credentials: ", $CTXAdmin.UserName -ShowTime -Color yellow, Green -LinesBefore 2
#endregion

########################################
## build pages
#########################################
#$XMLParameter.PSObject.Properties | ForEach-Object {($_.Name)} | Join-String -Separator '","'




$ConfigurationFile = Get-Content (Join-Path $PSScriptRoot dbconfig.json) | ConvertFrom-Json
Try { Import-Module (Join-Path $PSScriptRoot $ConfigurationFile.dashboard.rootmodule) -ErrorAction Stop }
Catch {	Write-Warning "Valid function module not found"; }

. (Join-Path $PSScriptRoot "themes\*.ps1")

$PageFolder = Get-ChildItem (Join-Path $PSScriptRoot pages) | Sort-Object name

$Pages = Foreach ($Page in $PageFolder) {
	. (Join-Path $PSScriptRoot "pages\$Page")
}
$UDTitle = $DashboardTitle + " | Dashboard"

$Initialization = New-UDEndpointInitialization -Module @(Join-Path $PSScriptRoot $ConfigurationFile.dashboard.rootmodule) -Variable @("DateCollected", "CTXDDC", "CTXStoreFront", "RDSLicenseServer", "RDSLicensType", "TrustedDomains", "ReportsFolder", "ParametersFolder", "DashboardTitle", "SaveExcelReport", "SendEmail", "EmailFrom", "EmailTo", "SMTPServer", "SMTPServerPort", "SMTPEnableSSL", "CTXAdmin", "JSONParameterFilePath")

$DashboardParams = @{
	Title                  = $UDTitle
	Theme                  = $Myredtheme
	Pages                  = $Pages
	EndpointInitialization = $Initialization
}

$MyDashboard = New-UDDashboard @DashboardParams
Get-UDDashboard | Stop-UDDashboard
Start-UDDashboard -Port $ConfigurationFile.dashboard.port -Dashboard $MyDashboard -Name $UDTitle
Start-Process http://localhost:8090
