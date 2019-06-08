
<#PSScriptInfo

.VERSION 1.0.1

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

.PRIVATEDATA

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
$XMLParameter.Settings.Variables.Variable | ft
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Variable Details"

$XMLParameter.Settings.Variables.Variable | foreach {
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
Import-Module ..\CTXHealthCheck.psm1 -Force -Verbose

if ((Test-Path -Path $ReportsFolder\XDAudit) -eq $false) { New-Item -Path "$ReportsFolder\XDAudit" -ItemType Directory -Force -ErrorAction SilentlyContinue }

[string]$Reportname = $ReportsFolder + "\XDAudit\XD_Audit." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"
[string]$ExcelReportname = $ReportsFolder + "\XDAudit\XD_Audit." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xlsx"

if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
[string]$Transcriptlog ="$ReportsFolder\logs\XDAudit_TransmissionLogs." + (get-date -Format yyyy.MM.dd-HH.mm) + ".log"
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
$timer = [Diagnostics.Stopwatch]::StartNew();


########################################
## Getting Credentials
#########################################


$CTXAdmin = Find-Credential | where target -Like "*Healthcheck" | Get-Credential -Store
if ($CTXAdmin -eq $null) {
    $AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
    Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}
########################################
## Connect and get info
#########################################
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
$CitrixObjects = Get-CitrixObjects -AdminServer $CTXDDC -GetMachineCatalog -GetDeliveryGroup -GetPublishedApps -Verbose

$CitrixRemoteFarmDetails = Get-CitrixFarmDetails -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$MashineCatalog = $CitrixObjects.MashineCatalog | Select MachineCatalogName,AllocationType,SessionSupport,UnassignedCount,UsedCount,MasterImageVM,MasterImageSnapshotName,MasterImageSnapshotCount,MasterImageVMDate
$DeliveryGroups = $CitrixObjects.DeliveryGroups | select DesktopGroupName,Enabled,InMaintenanceMode,IncludedUserCSV,IncludeADGroupsCSV
$PublishedApps = $CitrixObjects.PublishedApps | select DesktopGroupName,ApplicationName,Enabled,CommandLineExecutable,CommandLineArguments,WorkingDirectory,PublishedAppGroupCSV,PublishedAppUserCSV



########################################
## Setting some table color and settings
########################################

$TableSettings = @{
    Style                  = 'cell-border'
    DisableOrdering        = $true
    DisableProcessing      = $true
    DisableResponsiveTable = $true
    DisableSelect          = $true
    DisableSearch          = $true
    DisableColumnReorder   = $true
    HideFooter             = $true
    TextWhenNoData         = 'No Data to display here'
}
$SectionSettings = @{
    HeaderBackGroundColor = 'DarkGray'
    HeaderTextAlignment   = 'center'
    HeaderTextColor       = 'White'
    BackgroundColor       = 'LightGrey'
    CanCollapse           = $false
}

$TableSectionSettings = @{
    HeaderTextColor       = 'Black'
    HeaderTextAlignment   = 'center'
    HeaderBackGroundColor = 'LightSteelBlue'
    BackgroundColor       = 'WhiteSmoke'
}

#######################
## Building the report
#######################
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"

$HeddingText = "XenDesktop Audit for Farm: " + $CitrixRemoteFarmDetails.SiteDetails.Summary.Name + " on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)  + " " + (Get-Date -Format HH:mm)
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


$timer.Stop()
$timer.Elapsed | select Days,Hours,Minutes,Seconds | fl
Stop-Transcript
}