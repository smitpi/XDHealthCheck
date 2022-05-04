
<#PSScriptInfo

.VERSION 1.0.11

.GUID bc7d3016-a1c9-41b7-a1f9-fa20da99f891

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
Created [22/05/2019_19:17]
Updated [24/05/2019_19:25]
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
Creates and distributes  a report on citrix farm health.

.DESCRIPTION
Creates and distributes  a report on citrix farm health.

.PARAMETER JSONParameterFilePath
Path to the json config file, created by Install-ParametersFile

.EXAMPLE
Start-CitrixHealthCheck -JSONParameterFilePath 'C:\temp\Parameters.json'

#>
function Start-CitrixHealthCheck {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".json") })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.json"
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
	[string]$Transcriptlog = "$ReportsFolder\logs\XDHealth_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();


	if ((Test-Path -Path $ReportsFolder\XDHealth) -eq $false) { New-Item -Path "$ReportsFolder\XDHealth" -ItemType Directory -Force -ErrorAction SilentlyContinue }

	if ([bool]$RemoveOldReports) {
		$oldReports = (Get-Date).AddDays(-$RemoveOldReports)
		Get-ChildItem $ReportsFolder\XDHealth *.html | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDHealth *.xlsx | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDHealth *.xml | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\logs\XDHealth_TransmissionLogs* | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
	}
	[string]$Reportname = $ReportsFolder + "\XDHealth\XD_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"
	[string]$AllXMLExport = $ReportsFolder + "\XDHealth\XD_All_Healthcheck.xml"
	[string]$ReportsXMLExport = $ReportsFolder + "\XDHealth\XD_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xml"
	[string]$ExcelReportname = $ReportsFolder + "\XDHealth\XD_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xlsx"

	#endregion

	########################################
	#region Build other variables
	#########################################

    if (-not(Get-PSSnapin -Registered | Where-Object {$_.name -like "Citrix*"})) {Add-PSSnapin citrix* -ErrorAction SilentlyContinue}

	[array]$CTXControllers = (Get-BrokerController -AdminAddress $CTXDDC).dnsname
	[array]$CTXLicenseServer = (Get-BrokerSite -AdminAddress $AdminServer).LicenseServerName
	$CTXCore = $CTXControllers + $CTXStoreFrontFarm + $CTXLicenseServer | Sort-Object -Unique
	#endregion

	########################################
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting License Details"
	$CitrixLicenseInformation = Get-CitrixLicenseInformation -AdminServer $CTXDDC 
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
	$CitrixRemoteFarmDetails = Get-CitrixFarmDetail -AdminServer $CTXDDC 
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Eventlog Details"
	$CitrixServerEventLogs = Get-CitrixServerEventLog -Serverlist $CTXCore -Days 1 
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting RDS Details"
	$RDSLicenseInformation = Get-RDSLicenseInformation -LicenseServer $RDSLicenseServer | ForEach-Object { $_.$RDSLicenseType } | Where-Object { $_.TotalLicenses -ne 4294967295 } | Select-Object TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Config changes Details"
	$CitrixConfigurationChanges = Get-CitrixConfigurationChange -AdminServer $CTXDDC -Indays 7
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Storefront Details"
	$StoreFrontDetails = Get-StoreFrontDetail -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Server Performance Details"
	$ServerPerformance = Get-CitrixServerPerformance -ComputerName $CTXCore
	#endregion

	########################################
	#region Adding more reports / scripts
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Building Red Flags"
	Function Redflags {
		$RedFlags = @()
		$FlagReport = @()

		$CitrixLicenseInformation | Where-Object LicensesAvailable -LT 500 | ForEach-Object { $RedFlags += "Citrix License Product: " + $_.LicenseProductName + ", has " + $_.LicensesAvailable + " available licenses" }
		$RDSLicenseInformation | Where-Object AvailableLicenses -LT 500 | ForEach-Object { $RedFlags += $_.TypeAndModel + ", has " + $_.AvailableLicenses + " Licenses Available" }

		if ($null -eq $CitrixRemoteFarmDetails.SiteDetails.Summary.Name) { $RedFlags += "Could not connect to the Farm with server $CTXDDC" }
		else {
			if ($CitrixRemoteFarmDetails.DBConnection[0].Value -NE "OK") { $RedFlags += "Farm " + $CitrixRemoteFarmDetails.SiteDetails.Summary.Name + " can't connect to Database" }
			$CitrixRemoteFarmDetails.Controllers.Summary | Where-Object 'Desktops Registered' -LT 100 | ForEach-Object { $RedFlags += $_.Name + " ony have " + $_.'Desktops Registered' + " Desktops Registered" }
			$CitrixRemoteFarmDetails.Controllers.Summary | Where-Object State -notLike 'Active' | ForEach-Object { $RedFlags += $_.name + " is not active" }
			if ($CitrixRemoteFarmDetails.SessionCounts.'Unregistered Servers' -gt 0) { $RedFlags += "There are " + $CitrixRemoteFarmDetails.SessionCounts.'Unregistered Servers' + " Hosted Shared Server(s) Unregistered" }
			if ($CitrixRemoteFarmDetails.SessionCounts.'Unregistered Desktops' -gt 0) { $RedFlags += "There are " + $CitrixRemoteFarmDetails.SessionCounts.'Unregistered Desktops' + " VDI Desktop(s) Unregistered" }
			if ($CitrixRemoteFarmDetails.SessionCounts.'Tainted Objects' -gt 0) { $RedFlags += "There are " + $CitrixRemoteFarmDetails.SessionCounts.'Tainted Objects' + " Tainted Objects in the Database" }
			if (($CitrixRemoteFarmDetails.VDAUptime | Where-Object { $_.uptime -gt 7 }).count -gt 0) { $RedFlags += "There are " + (($CitrixRemoteFarmDetails.VDAUptime | Where-Object { $_.uptime -gt 7 }).count) + " VDA servers needed a reboot" }
		}

		$CitrixServerEventLogs | Where-Object Errors -gt 100 | ForEach-Object { $RedFlags += $_.'ServerName' + " have " + $_.Errors + " errors in the last 24 hours" }
		$ServerPerformance | Where-Object 'Stopped Services' -ne $null | ForEach-Object { $RedFlags += $_.Servername + " has stopped Citrix Services" }
		foreach ($server in $ServerPerformance) {
			if ([int]$server.'CDrive % Free' -lt 10) { $RedFlags += $server.Servername + " has only " + $server.'CDrive % Free' + " % free disk space on C Drive" }
			if ([int]$server.Uptime -gt 20) { $RedFlags += $server.Servername + " was last rebooted " + $server.uptime + " Days ago" }
		}

		$index = 0
		foreach ($flag in $RedFlags) {
			$index = $index + 1
			$Object = New-Object PSCustomObject
			$Object | Add-Member -MemberType NoteProperty -Name "#" -Value $index.ToString()
			$Object | Add-Member -MemberType NoteProperty -Name "Description" -Value $flag
			$FlagReport += $Object
		}
		$FlagReport
	}

	$flags = Redflags
	#endregion

	########################################
	#region saving data to xml
	########################################
	$AllXDData = New-Object PSObject -Property @{
		DateCollected              = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		Redflags                   = $flags
		CitrixLicenseInformation   = $CitrixLicenseInformation
		CitrixRemoteFarmDetails    = $CitrixRemoteFarmDetails
		CitrixServerEventLogs      = $CitrixServerEventLogs
		RDSLicenseInformation      = $RDSLicenseInformation | Select-Object TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses
		CitrixConfigurationChanges = $CitrixConfigurationChanges
		StoreFrontDetails          = $StoreFrontDetails
		ServerPerformance          = $ServerPerformance
	}
	if (Test-Path -Path $AllXMLExport) { Remove-Item $AllXMLExport -Force -Verbose }
	$AllXDData | Export-Clixml -Path $AllXMLExport -Depth 25 -NoClobber -Force

	$ReportXDData = New-Object PSObject -Property @{
		DateCollected                  = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		Redflags                       = $flags
		SiteDetails                    = $CitrixRemoteFarmDetails.SiteDetails.Summary
		SessionCounts                  = $CitrixRemoteFarmDetails.SessionCounts
		RebootSchedule                 = $CitrixRemoteFarmDetails.RebootSchedule
		Controllers                    = $CitrixRemoteFarmDetails.Controllers.Summary
		DBConnection                   = $CitrixRemoteFarmDetails.DBConnection
		CitrixLicenseInformation       = $CitrixLicenseInformation
		RDSLicenseInformation          = $RDSLicenseInformation
		CitrixServerEventLogs          = ($CitrixServerEventLogs.SingleServer | Select-Object ServerName, Errors, Warning)
		TotalProvider                  = ($CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count)
		StoreFrontDetailsSiteDetails   = $StoreFrontDetails.SiteDetails
		StoreFrontDetailsServerDetails = $StoreFrontDetails.ServerDetails
		CitrixConfigurationChanges     = ($CitrixConfigurationChanges.Summary | Where-Object { $_.name -ne "" } | Sort-Object count -Descending | Select-Object -First 5 -Property count, name)
		ServerPerformance              = $ServerPerformance
		DeliveryGroups                 = $CitrixRemoteFarmDetails.DeliveryGroups
		UnRegisteredDesktops           = $CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops
		UnRegisteredServers            = $CitrixRemoteFarmDetails.Machines.UnRegisteredServers
		TaintedObjects                 = $CitrixRemoteFarmDetails.ADObjects.TaintedObjects
		VDAUptime                      = $CitrixRemoteFarmDetails.VDAUptime | Where-Object { $_.uptime -gt 7 }
	} | Select-Object DateCollected, Redflags, SiteDetails, SessionCounts, RebootSchedule, Controllers, DBConnection, SharedServers, VirtualDesktop, CitrixLicenseInformation, RDSLicenseInformation, CitrixServerEventLogs, TotalProvider, StoreFrontDetailsSiteDetails, StoreFrontDetailsServerDetails, CitrixConfigurationChanges, ServerPerformance, DeliveryGroups, UnRegisteredDesktops, UnRegisteredServers, TaintedObjects, VDAUptime

	$ReportXDData | Export-Clixml -Path $ReportsXMLExport -NoClobber -Force

	#endregion

	########################################
	#region Setting some table color and settings
	########################################

	#######################
	#region Building HTML the report
	#######################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"
	$emailbody = New-HTML -TitleText 'Red Flags' { New-HTMLTable  @TableSettings  -DataTable $flags }

	$HeadingText = $DashboardTitle + " | XenDesktop Report | " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
	New-HTML -TitleText "XenDesktop Report"  -FilePath $Reportname {
		New-HTMLLogo -RightLogoString $XDHealth_LogoURL
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
		New-HTMLSection @SectionSettings  -Content {
			New-HTMLSection -HeaderText 'Citrix Sessions' @TableSectionSettings { New-HTMLTable   @TableSettings  -DataTable $CitrixRemoteFarmDetails.SessionCounts $Conditions_sessions }
		}
		New-HTMLSection @SectionSettings   -Content {
			New-HTMLSection -HeaderText 'Citrix Controllers'  @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  $CitrixRemoteFarmDetails.Controllers.Summary $Conditions_controllers }
			New-HTMLSection -HeaderText 'Citrix DB Connection' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DBConnection $Conditions_db }
		}
		New-HTMLSection  @SectionSettings  -Content {
			New-HTMLSection -HeaderText 'Citrix Licenses'  @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixLicenseInformation $Conditions_ctxlicenses }
			New-HTMLSection -HeaderText 'RDS Licenses' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($RDSLicenseInformation | Select-Object TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses) }
		}
		New-HTMLSection  @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Citrix Error Counts' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  ($CitrixServerEventLogs | Select-Object ServerName, Errors, Warning) $Conditions_events }
			New-HTMLSection -HeaderText 'Citrix Events Top Events' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixServerEventLogs.TopProfider | Select-Object -First $CTXCore.count) }
		}
		New-HTMLSection  @SectionSettings -Content {
			New-HTMLSection -HeaderText 'StoreFront Site' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  $StoreFrontDetails.SiteDetails }
			New-HTMLSection -HeaderText 'StoreFront Server' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $StoreFrontDetails.ServerDetails }
		}
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Config Changes in the last 7 days' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixConfigurationChanges.Summary | Where-Object { $_.name -ne "" } | Sort-Object count -Descending | Select-Object -First 5 -Property count, name) } }
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Server Performace' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($ServerPerformance) $Conditions_performance } }
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'VDA Server Uptime more than 7 days' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixRemoteFarmDetails.VDAUptime | Where-Object { $_.uptime -gt 7 }) } }
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DeliveryGroups $Conditions_deliverygroup } }
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix UnRegistered Desktops' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops } }
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix UnRegistered Servers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredServers } }
	}
	#endregion

	#######################
	#region Saving Excel report
	#######################
	if ($SaveExcelReport) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Saving Excel Report"
		$excelfile = $CitrixServerEventLogs.All | Export-Excel -Path $ExcelReportname -WorksheetName EventsRawData -AutoSize -AutoFilter -Title "Citrix Events" -TitleBold -TitleSize 20 -FreezePane 3 -IncludePivotTable -TitleFillPattern DarkGrid -PivotTableName "Events Summery" -PivotRows MachineName, LevelDisplayName, ProviderName -PivotData @{"Message" = "count" } -NoTotalsInPivot
		$excelfile += $CitrixConfigurationChanges.Filtered | Export-Excel -Path $ExcelReportname -WorksheetName ConfigChangeRawData -AutoSize -AutoFilter -Title "Citrix Config Changes" -TitleBold -TitleSize 20 -FreezePane 3

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
		$emailTo | ForEach-Object { $emailMessage.To.Add($_) }
		$emailMessage.Subject = $DashboardTitle + " - Citrix Health Check Report on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)
		$emailMessage.IsBodyHtml = $true
		$emailMessage.Body = $emailbody
		$emailMessage.Attachments.Add($Reportname)
		$emailMessage.Attachments.Add($ExcelReportname)
		$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
		#$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
		$smtpClient.EnableSsl = $smtpEnableSSL
		$smtpClient.Timeout = 30000000
		$smtpClient.Send( $emailMessage )
	}
	#endregion

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending]Healthcheck Complete"

	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript
}
