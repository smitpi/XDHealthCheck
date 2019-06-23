
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



function Initialize-CitrixAudit {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".xml") })]
		[string]$XMLParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.xml"
	)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"

	##########################################
	#region xml imports
	##########################################

	$XMLParameter = Import-Clixml $XMLParameterFilePath
	if ($null -eq $XMLParameter) { Write-Error "Valid Parameters file not found"; break }

	$ReportsFoldertmp = $XMLParameter.ReportsFolder.ToString()
	if ((Test-Path -Path $ReportsFoldertmp\logs) -eq $false) { New-Item -Path "$ReportsFoldertmp\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFoldertmp\logs\XDAudit_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();

	Write-Colour "Using Variables from Parameters.xml: ", $XMLParameterFilePath.ToString() -ShowTime -Color DarkCyan, DarkYellow -LinesAfter 1
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
	##########################################
	#region checking folders and report names
	##########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
	if ((Test-Path -Path $ReportsFolder\XDAudit) -eq $false) { New-Item -Path "$ReportsFolder\XDAudit" -ItemType Directory -Force -ErrorAction SilentlyContinue }

	if ([bool]$RemoveOldReports) {
		$oldReports = (Get-Date).AddDays(-$RemoveOldReports)
		Get-ChildItem $ReportsFolder\XDAudit *.html | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDAudit *.xlsx | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\logs\XDAudit_TransmissionLogs* | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
	}

	[string]$Reportname = $ReportsFolder + "\XDAudit\XD_Audit." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"
	[string]$XMLExport = $ReportsFolder + "\XDAudit\XD_Audit.xml"
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

	#######################
	#region Sending email reports
	#######################
	if ($SendEmail) {

		$smtpClientCredentials = Find-Credential | Where-Object target -Like "*Healthcheck_smtp" | Get-Credential -Store
		if ($smtpClientCredentials -eq $null) {
			$Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
			Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Sending Report Email"
		$emailMessage = New-Object System.Net.Mail.MailMessage
		$emailMessage.From = $emailFrom
		$emailMessage.To.Add($emailTo)
		$emailMessage.Subject = "Citrix Audit Results Report on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)
		$emailMessage.IsBodyHtml = $true
		$emailMessage.Body = 'Please see attached reports'
		$emailMessage.Attachments.Add($Reportname)
		$emailMessage.Attachments.Add($ExcelReportname)


		$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
		$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
		$smtpClient.EnableSsl = $smtpEnableSSL
		$smtpClient.Timeout = 30000000
		$smtpClient.Send( $emailMessage )
	}
	#endregion

	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript
}


