
<#PSScriptInfo

.VERSION 1.0.1

.GUID bc7d3016-a1c9-41b7-a1f9-fa20da99f891

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA

.COPYRIGHT

.TAGS Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Date Created - 22/05/2019_19:17
Date Updated - 24/05/2019_19:25

.PRIVATEDATA

#> 



<# 

.DESCRIPTION 
 Citrix XenDesktop HTML Health Check Report 

#> 
#Requires -Modules BetterCredentials, PSWriteColor,ImportExcel,PSWriteHTML,CTXHealthCheck

Param()

function Initialize-CitrixHealthCheck {
    PARAM(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [xml]$XMLParameter,
        [Parameter(Mandatory=$true, Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptPath)


[string]$Transcriptlog ="$ScriptPath\Reports\logs\XD_TransmissionLogs." + (get-date -Format yyyy.MM.dd-HH.mm) + ".log"
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
$timer = [Diagnostics.Stopwatch]::StartNew();
Clear-Host


########################################
## Getting Credentials
#########################################

$smtpClientCredentials = Find-Credential | where target -Like "*Healthcheck_smtp" | Get-Credential -Store
if ($smtpClientCredentials -eq $null) {
    $Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
    Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}

$CTXAdmin = Find-Credential | where target -Like "*Healthcheck" | Get-Credential -Store
if ($CTXAdmin -eq $null) {
    $AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
    Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}


########################################
## Build other variables
#########################################
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"

Write-Output "Using these Variables"
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


[string]$ReportsFolder = "$ScriptPath\Reports"
[string]$Reportname = $ReportsFolder + "\XD_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"
[string]$ExcelReportname = $ReportsFolder + "\XD_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xlsx"

$CTXControllers = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerController | select dnsname } | foreach { $_.dnsname }
$CTXLicenseServer = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerSite -AdminAddress $AdminServer | select LicenseServerName } | foreach { $_.LicenseServerName }
$CTXStoreFrontFarm = Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-STFServerGroup | select -ExpandProperty ClusterMembers | select hostname | foreach { ([System.Net.Dns]::GetHostByName(($_.hostname))).Hostname } }
$CTXCore = $CTXControllers + $CTXStoreFrontFarm + $CTXLicenseServer | sort -Unique

########################################
## Connect and get info
#########################################
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
$CitrixLicenseInformation = Get-CitrixLicenseInformation -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote
$CitrixRemoteFarmDetails = Get-CitrixRemoteFarmDetails -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$CitrixServerEventLogs = Get-CitrixServerEventLogs -Serverlist $CTXCore -Days 1 -RemoteCredentials $CTXAdmin -Verbose
$RDSLicenseInformation = Get-RDSLicenseInformation -LicenseServer $RDSLicensServer  -RemoteCredentials $CTXAdmin -Verbose
$CitrixConfigurationChanges = Get-CitrixConfigurationChanges -AdminServer $CTXDDC -Indays 30 -RemoteCredentials $CTXAdmin -Verbose
$StoreFrontDetails = Get-StoreFrontDetails -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$ServerPerformance = Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin -Verbose

Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing]Building Red Flags"
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
        if ([int]$server.CDrive_Free -lt 10) {$RedFlags += $server.Servername + " has only " + $server.CDrive_Free + " free disk space on C Drive"}
        if ([int]$server.DDrive_Free -lt 10) {$RedFlags += $server.Servername + " has only " + $server.DDrive_Free + " free disk space on D Drive"}
        if ([int]$server.Uptime -gt 3) {$RedFlags += $server.Servername + " was last rebooted " + $server.uptime + " Days ago"}
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

########################################
## Setting some table color and settings
########################################

$TableSettings = @{
    Style                  = 'cell-border'
    DisablePaging          = $true
    DisableOrdering        = $true
    DisableInfo            = $true
    DisableProcessing      = $true
    DisableResponsiveTable = $true
    DisableNewLine         = $true
    DisableSelect          = $true
    DisableSearch          = $true
    DisableColumnReorder   = $true
    HideFooter             = $true
    OrderMulti             = $true
    DisableStateSave       = $true
    TextWhenNoData         = 'No Data to display here'
}

$SectionSettings = @{
    HeaderBackGroundColor = 'DarkGray'
    HeaderTextAlignment   = 'center'
    HeaderTextColor       = 'White'
    BackgroundColor       = 'LightGrey'
    CanCollapse           = $true
}

$TableSectionSettings = @{
    HeaderTextColor       = 'Black'
    HeaderTextAlignment   = 'center'
    HeaderBackGroundColor = 'LightSteelBlue'
    BackgroundColor       = 'WhiteSmoke'
}

##########################
## Setting some conditions
###########################
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
#######################
## Building the report
#######################
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"
$emailbody = New-HTML -TitleText 'Red Flags'  {New-HTMLTable  @TableSettings  -DataTable $flags}

$HeddingText = "XenDesktop Report for Farm: " + $CitrixRemoteFarmDetails.SiteDetails.Summary.Name + " on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)
New-HTML -TitleText "XenDesktop Report"  -FilePath $Reportname {
    New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
    New-HTMLSection @SectionSettings  -Content {
        New-HTMLSection -HeaderText 'Citrix Sessions' @TableSectionSettings { New-HTMLTable  @TableSettings  -DataTable $CitrixRemoteFarmDetails.SessionCounts $Conditions_sessions }
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
        New-HTMLSection -HeaderText 'Citrix Error Counts' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  ($CitrixServerEventLogs.SingleServer | select ServerName, Errors, Warning) $Conditions_events }
        New-HTMLSection -HeaderText 'Citrix Events Top Events' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count) }
    }
    New-HTMLSection  @SectionSettings -Content {
        New-HTMLSection -HeaderText 'StoreFront Site' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  $StoreFrontDetails.SiteDetails }
        New-HTMLSection -HeaderText 'StoreFront Server' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $StoreFrontDetails.ServerDetails }
    }
    New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Config Changes in the last 7 days' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixConfigurationChanges.Summary | where { $_.name -ne "" } | Sort-Object count -Descending | select -First 5 -Property count, name) } }
    New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Server Performace' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($ServerPerformance) $Conditions_performance } }
    New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DeliveryGroups.Summary $Conditions_deliverygroup } }
    New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix UnRegistered Desktops' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops } }
    New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix UnRegistered Servers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredServers} }
    New-HTMLSection  @SectionSettings -Content { New-HTMLSection -HeaderText  'Citrix Tainted Objects' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.ADObjects.TaintedObjects } }
}


if ($SaveExcelReport) {
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Saving Excel Report"
$excelfile = $CitrixServerEventLogs.TotalAll  | Export-Excel -Path $ExcelReportname -WorksheetName EventsRawData -AutoSize -AutoFilter -Title "Citrix Events" -TitleBold -TitleSize 20 -FreezePane 3 -IncludePivotTable -TitleFillPattern DarkGrid -PivotTableName "Events Summery" -PivotRows MachineName, LevelDisplayName, ProviderName -PivotData @{"Message" = "count" } -NoTotalsInPivot
$excelfile += $CitrixConfigurationChanges.Filtered | Export-Excel -Path $ExcelReportname -WorksheetName ConfigChangeRawData -AutoSize -AutoFilter -Title "Citrix Config Changes" -TitleBold -TitleSize 20 -FreezePane 3

}
if ($SendEmail){
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing]Sending Report Email"
#send email
$emailMessage = New-Object System.Net.Mail.MailMessage
$emailMessage.From = $emailFrom
$emailMessage.To.Add($emailTo)
$emailMessage.Subject = "Citrix Health Check Report on " + (get-date -Format dd) + " " + (get-date -Format MMMM) + "," + (get-date -Format yyyy)
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
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending]Healthcheck Complete"

$timer.Stop()
$timer.Elapsed | select Days,Hours,Minutes,Seconds | fl
Stop-Transcript 

}
