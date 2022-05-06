
<#PSScriptInfo

.VERSION 1.0.10

.GUID 11d2e083-fcea-48c4-bb9f-093840ea5d0e

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT 

.TAGS Citrix

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [06/06/2019_06:00] Initial Script Creating
Updated [06/06/2019_19:26]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports
Updated [01/07/2020_14:43] Script Fle Info was updated
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
<#
.SYNOPSIS
Creates and distributes  a report on catalog, groups and published app config.

.DESCRIPTION
Creates and distributes  a report on catalog, groups and published app config.

.PARAMETER JSONParameterFilePath
Path to the json config file, created by Install-ParametersFile

.EXAMPLE
Start-CitrixAudit -JSONParameterFilePath 'C:\temp\Parameters.json'

#>
function Start-CitrixAudit {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Start-CitrixAudit')]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + '\Parameters.json'
	)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"
	##########################################
	#region xml imports
	##########################################
	Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath
	#endregion

	##########################################
	#region checking folders and report names
	##########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"

	if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFolder\logs\XDAudit_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.log'
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();

	if ((Test-Path -Path $ReportsFolder\XDAudit) -eq $false) { New-Item -Path "$ReportsFolder\XDAudit" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	if ([bool]$RemoveOldReports) {
		$oldReports = (Get-Date).AddDays(-$RemoveOldReports)
		Get-ChildItem $ReportsFolder\XDAudit *.html | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDAudit *.xlsx | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDAudit *.xml | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\logs\XDAudit_TransmissionLogs* | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
	}

	[string]$Reportname = $ReportsFolder + '\XDAudit\XD_Audit.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html'
	[string]$XMLExport = $ReportsFolder + '\XDAudit\XD_Audit.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xml'
	[string]$ExcelReportname = $ReportsFolder + '\XDAudit\XD_Audit.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx'

	#endregion

	########################################
	#region Getting Credentials
	#########################################


	#endregion

	########################################
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
	$CitrixObjects = Get-CitrixObjects -AdminServer $CTXDDC

	$MachineCatalog = $CitrixObjects.MachineCatalog | Select-Object MachineCatalogName, AllocationType, SessionSupport, UnassignedCount, UsedCount, MasterImageVM, MasterImageSnapshotName, MasterImageSnapshotCount, MasterImageVMDate
	$DeliveryGroups = $CitrixObjects.DeliveryGroups | Select-Object DesktopGroupName, Enabled, InMaintenanceMode, TotalApplications, TotalDesktops, DesktopsUnregistered, UserAccess, GroupAccess
	$PublishedApps = $CitrixObjects.PublishedApps | Select-Object DesktopGroupName, DesktopGroupUsersAccess, DesktopGroupGroupAccess, Enabled, ApplicationName, PublishedAppGroupAccess, PublishedAppUserAccess
	#endregion

	########################################
	#region saving data to xml
	########################################
	$AllXDData = New-Object PSObject -Property @{
		DateCollected     = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		MachineCatalog    = $CitrixObjects.MachineCatalog
		DeliveryGroups    = $CitrixObjects.DeliveryGroups
		PublishedApps     = $CitrixObjects.PublishedApps
		VDAServers        = $CitrixObjects.VDAServers
		VDAWorkstations   = $CitrixObjects.VDAWorkstations
		MachineCatalogSum = $MachineCatalog
		DeliveryGroupsSum = $DeliveryGroups
		PublishedAppsSum  = $PublishedApps
	}
	if (Test-Path -Path $XMLExport) { Remove-Item $XMLExport -Force -Verbose }
	$AllXDData | Export-Clixml -Path $XMLExport -Depth 25 -NoClobber -Force
	#endregion

	########################################
	#region Setting some table color and settings
	########################################

	

	#######################
	#region Building HTML the report
	#######################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"

	$HeadingText = $DashboardTitle + ' | XenDesktop Audit | ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)
	New-HTML -TitleText 'XenDesktop Audit' -FilePath $Reportname {
		New-HTMLLogo -RightLogoString $XDHealth_LogoURL
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Machine Catalogs' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $MachineCatalog }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $DeliveryGroups }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Published Apps' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $PublishedApps }
		}
	}
	#endregion

	#######################
	#region Saving Excel report
	#######################
	if ($SaveExcelReport) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Saving Excel Report"
		$AllXDData.MachineCatalog | Export-Excel -Path $ExcelReportname -AutoSize -AutoFilter -Title 'MachineCatalog' -WorksheetName MachineCatalog -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
		$AllXDData.DeliveryGroups | Export-Excel -Path $ExcelReportname -AutoSize -AutoFilter -Title 'DeliveryGroups' -WorksheetName DeliveryGroups -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
		$AllXDData.PublishedApps | Export-Excel -Path $ExcelReportname -AutoSize -AutoFilter -Title 'PublishedApps' -WorksheetName PublishedApps -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
		$AllXDData.VDAServers | Export-Excel -Path $ExcelReportname -AutoSize -AutoFilter -Title 'VDAServers' -WorksheetName VDAServers -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
		$AllXDData.VDAWorkstations | Export-Excel -Path $ExcelReportname -AutoSize -AutoFilter -Title 'VDAWorkstations' -WorksheetName VDAWorkstations -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
	}
	#endregion
	
	#######################
	#region Sending email reports
	#######################
	if ($SendEmail) {

		$smtpClientCredentials = Find-Credential | Where-Object target -Like '*Healthcheck_smtp' | Get-Credential -Store
		if ($null -eq $smtpClientCredentials) {
			$Account = BetterCredentials\Get-Credential -Message 'smtp login for HealthChecks email'
			Set-Credential -Credential $Account -Target 'Healthcheck_smtp' -Persistence LocalComputer -Description 'Account used for ctx health checks' -Verbose
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Sending Report Email"
		$emailMessage = New-Object System.Net.Mail.MailMessage
		$emailMessage.From = $emailFrom
		$emailTo | ForEach-Object { $emailMessage.To.Add($_) }

		$emailMessage.Subject = $DashboardTitle + ' - Citrix Audit Results Report on ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy)
		$emailMessage.IsBodyHtml = $true
		$emailMessage.Body = 'Please see attached reports'
		$emailMessage.Attachments.Add($Reportname)
		$emailMessage.Attachments.Add($ExcelReportname)

		$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
		#$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
		$smtpClient.EnableSsl = $smtpEnableSSL
		$smtpClient.Timeout = 30000000
		$smtpClient.Send( $emailMessage )
	}
	#endregion

	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript
}


