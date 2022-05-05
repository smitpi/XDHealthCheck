
<#PSScriptInfo

.VERSION 1.0.13

.GUID b59eb9d3-7d4d-4956-96cf-fb2ed5053e19

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
Created [05/05/2019_08:57]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:25]
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
Get needed Farm details.

.DESCRIPTION
Get needed Farm details.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.EXAMPLE
Get-CitrixFarmDetail -AdminServer $CTXDDC 

#>
Function Get-CitrixFarmDetail {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixFarmDetail')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer
	)

	if (-not(Get-PSSnapin -Registered | Where-Object {$_.name -like 'Citrix*'})) {Add-PSSnapin citrix* -ErrorAction SilentlyContinue}

	#region Site details
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Site Details"
	$site = Get-BrokerSite -AdminAddress $AdminServer
	$SiteDetails = New-Object PSObject -Property @{
		Summary    = $site | Select-Object Name, ConfigLastChangeTime, LicenseEdition, LicenseModel, LicenseServerName
		AllDetails = $site
	}
	#endregion

	#region Controllers
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Controllers Details"
	[System.Collections.ArrayList]$Controllers = @()
	Get-BrokerController -AdminAddress $AdminServer | ForEach-Object {
		[void]$Controllers.Add([pscustomobject]@{
				AllDetails = $_
				Summary    = New-Object PSObject -Property @{
					Name                  = $_.dnsname
					'Desktops Registered' = $_.DesktopsRegistered
					'Last Activity Time'  = $_.LastActivityTime
					'Last Start Time'     = $_.LastStartTime
					State                 = $_.State
					ControllerVersion     = $_.ControllerVersion
				}
			})
	}
	#endregion

	#region Machines
try {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Machines Details"
	$NonRemotepc = Get-BrokerMachine -MaxRecordCount 1000000 -AdminAddress $AdminServer
	$UnRegServer = $NonRemotepc | Where-Object { $_.RegistrationState -like 'unreg*' -and $_.DeliveryType -notlike 'DesktopsOnly' } | Select-Object DNSName, CatalogName, DesktopGroupName, FaultState
	$UnRegDesktop = $NonRemotepc | Where-Object { $_.RegistrationState -like 'unreg*' -and $_.DeliveryType -like 'DesktopsOnly' } | Select-Object DNSName, CatalogName, DesktopGroupName, AssociatedUserNames, FaultState
	$Machines = New-Object PSObject -Property @{
		AllMachines          = $NonRemotepc
		UnRegisteredServers  = $UnRegServer
		UnRegisteredDesktops = $UnRegDesktop
	} | Select-Object AllMachines, UnRegisteredServers, UnRegisteredDesktops
} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}

	#endregion

	#region sessions
try {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Sessions Details"
	$sessions = Get-BrokerSession -MaxRecordCount 1000000 -AdminAddress $AdminServer
} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	
#endregion

	#region del groups
try {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] DeliveryGroups Details"
	$DeliveryGroups = Get-BrokerDesktopGroup -AdminAddress $AdminServer | Select-Object Name, DeliveryType, DesktopKind, IsRemotePC, Enabled, TotalDesktops, DesktopsAvailable, DesktopsInUse, DesktopsUnregistered, InMaintenanceMode, Sessions, SessionSupport, TotalApplicationGroups, TotalApplications
} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}	
#endregion		

	#region dbconnection	
try {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] DBConnection Details"
	$dbArray = @()

	$dbconnection = (Test-BrokerDBConnection -DBConnection(Get-BrokerDBConnection -AdminAddress $AdminServer))

	if ([bool]($dbconnection.ExtraInfo.'Database.Status') -eq $False) { [string]$dbstatus = 'Unavalable' }
	else { [string]$dbstatus = $dbconnection.ExtraInfo.'Database.Status' }

	$CCTXObject = New-Object PSObject -Property @{
		'Service Status'       = $dbconnection.ServiceStatus.ToString()
		'DB Connection Status' = $dbstatus
		'Is Mirroring Enabled' = $dbconnection.ExtraInfo.'Database.IsMirroringEnabled'.ToString()
		'DB Last Backup Date'  = $dbconnection.ExtraInfo.'Database.LastBackupDate'.ToString()
	} | Select-Object 'Service Status', 'DB Connection Status', 'Is Mirroring Enabled', 'DB Last Backup Date'

	$DBConnection = $CCTXObject.psobject.Properties | Select-Object -Property Name, Value
} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	
#endregion

	#region reboots
try {
	[System.Collections.ArrayList]$RebootSchedule = @()
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Reboot Schedule Details"
    Get-BrokerRebootScheduleV2 -AdminAddress $AdminServer -Day $((get-date).DayOfWeek.ToString()) | ForEach-Object {
        $sched = $_
        Get-BrokerMachine -DesktopGroupName $sched.DesktopGroupName | ForEach-Object {
                [void]$RebootSchedule.Add([pscustomobject]@{
                        ComputerName       = $_.DNSName
                        IP               = $_.IPAddress
                        DelGroup         = $_.DesktopGroupName
                        Day              = $sched.Day
                        Frequency         = $sched.Frequency
                        Name              = $sched.Name
                        RebootDuration    = $sched.RebootDuration
                        StartTime         = $sched.StartTime
        })
    }
    }
} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	#endregion
		
	#region uptime
try {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] VDA Uptime"	
	[System.Collections.ArrayList]$VDAUptime = @()
	Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 1000000 | Where-Object {$_.DesktopGroupName -notlike $null } | ForEach-Object {
		try {	
			$OS = Get-CimInstance Win32_OperatingSystem -ComputerName $_.DNSName -ErrorAction Stop | Select-Object *
			$Uptime = New-TimeSpan -Start $OS.LastBootUpTime -End (Get-Date)
			$updays = [math]::Round($uptime.Days, 0)
		} catch {
            try {
			Write-Warning "`t`tUnable to remote to $($_.DNSName), defaulting uptime to LastRegistrationTime"
			$Uptime = New-TimeSpan -Start $_.LastRegistrationTime -End (Get-Date)
			$updays = [math]::Round($uptime.Days, 0)
		} catch {$updays = "Unknown"}}


		[void]$VDAUptime.Add([pscustomobject]@{
				ComputerName         = $_.dnsname
				DesktopGroupName     = $_.DesktopGroupName
				SessionCount         = $_.SessionCount
				InMaintenanceMode    = $_.InMaintenanceMode
				MachineInternalState = $_.MachineInternalState
				Uptime               = $updays
				LastRegistrationTime = $_.LastRegistrationTime
			})
	}
} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	#endregion

	#region connection / machine failures
try {
	$Failures = Get-CitrixFailures -AdminServer $AdminServer -hours 24
} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}

	#endregion

	#region workspace app ver
try {
	$appver = Get-CitrixWorkspaceAppVersions -AdminServer $AdminServer -hours 24 | Where-Object {$_.ClientVersion -notlike $null}
} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	#endregion

	#region icartt
try {
     $CitrixSessionIcaRtt = Get-CitrixSessionIcaRtt -AdminServer $AdminServer -hours 24
} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
     
     #endregion

	#region counts
try {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Session Counts Details"
	$SessionCounts = New-Object PSObject -Property @{
		'Active Sessions'        = ($Sessions | Where-Object -Property Sessionstate -EQ 'Active').count
		'Disconnected Sessions'  = ($Sessions | Where-Object -Property Sessionstate -EQ 'Disconnected').count
		'Connection Failures'    = $Failures.ConnectionFails.Count
		'Unique Client Versions' = ($appver | Sort-Object -Property ClientVersion -Unique).Count
		'Unregistered Servers'   = ($Machines.UnRegisteredServers | Measure-Object).count
		'Unregistered Desktops'  = ($Machines.UnRegisteredDesktops | Measure-Object).count
		'Machine Failures'       = $Failures.mashineFails.Count
	} | Select-Object 'Active Sessions', 'Disconnected Sessions', 'Connection Failures', 'Unregistered Servers', 'Unregistered Desktops', 'Machine Failures' 
} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	
#endregion

	New-Object PSObject -Property @{
		DateCollected  = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		SiteDetails    = $SiteDetails
		Controllers    = $Controllers
		Machines       = $Machines
		Sessions       = $Sessions
		DeliveryGroups = $DeliveryGroups
		DBConnection   = $DBConnection
		SessionCounts  = $SessionCounts
		RebootSchedule = $RebootSchedule
		VDAUptime      = $VDAUptime
		Failures       = $Failures
		AppVer         = $appver
		IcaRtt         = $CitrixSessionIcaRtt
	} | Select-Object DateCollected, SiteDetails, Controllers, Machines, Sessions, DeliveryGroups, DBConnection, SessionCounts, RebootSchedule, VDAUptime, Failures, AppVer, IcaRtt

} #end Function

