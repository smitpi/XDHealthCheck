
<#PSScriptInfo

.VERSION 1.0.2

.GUID 11d2e083-fcea-48c4-bb9f-093840ea5d0e

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
Created [06/06/2019_06:00] Initital Script Creating
Updated [06/06/2019_19:26]
Updated [09/06/2019_09:18]

.PRIVATEDATA
Requires -Modules BetterCredentials, PSWriteColor,ImportExcel,PSWriteHTML

#>





<#

.DESCRIPTION
Citrix XenDesktop HTML Health Check Report

#>

Param()



function Initialize-CitrixAudit {
    PARAM(
        [Parameter(Mandatory = $true, Position = 0)]
		[ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".xml")})]
        [string]$XMLParameterFilePath)

Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"

Write-Colour "Using these Variables"
[XML]$XMLParameter = Get-Content $XMLParameterFilePath
$XMLParameter.Settings.Variables.Variable | Format-Table
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Variable Details"

$XMLParameter.Settings.Variables.Variable | ForEach-Object {
		# Set Variables contained in XML file
		$VarValue = $_.Value
		$CreateVariable = $True # Default value to create XML content as Variable
		switch ($_.Type) {
			# Format data types for each variable
			'[string]' { $VarValue = [string]$VarValue } # Fixed-length string of Unicode characters
			'[char]' { $VarValue = [char]$VarValue } # A Unicode 16-bit character
			'[byte]' { $VarValue = [byte]$VarValue } # An 8-bit unsigned character
            '[bool]' { If ($VarValue.ToLower() -eq 'false'){$VarValue = [bool]$False} ElseIf ($VarValue.ToLower() -eq 'true'){$VarValue = [bool]$True} } # An boolean True/False value
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
Set-Location $PSScriptRoot

if ((Test-Path -Path $ReportsFolder\XDAudit) -eq $false) { New-Item -Path "$ReportsFolder\XDAudit" -ItemType Directory -Force -ErrorAction SilentlyContinue }

[string]$Reportname = $ReportsFolder + "\XDAudit\XD_Audit." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"
[string]$XMLExport = $ReportsFolder + "\XDAudit\XD_Audit.xml"
[string]$ExcelReportname = $ReportsFolder + "\XDAudit\XD_Audit." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xlsx"

if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
[string]$Transcriptlog ="$ReportsFolder\logs\XDAudit_TransmissionLogs." + (get-date -Format yyyy.MM.dd-HH.mm) + ".log"
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
$timer = [Diagnostics.Stopwatch]::StartNew();


########################################
## Getting Credentials
#########################################


$CTXAdmin = Find-Credential | Where-Object target -Like "*Healthcheck" | Get-Credential -Store
if ($null -eq $CTXAdmin) {
    $AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
    Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}
########################################
## Connect and get info
#########################################
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
$CitrixObjects = Get-CitrixObjects -AdminServer $CTXDDC -RunAsPSRemote -RemoteCredentials $CTXAdmin -Verbose

$CitrixRemoteFarmDetails = Get-CitrixFarmDetails -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$MashineCatalog = $CitrixObjects.MashineCatalog | Select-Object MachineCatalogName,AllocationType,SessionSupport,UnassignedCount,UsedCount,MasterImageVM,MasterImageSnapshotName,MasterImageSnapshotCount,MasterImageVMDate
$DeliveryGroups = $CitrixObjects.DeliveryGroups | Select-Object DesktopGroupName,Enabled,InMaintenanceMode,TotalApplications,TotalDesktops,DesktopsUnregistered,UserAccess,GroupAccess
$PublishedApps = $CitrixObjects.PublishedApps | Select-Object DesktopGroupName,Enabled,ApplicationName,CommandLineExecutable,CommandLineArguments,WorkingDirectory,PublishedAppGroupAccess,PublishedAppUserAccess


########################################
## Setting some table color and settings
########################################
#region Table Settings
$TableSettings = @{
	Style                  = 'stripe'
	HideFooter             = $true
	OrderMulti             = $true
	TextWhenNoData         = 'No Data to display here'
}

$SectionSettings = @{
	HeaderBackGroundColor = 'white'
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = 'red'
	BackgroundColor       = 'white'
	CanCollapse           = $true
}

$TableSectionSettings = @{
	HeaderTextColor       = 'white'
	HeaderTextAlignment   = 'center'
	HeaderBackGroundColor = 'red'
	BackgroundColor       = 'white'
}
#endregion
##########################
## Setting some conditions
###########################
#region Table Conditions
<#
$Conditions_Flags = {
    New-HTMLTableCondition -Name Discription -Type string -Operator eq -Value '*' -Color White -BackgroundColor Red -Row
}

$Conditions_sessions = {
    New-HTMLTableCondition -Name 'Unregistered Servers' -Type number -Operator gt -Value 0 -Color White -BackgroundColor Red
    New-HTMLTableCondition -Name 'Unregistered Desktops' -Type number -Operator gt -Value 0 -Color White -BackgroundColor Red
    New-HTMLTableCondition -Name 'Tainted Objects' -Type number -Operator gt -Value 0 -Color White -BackgroundColor Red
}

$Conditions_controllers = {
    New-HTMLTableCondition -Name State -Type string -Operator eq -Value 'Active' -Color White -BackgroundColor green
    New-HTMLTableCondition -Name 'Desktops Registered' -Type number -Operator lt 100 -Color White -BackgroundColor Red
}

$Conditions_db = {
    New-HTMLTableCondition -Name Value -Type string -Operator eq -Value 'OK' -Color White -BackgroundColor Green
}

$Conditions_ctxlicenses = {
    New-HTMLTableCondition -Name LicensesAvailable -Type number -Operator lt 1000 -Color White -BackgroundColor Red
    New-HTMLTableCondition -Name AvailableLicenses -Type number -Operator lt 1000 -Color White -BackgroundColor Red
}

$Conditions_events = {
    New-HTMLTableCondition -Name Errors -Type number -Operator gt -Value 100 -Color White -BackgroundColor red
}

$Conditions_performance = {
    New-HTMLTableCondition -Name Uptime -Type number -Operator ge -Value 7 -Color White -BackgroundColor Red
    New-HTMLTableCondition -Name 'Stopped_Services' -Type string -Operator ge -Value '*Citrix*' -Color White -BackgroundColor Red
    New-HTMLTableCondition -Name 'CDrive_Free' -Type number -Operator lt -Value 5 -Color White -BackgroundColor Red
    New-HTMLTableCondition -Name 'DDrive_Free' -Type number -Operator lt -Value 5 -Color White -BackgroundColor Red
}

$Conditions_deliverygroup = {
    New-HTMLTableCondition -Name DesktopsUnregistered -Type number -Operator gt -Value 0 -Color White -BackgroundColor Red
    New-HTMLTableCondition -Name InMaintenanceMode -Type string -Operator eq -Value 'True' -Color White -BackgroundColor Red
}
#>
#endregion

#######################
## Building the report
#######################

$AllXDData = New-Object PSObject -Property @{
	DateCollected             = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
    CitrixRemoteFarmDetails   = $CitrixRemoteFarmDetails
    MashineCatalog            = $CitrixObjects.MashineCatalog
	DeliveryGroups            = $CitrixObjects.DeliveryGroups
	PublishedApps             = $CitrixObjects.PublishedApps
    MashineCatalogSum         = $MashineCatalog
    DeliveryGroupsSum         = $DeliveryGroups
    PublishedAppsSum          = $PublishedApps
}
if (Test-Path -Path $XMLExport) { Remove-Item $XMLExport -Force -Verbose}
$AllXDData | Export-Clixml -Path $XMLExport -Depth 25 -NoClobber -Force

Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"

$HeddingText = $DashboardTitle + " | XenDesktop Audit | " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
New-HTML -TitleText "XenDesktop Audit"  -FilePath $Reportname  {
    New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
    New-HTMLSection @SectionSettings  -Content {
        New-HTMLSection -HeaderText 'Machine Catalogs' @TableSectionSettings { New-HTMLTable   -DataTable $MashineCatalog}
    }
    New-HTMLSection @SectionSettings   -Content {
        New-HTMLSection -HeaderText 'Delivery Groups' @TableSectionSettings { New-HTMLTable -DataTable $DeliveryGroups }
    }
    New-HTMLSection  @SectionSettings  -Content {
        New-HTMLSection -HeaderText 'Published Apps' @TableSectionSettings { New-HTMLTable -DataTable $PublishedApps }
    }
}
if ($SaveExcelReport) {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Saving Excel Report"
  $AllXDData.MashineCatalog | Export-Excel -Path $ExcelReportname -WorksheetName MashineCatalog -AutoSize  -Title "CitrixMashine Catalog" -TitleBold -TitleSize 20 -FreezePane 3
  $AllXDData.DeliveryGroups | Export-Excel -Path $ExcelReportname -WorksheetName DeliveryGroups -AutoSize  -Title "Citrix Delivery Groups" -TitleBold -TitleSize 20 -FreezePane 3
  $AllXDData.PublishedApps | Export-Excel -Path $ExcelReportname -WorksheetName PublishedApps -AutoSize  -Title "Citrix PublishedApps" -TitleBold -TitleSize 20 -FreezePane 3
}


$timer.Stop()
$timer.Elapsed | Select-Object Days,Hours,Minutes,Seconds | Format-List
Stop-Transcript
}
