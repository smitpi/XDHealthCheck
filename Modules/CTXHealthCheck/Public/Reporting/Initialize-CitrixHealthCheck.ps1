
<#PSScriptInfo

.VERSION 1.0.3

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

.PRIVATEDATA

#> 

#Requires -Module BetterCredentials
#Requires -Module PSWriteColor
#Requires -Module ImportExcel
#Requires -Module PSWriteHTML




<#

.DESCRIPTION 
Citrix XenDesktop HTML Health Check Report


Requires -Modules BetterCredentials, PSWriteColor,ImportExcel,PSWriteHTML

#>

Param()
function Initialize-CitrixHealthCheck {
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".xml") })]
		[string]$XMLParameterFilePath)




#region xml imports
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"

	Write-Colour "Using these Variables"
	[XML]$XMLParameter = Get-Content $XMLParameterFilePath
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

if ((Test-Path -Path $ReportsFolder\XDHealth) -eq $false) { New-Item -Path "$ReportsFolder\XDHealth" -ItemType Directory -Force -ErrorAction SilentlyContinue }

[string]$Reportname = $ReportsFolder + "\XDHealth\XD_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"
[string]$XMLExport = $ReportsFolder + "\XDHealth\XD_Healthcheck.xml"
[string]$ExcelReportname = $ReportsFolder + "\XDHealth\XD_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xlsx"

if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
[string]$Transcriptlog = "$ReportsFolder\logs\XDHealth_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
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
## Build other variables
#########################################
$CTXControllers = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerController | select dnsname } | foreach { $_.dnsname }
$CTXLicenseServer = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerSite -AdminAddress $AdminServer | select LicenseServerName } | foreach { $_.LicenseServerName }
$CTXStoreFrontFarm = Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-STFServerGroup | select -ExpandProperty ClusterMembers | select hostname | foreach { ([System.Net.Dns]::GetHostByName(($_.hostname))).Hostname } }
$CTXCore = $CTXControllers + $CTXStoreFrontFarm + $CTXLicenseServer | sort -Unique

########################################
## Connect and get info
########################################
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
$CitrixLicenseInformation = Get-CitrixLicenseInformation -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$CitrixRemoteFarmDetails = Get-CitrixFarmDetails -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$CitrixServerEventLogs = Get-CitrixServerEventLogs -Serverlist $CTXCore -Days 1 -RemoteCredentials $CTXAdmin -Verbose
$RDSLicenseInformation = Get-RDSLicenseInformation -LicenseServer $RDSLicensServer  -RemoteCredentials $CTXAdmin -Verbose
$CitrixConfigurationChanges = Get-CitrixConfigurationChanges -AdminServer $CTXDDC -Indays 7 -RemoteCredentials $CTXAdmin -Verbose
$StoreFrontDetails = Get-StoreFrontDetails -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$ServerPerformance = Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin -Verbose



########################################
## Adding more reports / scripts
########################################

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Building Red Flags"
Function Redflags {
	$RedFlags = @()
	$FlagReport = @()

	$CitrixLicenseInformation | Where-Object LicensesAvailable -LT 1000 | foreach { $RedFlags += $_.LocalizedLicenseProductName + " has " + $_.LicensesAvailable + " Avalable" }
$RDSLicenseInformation | Where-Object AvailableLicenses -LT 5000 | foreach { $RedFlags += $_.TypeAndModel + " has " + $_.AvailableLicenses + " RDS Licenses Available" }

if ($CitrixRemoteFarmDetails.SiteDetails.Summary.Name -eq $null) { $RedFlags += "Could not connect to the Farm with server $CTXDDC" }
else {
	if ($CitrixRemoteFarmDetails.DBConnection[0].Value -NE "OK") { $RedFlags += "Farm " + $CitrixRemoteFarmDetails.SiteDetails.Summary.Name + " can't connect to Database" }
	$CitrixRemoteFarmDetails.Controllers.Summary | Where-Object 'Desktops Registered' -LT 100 | foreach { $RedFlags += $_.Name + " ony have " + $_.'Desktops Registered' + " Desktops Registered" }
$CitrixRemoteFarmDetails.Controllers.Summary | Where-Object State -notLike 'Active' | foreach { $RedFlags += $_.name + " is not active" }
if ($CitrixRemoteFarmDetails.SessionCounts.'Unregistered Servers' -gt 0) { $RedFlags += "There are Hosted Desktop " + $CitrixRemoteFarmDetails.SessionCounts.'Unregistered Servers' + " Server(s) Unregistered" }
if ($CitrixRemoteFarmDetails.SessionCounts.'Unregistered Desktops' -gt 0) { $RedFlags += "There are VDI " + $CitrixRemoteFarmDetails.SessionCounts.'Unregistered Desktops' + " Desktop(s) Unregistered" }
if ($CitrixRemoteFarmDetails.SessionCounts.'Tainted Objects' -gt 0) { $RedFlags += "There are " + $CitrixRemoteFarmDetails.SessionCounts.'Tainted Objects' + " Tainted Objects in the Database" }
}

$CitrixServerEventLogs.SingleServer | Where-Object Errors -gt 100 | foreach { $RedFlags += $_.'ServerName' + " have " + $_.Errors + " errors in the last 24 hours" }
$ServerPerformance | Where-Object Stopped_Services -ne $null | foreach { $RedFlags += $_.Servername + " has stopped Citrix Services" }
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
if (Test-Path -Path $XMLExport) { Remove-Item $XMLExport -Force -Verbose}
$AllXDData | Export-Clixml -Path $XMLExport -Depth 25 -NoClobber -Force

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

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"
$emailbody = New-HTML -TitleText 'Red Flags' { New-HTMLTable  @TableSettings  -DataTable $flags }

$HeddingText = $DashboardTitle + " | XenDesktop Report | " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
New-HTML -TitleText "XenDesktop Report"  -FilePath $Reportname -ShowHTML {
	New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
	New-HTMLSection @SectionSettings  -Content {
		New-HTMLSection -HeaderText 'Citrix Sessions' @TableSectionSettings { New-HTMLTable   @TableSettings  -DataTable $CitrixRemoteFarmDetails.SessionCounts $Conditions_sessions }
	}
	new-HTMLTab		\\e -
	New-HTMLSection @SectionSettings   -Content {
		New-HTMLSection -HeaderText 'Citrix Controllers'  @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  $CitrixRemoteFarmDetails.Controllers.Summary $Conditions_controllers }
		New-HTMLSection -HeaderText 'Citrix DB Connection' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DBConnection $Conditions_db }
	}
	New-HTMLSection  @SectionSettings  -Content {
		New-HTMLSection -HeaderText 'Citrix Licenses'  @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixLicenseInformation $Conditions_ctxlicenses }
		New-HTMLSection -HeaderText 'RDS Licenses' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $RDSLicenseInformation.$RDSLicensType $Conditions_ctxlicenses }
	}
	New-HTMLSection  @SectionSettings -Content {
		New-HTMLSection -HeaderText 'Citrix Error Counts' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  ($CitrixServerEventLogs.SingleServer | select ServerName, Errors, Warning) $Conditions_events }
	New-HTMLSection -HeaderText 'Citrix Events Top Events' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count) }
}
New-HTMLSection  @SectionSettings -Content {
	New-HTMLSection -HeaderText 'StoreFront Site' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  $StoreFrontDetails.SiteDetails }
	New-HTMLSection -HeaderText 'StoreFront Server' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $StoreFrontDetails.ServerDetails }
}
New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Config Changes in the last 7 days' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixConfigurationChanges.Summary | where { $_.name -ne "" } | Sort-Object count -Descending | select -First 5 -Property count, name) } }
New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Server Performace' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($ServerPerformance) $Conditions_performance } }
New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DeliveryGroups $Conditions_deliverygroup } }
New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix UnRegistered Desktops' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops } }
New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix UnRegistered Servers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredServers } }
New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Tainted Objects' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.ADObjects.TaintedObjects } }
}


if ($SaveExcelReport) {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Saving Excel Report"
	$excelfile = $CitrixServerEventLogs.TotalAll | Export-Excel -Path $ExcelReportname -WorksheetName EventsRawData -AutoSize -AutoFilter -Title "Citrix Events" -TitleBold -TitleSize 20 -FreezePane 3 -IncludePivotTable -TitleFillPattern DarkGrid -PivotTableName "Events Summery" -PivotRows MachineName, LevelDisplayName, ProviderName -PivotData @{"Message" = "count" } -NoTotalsInPivot
    $excelfile += $CitrixConfigurationChanges.Filtered | Export-Excel -Path $ExcelReportname -WorksheetName ConfigChangeRawData -AutoSize -AutoFilter -Title "Citrix Config Changes" -TitleBold -TitleSize 20 -FreezePane 3

}
if ($SendEmail) {

	$smtpClientCredentials = Find-Credential | where target -Like "*Healthcheck_smtp" | Get-Credential -Store
if ($smtpClientCredentials -eq $null) {
	$Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
	Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Sending Report Email"
#send email
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
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending]Healthcheck Complete"

$timer.Stop()
$timer.Elapsed | select Days, Hours, Minutes, Seconds | fl
Stop-Transcript

}
