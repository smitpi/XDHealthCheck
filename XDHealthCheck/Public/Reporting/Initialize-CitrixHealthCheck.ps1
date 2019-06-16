
<#PSScriptInfo

.VERSION 1.0.5

.GUID bc7d3016-a1c9-41b7-a1f9-fa20da99f891

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
Created [22/05/2019_19:17]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:26]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports

.PRIVATEDATA

#>

<#

.DESCRIPTION
Citrix XenDesktop HTML Health Check Report

#>

Param()
function Initialize-CitrixHealthCheck {
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
			'[Command]' { $VarValue = Invoke-Expression $VarValue; $CreateVariable = $False } # Command
		}
		If ($CreateVariable) { New-Variable -Name $_.Name -Value $VarValue -Scope $_.Scope -Force }
	}
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
	if ((Test-Path -Path $ReportsFolder\XDHealth) -eq $false) { New-Item -Path "$ReportsFolder\XDHealth" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Reportname = $ReportsFolder + "\XDHealth\XD_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"
	[string]$XMLExport = $ReportsFolder + "\XDHealth\XD_Healthcheck.xml"
	[string]$ExcelReportname = $ReportsFolder + "\XDHealth\XD_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xlsx"

	if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFolder\logs\XDHealth_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();
	#endregion

	########################################
	#region Getting Credentials
	#########################################
	$CTXAdmin = Find-Credential | Where-Object target -Like "*Healthcheck" | Get-Credential -Store
	if ($CTXAdmin -eq $null) {
		$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
		Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
	}
	#endregion

	########################################
	#region Build other variables
	#########################################
	$CTXControllers = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerController | Select-Object dnsname } | ForEach-Object { $_.dnsname }
	$CTXLicenseServer = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerSite -AdminAddress $AdminServer | Select-Object LicenseServerName } | ForEach-Object { $_.LicenseServerName }
	$CTXStoreFrontFarm = Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-STFServerGroup | Select-Object -ExpandProperty ClusterMembers | Select-Object hostname | ForEach-Object { ([System.Net.Dns]::GetHostByName(($_.hostname))).Hostname } }
	$CTXCore = $CTXControllers + $CTXStoreFrontFarm + $CTXLicenseServer | Sort-Object -Unique
	#endregion

	########################################
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
	$CitrixLicenseInformation = Get-CitrixLicenseInformation -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote
	$CitrixRemoteFarmDetails = Get-CitrixFarmDetail -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote
	$CitrixServerEventLogs = Get-CitrixServerEventLog -Serverlist $CTXCore -Days 1 -RemoteCredentials $CTXAdmin
	$RDSLicenseInformation = Get-RDSLicenseInformation -LicenseServer $RDSLicensServer  -RemoteCredentials $CTXAdmin
	$CitrixConfigurationChanges = Get-CitrixConfigurationChange -AdminServer $CTXDDC -Indays 7 -RemoteCredentials $CTXAdmin
	$StoreFrontDetails = Get-StoreFrontDetail -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote
	$ServerPerformance = Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin
	#endregion

	########################################
	#region Adding more reports / scripts
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Building Red Flags"
	Function Redflags {
		$RedFlags = @()
		$FlagReport = @()

		$CitrixLicenseInformation | Where-Object LicensesAvailable -LT 1000 | ForEach-Object { $RedFlags += $_.LocalizedLicenseProductName + " has " + $_.LicensesAvailable + " Avalable" }
		$RDSLicenseInformation | Where-Object AvailableLicenses -LT 5000 | ForEach-Object { $RedFlags += $_.TypeAndModel + " has " + $_.AvailableLicenses + " RDS Licenses Available" }

		if ($CitrixRemoteFarmDetails.SiteDetails.Summary.Name -eq $null) { $RedFlags += "Could not connect to the Farm with server $CTXDDC" }
		else {
			if ($CitrixRemoteFarmDetails.DBConnection[0].Value -NE "OK") { $RedFlags += "Farm " + $CitrixRemoteFarmDetails.SiteDetails.Summary.Name + " can't connect to Database" }
			$CitrixRemoteFarmDetails.Controllers.Summary | Where-Object 'Desktops Registered' -LT 100 | ForEach-Object { $RedFlags += $_.Name + " ony have " + $_.'Desktops Registered' + " Desktops Registered" }
			$CitrixRemoteFarmDetails.Controllers.Summary | Where-Object State -notLike 'Active' | ForEach-Object { $RedFlags += $_.name + " is not active" }
			if ($CitrixRemoteFarmDetails.SessionCounts.'Unregistered Servers' -gt 0) { $RedFlags += "There are Hosted Desktop " + $CitrixRemoteFarmDetails.SessionCounts.'Unregistered Servers' + " Server(s) Unregistered" }
			if ($CitrixRemoteFarmDetails.SessionCounts.'Unregistered Desktops' -gt 0) { $RedFlags += "There are VDI " + $CitrixRemoteFarmDetails.SessionCounts.'Unregistered Desktops' + " Desktop(s) Unregistered" }
			if ($CitrixRemoteFarmDetails.SessionCounts.'Tainted Objects' -gt 0) { $RedFlags += "There are " + $CitrixRemoteFarmDetails.SessionCounts.'Tainted Objects' + " Tainted Objects in the Database" }
		}

		$CitrixServerEventLogs.SingleServer | Where-Object Errors -gt 100 | ForEach-Object { $RedFlags += $_.'ServerName' + " have " + $_.Errors + " errors in the last 24 hours" }
		$ServerPerformance | Where-Object Stopped_Services -ne $null | ForEach-Object { $RedFlags += $_.Servername + " has stopped Citrix Services" }
		foreach ($server in $ServerPerformance) {
			if ([int]$server.CDrive_Free -lt 10) { $RedFlags += $server.Servername + " has only " + $server.CDrive_Free + " free disk space on C Drive" }
			if ([int]$server.DDrive_Free -lt 10) { $RedFlags += $server.Servername + " has only " + $server.DDrive_Free + " free disk space on D Drive" }
			if ([int]$server.Uptime -gt 3) { $RedFlags += $server.Servername + " was last rebooted " + $server.uptime + " Days ago" }
		}

		$index = 0
		foreach ($flag in $RedFlags) {
			$index = $index + 1
			$Object = New-Object PSCustomObject
			$Object | Add-Member -MemberType NoteProperty -Name "#" -Value $index.ToString()
			$Object | Add-Member -MemberType NoteProperty -Name "Discription" -Value $flag
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
		RDSLicenseInformation      = $RDSLicenseInformation
		CitrixConfigurationChanges = $CitrixConfigurationChanges
		StoreFrontDetails          = $StoreFrontDetails
		ServerPerformance          = $ServerPerformance
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
		OrderMulti     = $true
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
	$emailbody = New-HTML -TitleText 'Red Flags' { New-HTMLTable  @TableSettings  -DataTable $flags }

	$HeddingText = $DashboardTitle + " | XenDesktop Report | " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
	New-HTML -TitleText "XenDesktop Report"  -FilePath $Reportname -ShowHTML {
		New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
		New-HTMLSection @SectionSettings  -Content {
			New-HTMLSection -HeaderText 'Citrix Sessions' @TableSectionSettings { New-HTMLTable   @TableSettings  -DataTable $CitrixRemoteFarmDetails.SessionCounts $Conditions_sessions }
		}
		New-HTMLSection @SectionSettings   -Content {
			New-HTMLSection -HeaderText 'Citrix Controllers'  @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  $CitrixRemoteFarmDetails.Controllers.Summary $Conditions_controllers }
			New-HTMLSection -HeaderText 'Citrix DB Connection' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DBConnection $Conditions_db }
		}
		New-HTMLSection  @SectionSettings  -Content {
			New-HTMLSection -HeaderText 'Citrix Licenses'  @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixLicenseInformation $Conditions_ctxlicenses }
			New-HTMLSection -HeaderText 'RDS Licenses' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $RDSLicenseInformation.$RDSLicensType $Conditions_ctxlicenses }
		}
		New-HTMLSection  @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Citrix Error Counts' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  ($CitrixServerEventLogs.SingleServer | Select-Object ServerName, Errors, Warning) $Conditions_events }
			New-HTMLSection -HeaderText 'Citrix Events Top Events' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count) }
		}
		New-HTMLSection  @SectionSettings -Content {
			New-HTMLSection -HeaderText 'StoreFront Site' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  $StoreFrontDetails.SiteDetails }
			New-HTMLSection -HeaderText 'StoreFront Server' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $StoreFrontDetails.ServerDetails }
		}
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Config Changes in the last 7 days' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixConfigurationChanges.Summary | Where-Object { $_.name -ne "" } | Sort-Object count -Descending | Select-Object -First 5 -Property count, name) } }
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Server Performace' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($ServerPerformance) $Conditions_performance } }
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DeliveryGroups $Conditions_deliverygroup } }
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix UnRegistered Desktops' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops } }
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix UnRegistered Servers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredServers } }
		New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Tainted Objects' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.ADObjects.TaintedObjects } }
	}
	#endregion

	#######################
	#region Saving Excel report
	#######################
	if ($SaveExcelReport) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Saving Excel Report"
		$excelfile = $CitrixServerEventLogs.TotalAll | Export-Excel -Path $ExcelReportname -WorksheetName EventsRawData -AutoSize -AutoFilter -Title "Citrix Events" -TitleBold -TitleSize 20 -FreezePane 3 -IncludePivotTable -TitleFillPattern DarkGrid -PivotTableName "Events Summery" -PivotRows MachineName, LevelDisplayName, ProviderName -PivotData @{"Message" = "count" } -NoTotalsInPivot
		$excelfile += $CitrixConfigurationChanges.Filtered | Export-Excel -Path $ExcelReportname -WorksheetName ConfigChangeRawData -AutoSize -AutoFilter -Title "Citrix Config Changes" -TitleBold -TitleSize 20 -FreezePane 3

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
		$emailMessage.Subject = "Citrix Health Check Report on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)
		$emailMessage.IsBodyHtml = $true
		$emailMessage.Body = $emailbody
		$emailMessage.Attachments.Add($Reportname)
		$emailMessage.Attachments.Add($ExcelReportname)


		$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
		$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
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
