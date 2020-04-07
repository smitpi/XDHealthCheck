
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
Created [06/06/2019_06:00] Initial Script Creating
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



function Start-IntranetF2CitrixAudit {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".json") })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + "\Reports\IntranetF2\Parameters.json"
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
	$ctxadmin = $Trusteddomains[0].Credentials
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"

	if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFolder\logs\XDAudit_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
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

	[string]$Reportname = $ReportsFolder + "\XDAudit\XD_Audit." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"
	[string]$XMLExport = $ReportsFolder + "\XDAudit\XD_Audit." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xml"
	[string]$ExcelReportname = $ReportsFolder + "\XDAudit\XD_Audit." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xlsx"

	#endregion

	########################################
	#region Getting Credentials
	#########################################


	#endregion

	########################################
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
	$CitrixObjects = Get-CitrixObjects -AdminServer $CTXDDC -RunAsPSRemote -RemoteCredentials $CTXAdmin -Verbose

	$MashineCatalog = $CitrixObjects.MashineCatalog | Select-Object MachineCatalogName, AllocationType, SessionSupport, UnassignedCount, UsedCount, MasterImageVM, MasterImageSnapshotName, MasterImageSnapshotCount, MasterImageVMDate
	$DeliveryGroups = $CitrixObjects.DeliveryGroups | Select-Object DesktopGroupName, Enabled, InMaintenanceMode, TotalApplications, TotalDesktops, DesktopsUnregistered, UserAccess, GroupAccess
	$PublishedApps = $CitrixObjects.PublishedApps | Select-Object DesktopGroupName, DesktopGroupUsersAccess, DesktopGroupGroupAccess, Enabled, ApplicationName, PublishedAppGroupAccess, PublishedAppUserAccess
	#endregion

	########################################
	#region saving data to xml
	########################################
	$AllXDData = New-Object PSObject -Property @{
		DateCollected           = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		MashineCatalog          = $CitrixObjects.MashineCatalog
		DeliveryGroups          = $CitrixObjects.DeliveryGroups
		PublishedApps           = $CitrixObjects.PublishedApps
        VDAServers              = $CitrixObjects.VDAServers
        VDAWorkstations         = $CitrixObjects.VDAWorkstations
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
		#Style          = 'stripe'
		Style          = 'cell-border'
		HideFooter     = $true
		OrderMulti     = $true
		TextWhenNoData = 'No Data to display here'
	}

	$SectionSettings = @{
		BackgroundColor       = 'white'
		CanCollapse           = $true
		HeaderBackGroundColor = 'white'
		HeaderTextAlignment   = 'center'
		HeaderTextColor       = $HeaderColor
	}

	$TableSectionSettings = @{
		BackgroundColor       = 'white'
		HeaderBackGroundColor = $HeaderColor
		HeaderTextAlignment   = 'center'
		HeaderTextColor       = 'white'
	}
	#endregion

	#######################
	#region Building HTML the report
	#######################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"

	$HeadingText = $DashboardTitle + " | XenDesktop Audit | " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
	New-HTML -TitleText "XenDesktop Audit"  -FilePath $Reportname {
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
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
		$AllXDData.VDAServers | Export-Excel -Path $ExcelReportname -WorksheetName VDAServers -AutoSize  -Title "Citrix VDA Servers" -TitleBold -TitleSize 20 -FreezePane 3
		$AllXDData.VDAWorkstations | Export-Excel -Path $ExcelReportname -WorksheetName VDAWorkstations -AutoSize  -Title "Citrix VDA Workstations" -TitleBold -TitleSize 20 -FreezePane 3
	}
	#endregion

	#######################
	#region Sending email reports
	#######################
	if ($SendEmail) {

		$smtpClientCredentials = Find-Credential | Where-Object target -Like "*Healthcheck_smtp" | Get-Credential -Store
		if ($null -eq $smtpClientCredentials) {
			$Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
			Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Sending Report Email"
		$emailMessage = New-Object System.Net.Mail.MailMessage
		$emailMessage.From = $emailFrom
        $emailTo | foreach {$emailMessage.To.Add($_)}
		$emailMessage.Subject =  $DashboardTitle + " - Citrix Audit Results Report on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)
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


