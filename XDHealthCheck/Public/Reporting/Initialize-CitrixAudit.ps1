
<#PSScriptInfo

.VERSION 1.0.4

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
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports

.PRIVATEDATA Requires -Modules BetterCredentials, PSWriteColor,ImportExcel,PSWriteHTML

#>









<#

.DESCRIPTION
Citrix XenDesktop HTML Health Check Report

#>

Param()



function Initialize-CitrixAudit {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".xml") })]
		[string]$XMLParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.xml")

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"
	<#

	Write-Colour "Using these Variables"
	[XML]$XMLParameter = Get-Content $XMLParameterFilePath
	if ($null -eq $XMLParameter) { Write-Color -Text "Valid Parameters file not found; break" }
	$XMLParameter.Settings.Variables.Variable | Format-Table
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"

	$XMLParameter.Settings.Variables.Variable | ForEach-Object {
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
		}
		If ($CreateVariable) { New-Variable -Name $_.Name -Value $VarValue -Scope $_.Scope -Force }
	}
 #
 #>
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

	##########################################
	#region checking folders and report names
	##########################################
	if ((Test-Path -Path $ReportsFolder\XDAudit) -eq $false) { New-Item -Path "$ReportsFolder\XDAudit" -ItemType Directory -Force -ErrorAction SilentlyContinue }

	[string]$Reportname = $ReportsFolder + "\XDAudit\XD_Audit." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"
	[string]$XMLExport = $ReportsFolder + "\XDAudit\XD_Audit.xml"
	[string]$ExcelReportname = $ReportsFolder + "\XDAudit\XD_Audit." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xlsx"

	if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFolder\logs\XDAudit_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();
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
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
	$CitrixObjects = Get-CitrixObjects -AdminServer $CTXDDC -RunAsPSRemote -RemoteCredentials $CTXAdmin
	$MashineCatalog = $CitrixObjects.MashineCatalog | Select-Object MachineCatalogName, AllocationType, SessionSupport, UnassignedCount, UsedCount, MasterImageVM, MasterImageSnapshotName, MasterImageSnapshotCount, MasterImageVMDate
	$DeliveryGroups = $CitrixObjects.DeliveryGroups | Select-Object DesktopGroupName, Enabled, InMaintenanceMode, TotalApplications, TotalDesktops, DesktopsUnregistered, UserAccess, GroupAccess
	$PublishedApps = $CitrixObjects.PublishedApps | Select-Object DesktopGroupName, Enabled, ApplicationName, CommandLineExecutable, CommandLineArguments, WorkingDirectory, PublishedAppGroupAccess, PublishedAppUserAccess
	#endregion

	########################################
	#region saving data to xml
	########################################
	$AllXDData = New-Object PSObject -Property @{
		DateCollected           = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		CitrixRemoteFarmDetails = $CitrixRemoteFarmDetails
		MashineCatalog          = $CitrixObjects.MashineCatalog
		DeliveryGroups          = $CitrixObjects.DeliveryGroups
		PublishedApps           = $CitrixObjects.PublishedApps
		MashineCatalogSum       = $MashineCatalog
		DeliveryGroupsSum       = $DeliveryGroups
		PublishedAppsSum        = $PublishedApps
	}
	if (Test-Path -Path $XMLExport) { Remove-Item $XMLExport -Force -Verbose }
	$AllXDData | Export-Clixml -Path $XMLExport -Depth 25 -NoClobber -Force
	#endregion

	########################################
	#region Setting some table color and settings
	########################################
	$TableSettings = @{
		Style          = 'stripe'
		HideFooter     = $true
		TextWhenNoData = 'No Data to display here'
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

	#######################
	#region Building HTML the report
	#######################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"

	$HeddingText = $DashboardTitle + " | XenDesktop Audit | " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
	New-HTML -TitleText "XenDesktop Audit"  -FilePath $Reportname {
		New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
		New-HTMLSection @SectionSettings  -Content {
			New-HTMLSection -HeaderText 'Machine Catalogs' @TableSectionSettings { New-HTMLTable @TableSettings  -DataTable $MashineCatalog }
		}
		New-HTMLSection @SectionSettings   -Content {
			New-HTMLSection -HeaderText 'Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings  -DataTable $DeliveryGroups }
		}
		New-HTMLSection  @SectionSettings  -Content {
			New-HTMLSection -HeaderText 'Published Apps' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $PublishedApps }
		}
	}
	#endregion

	#######################
	#region Saving Excel report
	#######################
	if ($SaveExcelReport) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Saving Excel Report"
		$AllXDData.MashineCatalog | Export-Excel -Path $ExcelReportname -WorksheetName MashineCatalog -AutoSize  -Title "CitrixMashine Catalog" -TitleBold -TitleSize 20 -FreezePane 3
		$AllXDData.DeliveryGroups | Export-Excel -Path $ExcelReportname -WorksheetName DeliveryGroups -AutoSize  -Title "Citrix Delivery Groups" -TitleBold -TitleSize 20 -FreezePane 3
		$AllXDData.PublishedApps | Export-Excel -Path $ExcelReportname -WorksheetName PublishedApps -AutoSize  -Title "Citrix PublishedApps" -TitleBold -TitleSize 20 -FreezePane 3
	}
	#endregion

	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript
}
