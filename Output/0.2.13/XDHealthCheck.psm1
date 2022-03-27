#region Private Functions
########### Private Function ###############
# source: Reports-Colors.ps1
# Module: XDHealthCheck
############################################

if (Test-Path HKCU:\Software\XDHealth) {

    $global:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
    $global:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
    $global:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL

}
else {
        New-Item -Path HKCU:\Software\XDHealth
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color1 -Value '#061820'
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color2 -Value '#FFD400'
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name LogoURL -Value 'https://c.na65.content.force.com/servlet/servlet.ImageServer?id=0150h000003yYnkAAE&oid=00DE0000000c48tMAA'

    $global:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
    $global:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
    $global:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL
}


#region Html Settings
$global:TableSettings = @{
	Style           = 'cell-border'
	TextWhenNoData  = 'No Data to display here'
	Buttons         = 'searchBuilder', 'pdfHtml5', 'excelHtml5'
	AutoSize        = $true
	DisableSearch   = $true
	FixedHeader     = $true
	HideFooter      = $true
	ScrollCollapse  = $true
	ScrollX         = $true
	ScrollY         = $true
	SearchHighlight = $true
}
$global:SectionSettings = @{
	BackgroundColor       = 'grey'
	CanCollapse           = $true
	HeaderBackGroundColor = $XDHealth_Color1
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = $XDHealth_Color2
	HeaderTextSize        = '10'
	BorderRadius          = '15px'
}
$global:TableSectionSettings = @{
	BackgroundColor       = 'white'
	CanCollapse           = $true
	HeaderBackGroundColor = $XDHealth_Color2
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = $XDHealth_Color1
	HeaderTextSize        = '10'
}
#endregion


########### Private Function ###############
# source: Reports-Variables.ps1
# Module: XDHealthCheck
############################################


$global:RegistrationState = [PSCustomObject]@{
    0 = 'Unknown'
    1 = 'Registered'
    2 = 'Unregistered'
}
$global:ConnectionState = [PSCustomObject]@{
    0 = 'Unknown'
    1 = 'Connected'
    2 = 'Disconnected'
    3 = 'Terminated'
    4 = 'PreparingSession'
    5 = 'Active'
    6 = 'Reconnecting'
    7 = 'NonBrokeredSession'
    8 = 'Other'
    9 = 'Pending'
}
$global:ConnectionFailureType = [PSCustomObject]@{
    0 = 'None'
    1 = 'ClientConnectionFailure'
    2 = 'MachineFailure'
    3 = 'NoCapacityAvailable'
    4 = 'NoLicensesAvailable'
    5 = 'Configuration'
}
$global:SessionFailureCode = [PSCustomObject]@{
    0   = 'Unknown'
    1   = 'None'
    2   = 'SessionPreparation'
    3   = 'RegistrationTimeout'
    4   = 'ConnectionTimeout'
    5   = 'Licensing'
    6   = 'Ticketing'
    7   = 'Other'
    8   = 'GeneralFail'
    9   = 'MaintenanceMode'
    10  = 'ApplicationDisabled'
    11  = 'LicenseFeatureRefused'
    12  = 'NoDesktopAvailable'
    13  = 'SessionLimitReached'
    14  = 'DisallowedProtocol'
    15  = 'ResourceUnavailable'
    16  = 'ActiveSessionReconnectDisabled'
    17  = 'NoSessionToReconnect'
    18  = 'SpinUpFailed'
    19  = 'Refused'
    20  = 'ConfigurationSetFailure'
    21  = 'MaxTotalInstancesExceeded'
    22  = 'MaxPerUserInstancesExceeded'
    23  = 'CommunicationError'
    24  = 'MaxPerMachineInstancesExceeded'
    25  = 'MaxPerEntitlementInstancesExceeded'
    100 = 'NoMachineAvailable'
    101 = 'MachineNotFunctional'
}



#endregion
#region Public Functions
#region Get-CitrixConfigurationChange.ps1
############################################
# source: Get-CitrixConfigurationChange.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Show the changes that was made to the farm

.DESCRIPTION
Show the changes that was made to the farm

.PARAMETER AdminServer
Name of data collector

.PARAMETER Indays
Limit the search, to only show changes from the last couple of days

.PARAMETER RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

.EXAMPLE
Get-CitrixConfigurationChange -DDC $CTXDDC -Indays 7 -RemoteCredentials $CTXAdmin

#>
Function Get-CitrixConfigurationChange {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int32]$Indays,
		[Parameter(Mandatory = $true)]
		[PSCredential]$RemoteCredentials)

	Invoke-Command -ComputerName $AdminServer -ScriptBlock {
		param($AdminServer, $Indays)
		Add-PSSnapin citrix* -ErrorAction SilentlyContinue
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Config Changes Details"

		$startdate = (Get-Date).AddDays(-$Indays)
		$exportpath = (Get-Item (Get-Item Env:\TEMP).value).FullName + '\ctxreportlog.csv'

		if (Test-Path $exportpath) { Remove-Item $exportpath -Force -ErrorAction SilentlyContinue }
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Progress] Exporting Changes"

		Export-LogReportCsv -OutputFile $exportpath -StartDateRange $startdate -EndDateRange (Get-Date)
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Progress] Importing Changes"

		$LogExportAll = Import-Csv -Path $exportpath -Delimiter ','
		$LogExport = $LogExportAll | Where-Object { $_.'High Level Operation Text' -notlike '' } | Select-Object -Property High*
		$LogSum = $LogExportAll | Group-Object -Property 'High Level Operation Text' -NoElement

		Remove-Item $exportpath -Force -ErrorAction SilentlyContinue
		$CTXObject = New-Object PSObject -Property @{
			DateCollected = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			AllDetails    = $LogExportAll
			Filtered      = $LogExport
			Summary       = $LogSum
		}
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Config Changes Details"

		$CTXObject

	} -ArgumentList @($AdminServer, $Indays) -Credential $RemoteCredentials

} #end Function

 
Export-ModuleMember -Function Get-CitrixConfigurationChange
#endregion
 
#region Get-CitrixFarmDetail.ps1
############################################
# source: Get-CitrixFarmDetail.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Get needed Farm details.

.DESCRIPTION
Get needed Farm details.

.PARAMETER AdminServer
Name of a data collector

.PARAMETER RunAsPSRemote
Credentials if running psremote 

.PARAMETER RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

.EXAMPLE
Get-CitrixFarmDetail -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote

#>
Function Get-CitrixFarmDetail {
		[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $false, Position = 1)]
		[switch]$RunAsPSRemote = $false,
		[Parameter(Mandatory = $false, Position = 2)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)



	function CitrixFarmDetails {
		[CmdletBinding()]
		param($AdminServer)

		Add-PSSnapin Citrix*

		function Get-CTXSiteDetail($AdminServer) {
			$site = Get-BrokerSite -AdminAddress $AdminServer
			$CustomCTXObject = New-Object PSObject -Property @{
    			Summary    = $site | Select-Object Name, ConfigLastChangeTime, LicenseEdition, LicenseModel, LicenseServerName
				AllDetails = $site
			}
			$CustomCTXObject
		}

		function Get-CTXController($AdminServer) {
			$RegistedDesktops = @()
			$controllsers = Get-BrokerController -AdminAddress $AdminServer
			foreach ($server in $controllsers) {
				$CustomCTXObject = New-Object PSObject -Property @{
					Name                  = $server.dnsname
					'Desktops Registered' = $server.DesktopsRegistered
					'Last Activity Time'  = $server.LastActivityTime
					'Last Start Time'     = $server.LastStartTime
					State                 = $server.State
					ControllerVersion     = $server.ControllerVersion
				} | Select-Object Name, 'Desktops Registered', 'Last Activity Time', 'Last Start Time', State, ControllerVersion

				$RegistedDesktops += $CustomCTXObject
			}
			$CustomCTXObject = New-Object PSObject -Property @{
				Summary    = $RegistedDesktops
				AllDetails = $controllsers
			}

			$CustomCTXObject
		}

		function Get-CTXBrokerMachine($AdminServer) {
			$NonRemotepc = Get-BrokerDesktopGroup -AdminAddress $AdminServer | Where-Object { $_.IsRemotePC -eq $false } | ForEach-Object { Get-BrokerMachine -MaxRecordCount 10000 -AdminAddress $AdminBox -DesktopGroupName $_.name | Select-Object DNSName, CatalogName, DesktopGroupName, CatalogUid, AssociatedUserNames, DesktopGroupUid, DeliveryType, DesktopKind, DesktopUid, FaultState, IPAddress, IconUid, OSType, PowerActionPending, PowerState, PublishedApplications, RegistrationState, InMaintenanceMode, WindowsConnectionSetting }
			$UnRegServer = $NonRemotepc | Where-Object { $_.RegistrationState -like "unreg*" -and $_.DeliveryType -notlike "DesktopsOnly" } | Select-Object DNSName, CatalogName, DesktopGroupName, FaultState
			$UnRegDesktop = $NonRemotepc | Where-Object { $_.RegistrationState -like "unreg*" -and $_.DeliveryType -like "DesktopsOnly" } | Select-Object DNSName, CatalogName, DesktopGroupName, AssociatedUserNames, FaultState
			$CusObject = New-Object PSObject -Property @{
				AllMachines          = $NonRemotepc
				UnRegisteredServers  = $UnRegServer
				UnRegisteredDesktops = $UnRegDesktop
			} | Select-Object AllMachines, UnRegisteredServers, UnRegisteredDesktops
			$CusObject
		}

		function Get-CTXSession($AdminServer) { Get-BrokerSession -MaxRecordCount 10000 -AdminAddress $AdminServer }

		function Get-CTXBrokerDesktopGroup($AdminServer) {
			Get-BrokerDesktopGroup -AdminAddress $AdminServer | Select-Object Name, DeliveryType, DesktopKind, IsRemotePC, Enabled, TotalDesktops, DesktopsAvailable, DesktopsInUse, DesktopsUnregistered, InMaintenanceMode, Sessions, SessionSupport, TotalApplicationGroups, TotalApplications
		}

		function Get-CTXADObject($AdminServer) {
			$tainted = $adobjects = $CusObject = $null
			$adobjects = Get-AcctADAccount -MaxRecordCount 10000 -AdminAddress $AdminServer
			$tainted = $adobjects | Where-Object { $_.state -like "tainted*" }
			$CusObject = New-Object PSObject -Property @{
				AllObjects     = $adobjects
				TaintedObjects = $tainted
			} | Select-Object AllObjects, TaintedObjects
			$CusObject
		}

		function Get-CTXDBConnection($AdminServer) {
			$dbArray = @()

			$dbconnection = (Test-BrokerDBConnection -DBConnection(Get-BrokerDBConnection -AdminAddress $AdminBox))

			if ([bool]($dbconnection.ExtraInfo.'Database.Status') -eq $False) { [string]$dbstatus = "Unavalable" }
			else { [string]$dbstatus = $dbconnection.ExtraInfo.'Database.Status' }

			$CCTXObject = New-Object PSObject -Property @{
				"Service Status"       = $dbconnection.ServiceStatus.ToString()
				"DB Connection Status" = $dbstatus
				"Is Mirroring Enabled" = $dbconnection.ExtraInfo.'Database.IsMirroringEnabled'.ToString()
				"DB Last Backup Date"  = $dbconnection.ExtraInfo.'Database.LastBackupDate'.ToString()
			} | Select-Object  "Service Status", "DB Connection Status", "Is Mirroring Enabled", "DB Last Backup Date"
			$dbArray = $CCTXObject.psobject.Properties | Select-Object -Property Name, Value
			$dbArray
		}

		function Get-CTXRebootSchedule ($AdminServer) { Get-BrokerRebootScheduleV2 -AdminAddress $AdminServer | Select-Object Day, DesktopGroupName, Enabled, Frequency, Name, RebootDuration, StartTime}

		function Get-VDAUptime($AdminServer) {
			$VDAUptime = @()
			Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 1000000 | Where-Object {$_.DesktopGroupName -notlike $null } | ForEach-Object {
			try {	
                $OS = Get-CimInstance Win32_OperatingSystem -ComputerName $_.DNSName -ErrorAction Stop | Select-Object *
				$Uptime = (Get-Date) - ($OS.LastBootUpTime)
				$updays = [math]::Round($uptime.Days, 0)
				$CusObject = New-Object PSObject -Property @{
					ComputerName         = $_.dnsname
					DesktopGroupName     = $_.DesktopGroupName
					SessionCount         = $_.SessionCount
					InMaintenanceMode    = $_.InMaintenanceMode
					MachineInternalState = $_.MachineInternalState
					Uptime               = $updays
				} | Select-Object ComputerName, DesktopGroupName, SessionCount, InMaintenanceMode, MachineInternalState, Uptime
				$VDAUptime += $CusObject
                } catch {Write-Warning "Cannot connect $($_.DNSName) to get uptime"}
			}
			$VDAUptime
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Site Details"
		$SiteDetails = Get-CTXSiteDetail -AdminServer $AdminServer
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Controllers Details"
		$Controllers = Get-CTXController -AdminServer $AdminServer
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Machines Details"
		$Machines = Get-CTXBrokerMachine -AdminServer $AdminServer
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] DeliveryGroups Details"
		$DeliveryGroups = Get-CTXBrokerDesktopGroup -AdminAddress $AdminServer
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Sessions Details"
		$Sessions = Get-CTXSession -AdminServer $AdminServer
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] ADObjects Details"
		$ADObjects = Get-CTXADObject -AdminServer $AdminServer
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] DBConnection Details"
		$DBConnection = Get-CTXDBConnection -AdminServer $AdminServer
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Reboot Schedule Details"
		$RebootSchedule = Get-CTXRebootSchedule -AdminServer $AdminServer
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] VDA Uptime"
		$VDAUptime = Get-VDAUptime -AdminServer $AdminServer
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Session Counts Details"
		$SessionCounts = New-Object PSObject -Property @{
			'Active Sessions'       = ($Sessions | Where-Object -Property Sessionstate -EQ "Active").count
			'Disconnected Sessions' = ($Sessions | Where-Object -Property Sessionstate -EQ "Disconnected").count
			'Unregistered Servers'  = ($Machines.UnRegisteredServers | Measure-Object).count
			'Unregistered Desktops' = ($Machines.UnRegisteredDesktops | Measure-Object).count
			'Tainted Objects'       = ($ADObjects.TaintedObjects | Measure-Object).Count
		} | Select-Object 'Active Sessions', 'Disconnected Sessions', 'Unregistered Servers', 'Unregistered Desktops', 'Tainted Objects'

		$CustomCTXObject    = New-Object PSObject -Property @{
			DateCollected   = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			SiteDetails     = $SiteDetails
			Controllers     = $Controllers
			Machines        = $Machines
			Sessions        = $Sessions
			ADObjects       = $ADObjects
			DeliveryGroups  = $DeliveryGroups
			DBConnection    = $DBConnection
			SessionCounts   = $SessionCounts
			RebootSchedule  = $RebootSchedule
			VDAUptime 		= $VDAUptime
		} | Select-Object DateCollected, SiteDetails, Controllers, Machines, Sessions, ADObjects, DeliveryGroups, DBConnection, SessionCounts, RebootSchedule, VDAUptime
		$CustomCTXObject
	}

$FarmDetails = @()
if ($RunAsPSRemote -eq $true) { $FarmDetails = Invoke-Command -ComputerName $AdminServer -ScriptBlock ${Function:CitrixFarmDetails} -ArgumentList  @($AdminServer) -Credential $RemoteCredentials }
else { $FarmDetails = CitrixFarmDetails -AdminServer $AdminServer}
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [End] All Details"
	$FarmDetails | Select-Object DateCollected, SiteDetails, Controllers, Machines, Sessions, ADObjects, DeliveryGroups, DBConnection, SessionCounts, RebootSchedule, VDAUptime

} #end Function

 
Export-ModuleMember -Function Get-CitrixFarmDetail
#endregion
 
#region Get-CitrixLicenseInformation.ps1
############################################
# source: Get-CitrixLicenseInformation.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Show Citrix License details

.DESCRIPTION
Show Citrix License details

.PARAMETER AdminServer
Name of a data collector

.PARAMETER RunAsPSRemote
Credentials if running psremote 

.PARAMETER RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

.EXAMPLE
Get-CitrixLicenseInformation -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote

#>Function Get-CitrixLicenseInformation {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials,
		[Parameter(Mandatory = $false, Position = 2)]
		[switch]$RunAsPSRemote = $false)


	function get-license {
		param($AdminServer, $VerbosePreference)
		Add-PSSnapin Citrix*
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] License Details"

		$LicenseServer = Get-BrokerSite -AdminAddress $AdminServer | Select-Object LicenseServerName
		[string]$licurl = "https://" + $LicenseServer.LicenseServerName + ":8083"
		$cert = Get-LicCertificate -AdminAddress $licurl
		$ctxlic = Get-LicInventory -AdminAddress $licurl -CertHash $cert.CertHash | Where-Object { $_.LicensesInUse -ne 0 }
		$AllDetails = @()
		foreach ($lic in $ctxlic) {
			$Licenses = New-Object PSObject -Property @{
				LicenseProductName = $lic.LocalizedLicenseProductName
				LicenseModel       = $lic.LocalizedLicenseModel
				LicensesInstalled  = $lic.LicensesAvailable
				LicensesInUse      = $lic.LicensesInUse
				LicensesAvailable  = ([int]$lic.LicensesAvailable - [int]$lic.LicensesInUse)
			} | Select-Object LicenseProductName, LicenseModel, LicensesInstalled, LicensesInUse, LicensesAvailable
			$AllDetails += $Licenses
		}
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [End] License Details"
			$AllDetails
		}

	$LicDetails = @()
	if ($RunAsPSRemote -eq $true) { $LicDetails = Invoke-Command -ComputerName $AdminServer -ScriptBlock ${Function:get-license} -ArgumentList @($AdminServer, $VerbosePreference) -Credential $RemoteCredentials }
	else { $LicDetails = get-license -AdminAddress $AdminServer }
	$LicDetails | Select-Object LicenseProductName, LicenseModel, LicensesInstalled, LicensesInUse, LicensesAvailable


} #end Function

 
Export-ModuleMember -Function Get-CitrixLicenseInformation
#endregion
 
#region Get-CitrixServerEventLog.ps1
############################################
# source: Get-CitrixServerEventLog.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Get windows event log details

.DESCRIPTION
Get windows event log details

.PARAMETER Serverlist
List of server names.

.PARAMETER Days
Limit the search for only do many days.

.PARAMETER RemoteCredentials
Credentials used to connect to server remotely.

.EXAMPLE
Get-CitrixServerEventLog -Serverlist $CTXCore -Days 1 -RemoteCredentials $CTXAdmin

#>
Function Get-CitrixServerEventLog {

	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[array]$Serverlist,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int32]$Days,
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)

	function events {
  param($Server, $days, $VerbosePreference)
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Eventlog Details"

		$eventtime = (Get-Date).AddDays(-$days)
		$ctxevent = Get-WinEvent -ComputerName $server -FilterHashTable @{LogName = 'Application', 'System'; Level = 2, 3; StartTime = $eventtime } -ErrorAction SilentlyContinue | Select-Object MachineName, TimeCreated, LogName, ProviderName, Id, LevelDisplayName, Message
		$servererrors = $ctxevent | Where-Object -Property LevelDisplayName -EQ "Error"
		$serverWarning = $ctxevent | Where-Object -Property LevelDisplayName -EQ "Warning"
		$TopProfider = $ctxevent | Where-Object { $_.LevelDisplayName -EQ "Warning" -or $_.LevelDisplayName -eq "Error" } | Group-Object -Property ProviderName | Sort-Object -Property count -Descending | Select-Object Name, Count

		$CTXObject = New-Object PSObject -Property @{
			ServerName  = ([System.Net.Dns]::GetHostByName(($env:computerName))).hostname
			Errors      = $servererrors.Count
			Warning     = $serverWarning.Count
			TopProfider = $TopProfider
			All         = $ctxevent
		}
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Eventlog Details"
		$CTXObject
	}

	$Eventlogs = @()
	foreach ($server in $Serverlist) {
		$logs = Invoke-Command -ComputerName $Server -ScriptBlock ${Function:events} -ArgumentList  @($Server, $days, $VerbosePreference) -Credential $RemoteCredentials
		$Eventlogs += $logs
	}

	$Eventlogs | ForEach-Object {
		$TotalErrors = $TotalErrors + $_.Errors
		$TotalWarnings = $TotalWarnings + $_.Warning
 }
	[array]$TotalProvider += $Eventlogs | ForEach-Object { $_.TopProfider }
	[array]$TotalAll += $Eventlogs | ForEach-Object { $_.all }

	$CTXObject = New-Object PSObject -Property @{
		DateCollected = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		SingleServer  = $Eventlogs | Select-Object ServerName, Errors, Warning, TopProfider, All
		TotalErrors   = $TotalErrors
		TotalWarnings = $TotalWarnings
		TotalProvider = $TotalProvider | Sort-Object -Property count -Descending
		TotalAll      = $TotalAll
	}
	$CTXObject

} #end Function

 
Export-ModuleMember -Function Get-CitrixServerEventLog
#endregion
 
#region Get-CitrixServerPerformance.ps1
############################################
# source: Get-CitrixServerPerformance.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Combine perfmon of multiple servers for reporting.

.DESCRIPTION
Combine perfmon of multiple servers for reporting.

.PARAMETER Serverlist
List of servers to get the permon details

.PARAMETER RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

.EXAMPLE
Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin
#>	
Function Get-CitrixServerPerformance {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[array]$Serverlist,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)

	$CitrixServerPerformance = @()
	foreach ($Server in $Serverlist) {
		$SingleServer = Get-CitrixSingleServerPerformance -Server $Server -RemoteCredentials $RemoteCredentials
		$CusObject = New-Object PSObject -Property @{
			DateCollected      = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			Servername         = $SingleServer.ServerName
			'CPU %'            = $SingleServer.'CPU %'
			'Memory %'         = $SingleServer.'Memory %'
			'CDrive % Free'    = $SingleServer.'CDrive % Free'
			'DDrive % Free'    = $SingleServer.'DDrive % Free'
			Uptime             = $SingleServer.Uptime
			'Stopped Services' = $SingleServer.StoppedServices
		} | Select-Object ServerName, 'CPU %', 'Memory %', 'CDrive % Free', 'DDrive % Free', Uptime, 'Stopped Services'
		$CitrixServerPerformance += $CusObject
	}

	$CitrixServerPerformance
} #end Function

 
Export-ModuleMember -Function Get-CitrixServerPerformance
#endregion
 
#region Get-CitrixSingleServerPerformance.ps1
############################################
# source: Get-CitrixSingleServerPerformance.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Get perfmon statistics

.DESCRIPTION
Get perfmon statistics

.PARAMETER Server
Server to get the permon details

.PARAMETER RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

.EXAMPLE
Get-CitrixSingleServerPerformance -Server ddc01 -RemoteCredentials $CTXAdmin
#>	
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Server,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Performance Details for $($server.ToString())"

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Perfmon Details for $($server.ToString())"
	$perf = Invoke-Command -ComputerName $Server -ScriptBlock	{
		$CtrList = @(
			"\Processor(_Total)\% Processor Time",
			"\memory\% committed bytes in use",
			"\LogicalDisk(C:)\% Free Space",
			"\LogicalDisk(D:)\% Free Space"
		)
			Get-Counter $CtrList -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples
	} -Credential $RemoteCredentials

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Services Details for $($server.ToString())"
	$services = Invoke-Command -ComputerName $Server -ScriptBlock	{
		Get-Service citrix* | Where-Object { ($_.starttype -eq "Automatic" -and $_.status -eq "Stopped") }
	} -Credential $RemoteCredentials
	if ([bool]$Services.DisplayName -eq $true) { $ServicesJoin = [String]::Join(';', $Services.DisplayName) }
		else { $ServicesJoin = '' }

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Uptime Details for $($server.ToString())"
	$OS = Invoke-Command -ComputerName $Server -ScriptBlock	{ Get-CimInstance Win32_OperatingSystem | Select-Object * } -Credential $RemoteCredentials
	$Uptime = (Get-Date) - ($OS.LastBootUpTime)
	$updays = [math]::Round($uptime.Days, 0)

	$CTXObject = New-Object PSCustomObject -Property @{
		DateCollected      = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		ServerName         = $Server
		'CPU %'            = [Decimal]::Round(($perf[0].CookedValue), 2).tostring()
		'Memory %'         = [Decimal]::Round(($perf[1].CookedValue), 2).tostring()
		'CDrive % Free'    = [Decimal]::Round(($perf[2].CookedValue), 2).tostring()
		'DDrive % Free'    = [Decimal]::Round(($perf[3].CookedValue), 2).tostring()
		Uptime             = $updays.tostring()
		'Stopped Services' = $ServicesJoin
	} | Select-Object ServerName, 'CPU %', 'Memory %', 'CDrive % Free', 'DDrive % Free', Uptime, 'Stopped Services'
	$CTXObject
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Performance Details for $($server.ToString())"

} #end Function

 
Export-ModuleMember -Function Get-CitrixSingleServerPerformance
#endregion
 
#region Get-CitrixWebsiteStatus.ps1
############################################
# source: Get-CitrixWebsiteStatus.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Get the status of a website

.DESCRIPTION
Get the status of a website

.PARAMETER Websitelist
List of websites to check

.EXAMPLE
Get-CitrixWebsiteStatus -Websitelist 'https://store.example.com'

#>
Function Get-CitrixWebsiteStatus {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[array]$Websitelist)

	$websites = @()
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Website Details"

	foreach ($web in $Websitelist) {
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		$WebResponse = Invoke-WebRequest -Uri $web -UseBasicParsing | Select-Object -Property StatusCode, StatusDescription

		$CTXObject = New-Object PSObject -Property @{
			"WebSite Name"    = $web
			StatusCode        = $WebResponse.StatusCode
			StatusDescription = $WebResponse.StatusDescription
		}
		$websites += $CTXObject
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Website Details"

	$websites | Select-Object  "WebSite Name" , StatusCode, StatusDescription



} #end Function

 
Export-ModuleMember -Function Get-CitrixWebsiteStatus
#endregion
 
#region Get-RDSLicenseInformation.ps1
############################################
# source: Get-RDSLicenseInformation.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Report on RDS License Useage

.DESCRIPTION
Report on RDS License Useage

.PARAMETER LicenseServer
Name of a RDS License Server

.PARAMETER RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

.EXAMPLE
Get-RDSLicenseInformation -LicenseServer $RDSLicenseServer  -RemoteCredentials $CTXAdmin

#>
Function Get-RDSLicenseInformation {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$LicenseServer,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] RDS Details"
	$RDSLicense = Invoke-Command -ComputerName $LicenseServer -Credential $RemoteCredentials -ScriptBlock { Get-CimInstance Win32_TSLicenseKeyPack -ErrorAction SilentlyContinue | Select-Object -Property TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses }
	$CTXObject = New-Object PSObject -Property @{
		"Per Device" = $RDSLicense | Where-Object { $_.TypeAndModel -eq "RDS Per Device CAL" }
		"Per User"   = $RDSLicense | Where-Object { $_.TypeAndModel -eq "RDS Per User CAL" }
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] RDS Details"
	$CTXObject



} #end Function

 
Export-ModuleMember -Function Get-RDSLicenseInformation
#endregion
 
#region Get-StoreFrontDetail.ps1
############################################
# source: Get-StoreFrontDetail.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Report on Storefront status.

.DESCRIPTION
Report on Storefront status.

.PARAMETER StoreFrontServer
Name of a storefront server

.PARAMETER RunAsPSRemote
Credentials if running psremote 

.PARAMETER RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

.EXAMPLE
Get-StoreFrontDetail -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote

#>Function Get-StoreFrontDetail {
	[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$StoreFrontServer,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$RemoteCredentials,
        [Parameter(Mandatory = $false, Position = 2)]
        [switch]$RunAsPSRemote = $false)

    function AllConfig {
        param($StoreFrontServer, $VerbosePreference)

        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Storefront Details"
        $SiteArray = @()
        Add-PSSnapin citrix*

        # Set Proxy
        $wc = New-Object System.Net.WebClient
        $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Store Details"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $WebObject = New-Object PSObject -Property @{
            InternalStore                  = (Get-STFServerGroup | Select-Object -ExpandProperty HostBaseUrl).AbsoluteUri
            InternalStoreStatus            = (Invoke-WebRequest -Uri ((Get-STFServerGroup | Select-Object -ExpandProperty HostBaseUrl).AbsoluteUri) -UseBasicParsing) | ForEach-Object { $_.StatusDescription }
            ReplicationSource              = (Get-ItemProperty  HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication -Name LastSourceServer).LastSourceServer
            SyncState                      = (Get-ItemProperty  HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication -Name LastUpdateStatus).LastUpdateStatus
            EndSyncDate                    = (((Get-ItemProperty  HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication -Name LastEndTime).LastEndTime).split(".")[0]).replace("T"," ")

        } | Select-Object InternalStore, InternalStoreStatus,ReplicationSource,SyncState,EndSyncDate
        $SiteArray =  $WebObject.psobject.Properties | Select-Object -Property Name, Value


        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Server Details"
        $SFGroup = Get-STFServerGroup | Select-Object -ExpandProperty ClusterMembers
        $SFServers = @()
        foreach ($SFG in $SFGroup) {
            $CusObject = New-Object PSObject -Property @{
                ComputerName = ([System.Net.Dns]::GetHostByName(($SFG.Hostname))).Hostname
                IsLive       = $SFG.IsLive
            } | Select-Object ComputerName, IsLive
            $SFServers += $CusObject
        }
        #####
        $Details = New-Object PSObject -Property @{
            DateCollected         = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
            SiteDetails           = $SiteArray
            ServerDetails         = $SFServers

        } | Select-Object DateCollected,SiteDetails, ServerDetails
        $Details
        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending] StoreFront Details"

    }
        $FarmDetails = @()
        if ($RunAsPSRemote -eq $true) { $FarmDetails = Invoke-Command -ComputerName $StoreFrontServer -ScriptBlock ${Function:AllConfig} -ArgumentList  @($StoreFrontServer, $VerbosePreference) -Credential $RemoteCredentials }
        else { $FarmDetails = AllConfig -StoreFrontServer $StoreFrontServer }
        Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [End] All Details"
        $FarmDetails | select-object DateCollected,SiteDetails,ServerDetails

    } #end Function

 
Export-ModuleMember -Function Get-StoreFrontDetail
#endregion
 
#region Get-CitrixObjects.ps1
############################################
# source: Get-CitrixObjects.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Get details of citrix objects

.DESCRIPTION
Get details of citrix objects. (Catalog, Delivery group and published apps)

.PARAMETER AdminServer
Name of a data collector

.PARAMETER RunAsPSRemote
Credentials if running psremote 

.PARAMETER RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

.EXAMPLE
Get-CitrixObjects -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote

#>
Function Get-CitrixObjects {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $false, Position = 2)]
		[switch]$RunAsPSRemote = $false,
		[Parameter(Mandatory = $false, Position = 3)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)


	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Config"
	Function GetAllConfig {
		[CmdletBinding()]
		param($AdminServer)

		Add-PSSnapin citrix*
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Machine Catalogs"
		$CTXMachineCatalog = @()
		$MachineCatalogs = Get-BrokerCatalog -AdminAddress $AdminServer
		foreach ($MachineCatalog in $MachineCatalogs) {
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Machine Catalog: $($MachineCatalog.name.ToString())"
			$MasterImage = Get-ProvScheme -AdminAddress $AdminServer | Where-Object -Property IdentityPoolName -Like $MachineCatalog.Name
			if ($MasterImage.MasterImageVM -notlike '') {
				$MasterImagesplit = ($MasterImage.MasterImageVM).Split("\")
				$masterSnapshotcount = ($MasterImagesplit | Where-Object { $_ -like '*.snapshot' }).count
				$mastervm = ($MasterImagesplit | Where-Object { $_ -like '*.vm' }).Replace(".vm", '')
				if ($masterSnapshotcount -gt 1) { $masterSnapshot = ($MasterImagesplit | Where-Object { $_ -like '*.snapshot' })[-1].Replace(".snapshot", '') }
				else { $masterSnapshot = ($MasterImagesplit | Where-Object { $_ -like '*.snapshot' }).Replace(".snapshot", '') }
			} else {
				$mastervm = ''
				$masterSnapshot = ''
				$masterSnapshotcount = 0
			}
			$CatObject = New-Object PSObject -Property @{
				MachineCatalogName           = $MachineCatalog.name
				AllocationType               = $MachineCatalog.AllocationType
				Description                  = $MachineCatalog.Description
				IsRemotePC                   = $MachineCatalog.IsRemotePC
				MachinesArePhysical          = $MachineCatalog.MachinesArePhysical
				MinimumFunctionalLevel       = $MachineCatalog.MinimumFunctionalLevel
				PersistUserChanges           = $MachineCatalog.PersistUserChanges
				ProvisioningType             = $MachineCatalog.ProvisioningType
				SessionSupport               = $MachineCatalog.SessionSupport
				Uid                          = $MachineCatalog.Uid
				UnassignedCount              = $MachineCatalog.UnassignedCount
				UsedCount                    = $MachineCatalog.UsedCount
				CleanOnBoot                  = $MasterImage.CleanOnBoot
				MasterImageVM                = $mastervm
				MasterImageSnapshotName      = $masterSnapshot
				MasterImageSnapshotCount     = $masterSnapshotcount
				MasterImageVMDate            = $MasterImage.MasterImageVMDate
				UseFullDiskCloneProvisioning = $MasterImage.UseFullDiskCloneProvisioning
				UseWriteBackCache            = $MasterImage.UseWriteBackCache
			} | Select-Object MachineCatalogName, AllocationType, Description, IsRemotePC, MachinesArePhysical, MinimumFunctionalLevel, PersistUserChanges, ProvisioningType, SessionSupport, Uid, UnassignedCount, UsedCount, CleanOnBoot, MasterImageVM, MasterImageSnapshotName, MasterImageSnapshotCount, MasterImageVMDate, UseFullDiskCloneProvisioning, UseWriteBackCache
			$CTXMachineCatalog += $CatObject
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Delivery Groups"
		$BrokerDesktopGroup = Get-BrokerDesktopGroup -AdminAddress $AdminServer
		$CTXDeliveryGroup = @()
		foreach ($DesktopGroup in $BrokerDesktopGroup) {
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DesktopGroup.name.ToString())"
			$BrokerAccess = @()
			$BrokerGroups = @()
			$BrokerAccess = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike "" } } | Select-Object UPN
			$BrokerGroups = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | Select-Object Name
			$CusObject = New-Object PSObject -Property @{
				DesktopGroupName       = $DesktopGroup.name
				Uid                    = $DesktopGroup.uid
				DeliveryType           = $DesktopGroup.DeliveryType
				DesktopKind            = $DesktopGroup.DesktopKind
				Description            = $DesktopGroup.Description
				DesktopsDisconnected   = $DesktopGroup.DesktopsDisconnected
				DesktopsFaulted        = $DesktopGroup.DesktopsFaulted
				DesktopsInUse          = $DesktopGroup.DesktopsInUse
				DesktopsUnregistered   = $DesktopGroup.DesktopsUnregistered
				Enabled                = $DesktopGroup.Enabled
				IconUid                = $DesktopGroup.IconUid
				InMaintenanceMode      = $DesktopGroup.InMaintenanceMode
				SessionSupport         = $DesktopGroup.SessionSupport
				TotalApplicationGroups = $DesktopGroup.TotalApplicationGroups
				TotalApplications      = $DesktopGroup.TotalApplications
				TotalDesktops          = $DesktopGroup.TotalDesktops
				Tags                   = @(($DesktopGroup.Tags) | Out-String).Trim()
				UserAccess             = @(($BrokerAccess.UPN) | Out-String).Trim()
				GroupAccess            = @(($BrokerGroups.Name) | Out-String).Trim()
			} | Select-Object DesktopGroupName, Uid, DeliveryType, DesktopKind, Description, DesktopsDisconnected, DesktopsFaulted, DesktopsInUse, DesktopsUnregistered, Enabled, IconUid, InMaintenanceMode, SessionSupport, TotalApplicationGroups, TotalApplications, TotalDesktops, Tags, UserAccess, GroupAccess
			$CTXDeliveryGroup += $CusObject
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Application config"
		$HostedApps = @()
		foreach ($DeskG in ($CTXDeliveryGroup | Where-Object { $_.DeliveryType -like 'DesktopsAndApps' })) {
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DeskG.DesktopGroupName.ToString())"
			$PublishedApps = Get-BrokerApplication -AssociatedDesktopGroupUid $DeskG.Uid -AdminAddress $AdminServer
			#			$PublishedApp = (Get-BrokerApplication -AdminAddress $AdminServer)[27]
			foreach ($PublishedApp in $PublishedApps) {
				Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Published Application: $($DeskG.DesktopGroupName.ToString()) - $($PublishedApp.PublishedName.ToString())"
				[System.Collections.ArrayList]$PublishedAppGroup = @()
				[System.Collections.ArrayList]$PublishedAppUser = @($PublishedApp.AssociatedUserNames | Where-Object { $_ -notlike $null })
				$index = 0
				foreach ($upn in $PublishedApp.AssociatedUserNames) {
					if ($null -like $upn) { $PublishedAppGroup += @($PublishedApp.AssociatedUserNames)[$index] }
					$index ++
				}
				$CusObject = New-Object PSObject -Property @{
					DesktopGroupName        = $DeskG.DesktopGroupName
					DesktopGroupUid         = $DeskG.Uid
					DesktopGroupUsersAccess = $DeskG.UserAccess
					DesktopGroupGroupAccess = $DeskG.GroupAccess
					ApplicationName         = $PublishedApp.ApplicationName
					ApplicationType         = $PublishedApp.ApplicationType
					AdminFolderName         = $PublishedApp.AdminFolderName
					ClientFolder            = $PublishedApp.ClientFolder
					Description             = $PublishedApp.Description
					Enabled                 = $PublishedApp.Enabled
					CommandLineExecutable   = $PublishedApp.CommandLineExecutable
					CommandLineArguments    = $PublishedApp.CommandLineArguments
					WorkingDirectory        = $PublishedApp.WorkingDirectory
					Tags                    = @(($PublishedApp.Tags) | Out-String).Trim()
					PublishedName           = $PublishedApp.PublishedName
					PublishedAppName        = $PublishedApp.Name
					PublishedAppGroupAccess = @(($PublishedAppGroup) | Out-String).Trim()
					PublishedAppUserAccess  = @(($PublishedAppUser) | Out-String).Trim()
				} | Select-Object DesktopGroupName, DesktopGroupUid, DesktopGroupUsersAccess, DesktopGroupGroupAccess, ApplicationName, ApplicationType, AdminFolderName, ClientFolder, Description, Enabled, CommandLineExecutable, CommandLineArgument, WorkingDirectory, Tags, PublishedName, PublishedAppName, PublishedAppGroupAccess, PublishedAppUserAccess
				$HostedApps += $CusObject
			}
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Server Details"
		$VDAServers = @()
		Get-BrokerMachine  -AdminAddress $AdminServer -MaxRecordCount 100000 | Where-Object { $_.OSType -like "Windows 20*" } | ForEach-Object {
			$VDASCusObject = New-Object PSObject -Property @{
				DNSName           = $_.DNSName
				CatalogName       = $_.CatalogName
				DesktopGroupName  = $_.DesktopGroupName
				IPAddress         = $_.IPAddress
				AgentVersion      = $_.AgentVersion
				OSType            = $_.OSType
				RegistrationState = $_.RegistrationState
				InMaintenanceMode = $_.InMaintenanceMode
			} | Select-Object DNSName, CatalogName, DesktopGroupName, IPAddress, AgentVersion, OSType, RegistrationState, InMaintenanceMode
			$VDAServers += $VDASCusObject
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Workstation Details"
		$VDAWorkstations = @()
		Get-BrokerMachine  -AdminAddress $AdminServer -MaxRecordCount 100000 | Where-Object { $_.OSType -notlike "Windows 20*" } | ForEach-Object {
			$VDAWCusObject = New-Object PSObject -Property @{
				DNSName             = $_.DNSName
				CatalogName         = $_.CatalogName
				DesktopGroupName    = $_.DesktopGroupName
				IPAddress           = $_.IPAddress
				AgentVersion        = $_.AgentVersion
				AssociatedUserNames = @(($_.AssociatedUserNames) | Out-String).Trim()
				OSType              = $_.OSType
				RegistrationState   = $_.RegistrationState
				InMaintenanceMode   = $_.InMaintenanceMode
			} | Select-Object DNSName, CatalogName, DesktopGroupName, IPAddress, AgentVersion, AssociatedUserNames, OSType, RegistrationState, InMaintenanceMode
			$VDAWorkstations += $VDAWCusObject
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Published Applications"

		$CusObject = New-Object PSObject -Property @{
			DateCollected   = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			MachineCatalog  = $CTXMachineCatalog
			DeliveryGroups  = $CTXDeliveryGroup
			PublishedApps   = $HostedApps
			VDAServers      = $VDAServers
			VDAWorkstations = $VDAWorkstations
		}
		$CusObject
	}

	$AppDetail = @()
	if ($RunAsPSRemote -eq $true) { $AppDetail = Invoke-Command -ComputerName $AdminServer -ScriptBlock ${Function:GetAllConfig} -ArgumentList  @($AdminServer) -Credential $RemoteCredentials }
	else { $AppDetail = GetAllConfig -AdminServer $AdminServer }
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] All Details"
	$AppDetail | Select-Object DateCollected, MachineCatalog, DeliveryGroups, PublishedApps, VDAServers, VDAWorkstations
} #end Function



 
Export-ModuleMember -Function Get-CitrixObjects
#endregion
 
#region Start-CitrixAudit.ps1
############################################
# source: Start-CitrixAudit.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
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

	$HeadingText = $DashboardTitle + " | XenDesktop Audit | " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
	New-HTML -TitleText "XenDesktop Audit"  -FilePath $Reportname {
		New-HTMLLogo -RightLogoString $XDHealth_LogoURL
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
		New-HTMLSection @SectionSettings  -Content {
			New-HTMLSection -HeaderText 'Machine Catalogs' @TableSectionSettings { New-HTMLTable @TableSettings  -DataTable $MachineCatalog }
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
		$AllXDData.MachineCatalog | Export-Excel -Path $ExcelReportname -WorksheetName MachineCatalog -AutoSize  -Title "Citrix Machine Catalog" -TitleBold -TitleSize 20 -FreezePane 3
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
		$emailTo | ForEach-Object { $emailMessage.To.Add($_) }

		$emailMessage.Subject = $DashboardTitle + " - Citrix Audit Results Report on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)
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


 
Export-ModuleMember -Function Start-CitrixAudit
#endregion
 
#region Start-CitrixHealthCheck.ps1
############################################
# source: Start-CitrixHealthCheck.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
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
	[array]$CTXControllers = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerController | Select-Object dnsname } | ForEach-Object { $_.dnsname }
	[array]$CTXLicenseServer = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerSite -AdminAddress $AdminServer | Select-Object LicenseServerName } | ForEach-Object { $_.LicenseServerName }
	[array]$CTXStoreFrontFarm = Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-STFServerGroup | Select-Object -ExpandProperty ClusterMembers | Select-Object hostname | ForEach-Object { ([System.Net.Dns]::GetHostByName(($_.hostname))).Hostname } }
	$CTXCore = @()
	$CTXCore = $CTXControllers + $CTXStoreFrontFarm + $CTXLicenseServer | Sort-Object -Unique
	#endregion

	########################################
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting License Details"
	$CitrixLicenseInformation = Get-CitrixLicenseInformation -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
	$CitrixRemoteFarmDetails = Get-CitrixFarmDetail -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Eventlog Details"
	$CitrixServerEventLogs = Get-CitrixServerEventLog -Serverlist $CTXCore -Days 1 -RemoteCredentials $CTXAdmin
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting RDS Details"
	$RDSLicenseInformation = Get-RDSLicenseInformation -LicenseServer $RDSLicenseServer  -RemoteCredentials $CTXAdmin | ForEach-Object { $_.$RDSLicenseType } | Where-Object { $_.TotalLicenses -ne 4294967295 } | Select-Object TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Config changes Details"
	$CitrixConfigurationChanges = Get-CitrixConfigurationChange -AdminServer $CTXDDC -Indays 7 -RemoteCredentials $CTXAdmin
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Storefront Details"
	$StoreFrontDetails = Get-StoreFrontDetail -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Server Performance Details"
	$ServerPerformance = Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin
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

		$CitrixServerEventLogs.SingleServer | Where-Object Errors -gt 100 | ForEach-Object { $RedFlags += $_.'ServerName' + " have " + $_.Errors + " errors in the last 24 hours" }
		$ServerPerformance | Where-Object 'Stopped Services' -ne $null | ForEach-Object { $RedFlags += $_.Servername + " has stopped Citrix Services" }
		foreach ($server in $ServerPerformance) {
			if ([int]$server.'CDrive % Free' -lt 10) { $RedFlags += $server.Servername + " has only " + $server.'CDrive % Free' + " % free disk space on C Drive" }
			if ([int]$server.'DDrive % Free' -lt 10) { $RedFlags += $server.Servername + " has only " + $server.'DDrive % Free' + " % free disk space on D Drive" }
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
			New-HTMLSection -HeaderText 'Citrix Error Counts' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  ($CitrixServerEventLogs.SingleServer | Select-Object ServerName, Errors, Warning) $Conditions_events }
			New-HTMLSection -HeaderText 'Citrix Events Top Events' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count) }
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
 
Export-ModuleMember -Function Start-CitrixHealthCheck
#endregion
 
#region Import-ParametersFile.ps1
############################################
# source: Import-ParametersFile.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Import the config file and creates the needed variables

.DESCRIPTION
Import the config file and creates the needed variables

.PARAMETER JSONParameterFilePath
Path to the json config file, created by Install-ParametersFile

.PARAMETER RedoCredentials
Deletes the saved credentials, and allow you to recreate them.

.EXAMPLE
Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath

#>
Function Import-ParametersFile {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + '\Parameters.json',
		[Parameter(Mandatory = $false, Position = 1)]
		[switch]$RedoCredentials = $false
	)

	$JSONParameter = Get-Content ($JSONParameterFilePath) | ConvertFrom-Json
	if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }

	Write-Colour 'Using Variables from Parameters.json: ', $JSONParameterFilePath.ToString() -ShowTime -Color DarkCyan, DarkYellow -LinesAfter 1
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
	$JSONParameter.PSObject.Properties | Where-Object { $_.name -notlike 'TrustedDomains' } | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime; New-Variable -Name $_.name -Value $_.value -Force -Scope global }
	New-Variable -Name 'JSONParameterFilePath' -Value $JSONParameterFilePath -Scope global -Force

	# Write-Colour "Creating credentials for Trusted domains:" -ShowTime -Color DarkCyan -LinesBefore 2
	# $Global:Trusteddomains = @()
	# foreach ($domain in $JSONParameter.TrustedDomains) {
	# 	$serviceaccount = Find-Credential | Where-Object target -Like ("*" + $domain.Description.tostring()) | Get-Credential -Store
	# 	if ($null -eq $serviceaccount) {
	# 		$serviceaccount = BetterCredentials\Get-Credential -Message ("Service Account for domain: " + $domain.NetBiosName.ToString())
	# 		Set-Credential -Credential $serviceaccount -Target $domain.Description.ToString() -Persistence LocalComputer -Description ("Service Account for domain: " + $domain.NetBiosName.ToString())
	# 	}
	# 	Write-Color -Text $domain.FQDN, ":", $serviceaccount.username  -Color Yellow, DarkCyan, Green -ShowTime
	# 	$CusObject = New-Object PSObject -Property @{
	# 		FQDN        = $domain.FQDN
	# 		Credentials = $serviceaccount
	# 	}
	# 	$Global:Trusteddomains += $CusObject
	# }
	$global:CTXAdmin = Find-Credential | Where-Object target -Like '*CTXAdmin' | Get-Credential -Store
	if ($null -eq $CTXAdmin) {
		$AdminAccount = BetterCredentials\Get-Credential -Message 'Admin Account: DOMAIN\Username for CTX Admin'
		Set-Credential -Credential $AdminAccount -Target 'CTXAdmin' -Persistence LocalComputer -Description 'Account used for Citrix queries' -Verbose
	}

	# $global:NSAdmin = Find-Credential | Where-Object target -Like "*NSAdmin" | Get-Credential -Store
	# if ($null -eq $CTXAdmin) {
	# 	$NSAccount = BetterCredentials\Get-Credential -Message "Admin Account for Netscaler"
	# 	Set-Credential -Credential $NSAccount -Target "NSAdmin" -Persistence LocalComputer -Description "Account used for Citrix Netscaler" -Verbose
	# }
	# Write-Colour "Netscaler Admin Credentials: ", $NSAdmin.UserName -ShowTime -Color yellow, Green -LinesBefore 1
	Write-Colour 'Citrix Admin Credentials: ', $CTXAdmin.UserName -ShowTime -Color yellow, Green

	if ($SendEmail) {
		$global:SMTPClientCredentials = Find-Credential | Where-Object target -Like '*Healthcheck_smtp' | Get-Credential -Store
		if ($null -eq $SMTPClientCredentials) {
			$Account = BetterCredentials\Get-Credential -Message 'smtp login for HealthChecks email'
			Set-Credential -Credential $Account -Target 'Healthcheck_smtp' -Persistence LocalComputer -Description 'Account used for XD health checks' -Verbose
		}
		Write-Colour 'SMTP Credentials: ', $SMTPClientCredentials.UserName -ShowTime -Color yellow, Green -LinesBefore 2

	}

	if ($RedoCredentials) {
		foreach ($domain in $JSONParameter.TrustedDomains) { Find-Credential | Where-Object target -Like ('*' + $domain.Description.tostring()) | Remove-Credential -Verbose }
		Find-Credential | Where-Object target -Like '*CTXAdmin' | Remove-Credential -Verbose
		Find-Credential | Where-Object target -Like '*NSAdmin' | Remove-Credential -Verbose
	}

} #end Function

 
Export-ModuleMember -Function Import-ParametersFile
#endregion
 
#region Install-CTXPSModule.ps1
############################################
# source: Install-CTXPSModule.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
	<#
.SYNOPSIS
Checks and installs needed modules

.DESCRIPTION
Checks and installs needed modules

.PARAMETER ModuleList
Path to json file.

.PARAMETER ForceInstall
Force reinstall of modules

.PARAMETER UpdateModules
Check for updates for the modules

.PARAMETER RemoveAll
Remove the modules

.EXAMPLE
Install-CTXPSModule -ModuleList 'C:\Temp\modules.json'

#>
Function Install-CTXPSModule {
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$ModuleList = (Join-Path -Path ((Get-Module XDHealthCheck).ModuleBase).ToString() -ChildPath Private\modulelist.json),
		[switch]$ForceInstall = $false,
		[switch]$UpdateModules = $false,
		[switch]$RemoveAll = $false
	)

	$mods = Get-Content $ModuleList | ConvertFrom-Json
	if ($RemoveAll) {
		try {
			$mods | ForEach-Object { Write-Host 'Uninstalling Module:' -ForegroundColor Cyan -NoNewline;Write-Host $_.Name -ForegroundColor red
				Get-Module -Name $_.Name -ListAvailable | Uninstall-Module -AllVersions -Force
			}
		}
		catch { Write-Error "Error Uninstalling $($mod.Name)" }
	}
	if ($UpdateModules) {
		try {
			$mods | ForEach-Object { Write-Host 'Updating Module:' -ForegroundColor Cyan -NoNewline;Write-Host $_.Name -ForegroundColor yello
				Get-Module -Name $_.Name -ListAvailable | Select-Object -First 1 | Update-Module -Force
			}
		}
		catch { Write-Error "Error Updating $($mod.Name)" }
	}

	foreach ($mod in $mods) {
		if ($ForceInstall -eq $false) { $PSModule = Get-Module -Name $mod.Name -ListAvailable | Select-Object -First 1 }
		if ($PSModule.Name -like '') {
			Write-Host 'Installing Module:' -ForegroundColor Cyan -NoNewline
			Write-Host $mod.Name -ForegroundColor Yellow
			Install-Module -Name $mod.Name -Scope AllUsers -AllowClobber -Force
		}
		else {
			Write-Host 'Using Installed Module:' -ForegroundColor Cyan -NoNewline
			Write-Host $PSModule.Name - $PSModule.Path -ForegroundColor Yellow
		}
	}
}
 
Export-ModuleMember -Function Install-CTXPSModule
#endregion
 
#region Install-ParametersFile.ps1
############################################
# source: Install-ParametersFile.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Create a json config file with all needed farm details.

.DESCRIPTION
Create a json config file with all needed farm details.

.EXAMPLE
Install-ParametersFile

#>
function Install-ParametersFile {

	[Cmdletbinding()]
	param ()
	try {
		$wc = New-Object System.Net.WebClient 
		$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials 
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

		$null = Install-PackageProvider Nuget -Force
		$null = Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

		Write-Host 'PSGalary:' -ForegroundColor Cyan -NoNewline
		Write-Host 'Succsessfull' -ForegroundColor Yellow

	}
	catch { Write-Error 'Unable to setup PSGallery ' }
	finally { Write-Error 'Unable to setup PSGallery' }

	Install-CTXPSModule

	[string]$CTXDDC = Read-Host 'A Citrix Data Collector FQDN'
	[string]$CTXStoreFront = Read-Host 'A Citrix StoreFront FQDN'
	[string]$RDSLicenseServer = Read-Host 'RDS LicenseServer FQDN'

	Write-Color -Text 'Add RDS License Type' -Color DarkGray -LinesAfter 1
	Write-Color '1: ', 'Per Device' -Color Yellow, Green
	Write-Color '2: ', 'Per User' -Color Yellow, Green
	$selection = Read-Host 'Please make a selection'
	switch ($selection) {
		'1' { [string]$RDSLicenseType = 'Per Device' }
		'2' { [string]$RDSLicenseType = 'Per User' }
	}
	$trusteddomains = @()
	$ClientInput = ''
	While ($ClientInput -ne 'n') {
		If ($null -ne $ClientInput) {
			$FQDN = Read-Host 'FQDN for the domain'
			$NetBiosName = Read-Host 'Net Bios Name for Domain '
			$CusObject = New-Object PSObject -Property @{
				FQDN        = $FQDN
				NetBiosName = $NetBiosName
				Description = $NetBiosName + '_ServiceAccount'
			} | Select-Object FQDN, NetBiosName, Description
			$trusteddomains += $CusObject
			$ClientInput = Read-Host 'Add more trusted domains? (y/n)'
		}
	}
	<#
		$CTXNS = @()
		$ClientInput = ''
		While ($ClientInput -ne 'n') {
			If ($ClientInput -ne $null) {
				$CusObject = New-Object PSObject -Property @{
					NSIP    = Read-Host 'Netscaler IP (Management)'
					NSAdmin = Read-Host 'Root Username'
				} | Select-Object NSIP, NSAdmin
				$CTXNS += $CusObject
				$ClientInput = Read-Host 'Add more Netscalers? (y/n)'
			}
		}#>
	$ReportsFolder = Read-Host 'Path to the Reports Folder'
	$ParametersFolder = Read-Host 'Path to where the Parameters.json will be saved'
	$DashboardTitle = Read-Host 'Title to be used in the reports and Dashboard'
	$RemoveOldReports = Read-Host 'Remove Reports older than (in days)'

	Write-Color -Text 'Save reports to an excel report' -Color DarkGray -LinesAfter 1
	Write-Color '1: ', 'Yes' -Color Yellow, Green
	Write-Color '2: ', 'No' -Color Yellow, Green
	$selection = Read-Host 'Please make a selection'
	switch ($selection) {
		'1' { $SaveExcelReport = $true }
		'2' { $SaveExcelReport = $false }
	}

	Write-Color -Text 'Send Report via email' -Color DarkGray -LinesAfter 1
	Write-Color '1: ', 'Yes' -Color Yellow, Green
	Write-Color '2: ', 'No' -Color Yellow, Green
	$selection = Read-Host 'Please make a selection'
	switch ($selection) {
		'1' { $SendEmail = $true }
		'2' { $SendEmail = $false }
	}

	if ($SendEmail -eq 'true') {
		$emailFromA = Read-Host 'Email Address of the Sender'
		$emailFromN = Read-Host 'Full Name of the Sender'
		$FromAddress = $emailFromN + ' <' + $emailFromA + '>'

		$ToAddress = @()
		$ClientInput = ''
		While ($ClientInput -ne 'n') {
			If ($null -ne $ClientInput) {
				$emailtoA = Read-Host 'Email Address of the Recipient'
				$emailtoN = Read-Host 'Full Name of the Recipient'
				$ToAddress += $emailtoN + ' <' + $emailtoA + '>'
			}
			$ClientInput = Read-Host 'Add more recipients? (y/n)'
		}

		$smtpServer = Read-Host 'IP or name of SMTP server'
		$smtpServerPort = Read-Host 'Port of SMTP server'
		Write-Color -Text 'Use ssl for SMTP' -Color DarkGray -LinesAfter 1
		Write-Color '1: ', 'Yes' -Color Yellow, Green
		Write-Color '2: ', 'No' -Color Yellow, Green
		$selection = Read-Host 'Please make a selection'
		switch ($selection) {
			'1' { $smtpEnableSSL = $true }
			'2' { $smtpEnableSSL = $false }
		}
	}
	$AllXDData = New-Object PSObject -Property @{
		DateCollected    = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		CTXDDC           = $CTXDDC
		CTXStoreFront    = $CTXStoreFront
		RDSLicenseServer = $RDSLicenseServer
		RDSLicenseType   = $RDSLicenseType
		TrustedDomains   = $trusteddomains
		ReportsFolder    = $ReportsFolder
		ParametersFolder = $ParametersFolder
		DashboardTitle   = $DashboardTitle
		RemoveOldReports = $RemoveOldReports
		SaveExcelReport  = $SaveExcelReport
		SendEmail        = $SendEmail
		EmailFrom        = $FromAddress
		EmailTo          = $ToAddress
		SMTPServer       = $smtpServer
		SMTPServerPort   = $smtpServerPort
		SMTPEnableSSL    = $smtpEnableSSL
	} | Select-Object DateCollected, CTXDDC , CTXStoreFront , RDSLicenseServer , RDSLicenseType, TrustedDomains , ReportsFolder , ParametersFolder , DashboardTitle, RemoveOldReports, SaveExcelReport , SendEmail , EmailFrom , EmailTo , SMTPServer , SMTPServerPort , SMTPEnableSSL

	if (Test-Path -Path "$ParametersFolder\Parameters.json") { Rename-Item "$ParametersFolder\Parameters.json" -NewName "Parameters_$(Get-Date -Format ddMMyyyy_HHmm).json" }
	else { $AllXDData | ConvertTo-Json -Depth 5 | Out-File -FilePath "$ParametersFolder\Parameters.json" -Force -Verbose }

	Import-ParametersFile -JSONParameterFilePath "$ParametersFolder\Parameters.json"

	Write-Color 'Testing PS Remote on needed servers:' -Color Cyan -LinesBefore 2 -ShowTime
	try {
		Write-Color 'DDC' -Color Yellow -ShowTime
		Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock { $env:COMPUTERNAME }
		Write-Color 'Storefront' -Color Yellow -ShowTime
		Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { $env:COMPUTERNAME }
		Write-Color 'RDS License Server' -Color Yellow -ShowTime
		Invoke-Command -ComputerName $RDSLicenseServer -Credential $CTXAdmin -ScriptBlock { $env:COMPUTERNAME }
	}
 catch { Write-Warning 'Please setup ps remoting to the DDC, StoreFront and RDS license server ' }
        


}



 
Export-ModuleMember -Function Install-ParametersFile
#endregion
 
#region Set-XDHealthReportColors.ps1
############################################
# source: Set-XDHealthReportColors.ps1
# Module: XDHealthCheck
# version: 0.2.13
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Set the color and logo for HTML Reports

.DESCRIPTION
Set the color and logo for HTML Reports. It updates the registry keys in HKCU:\Software\XDHealth with the new details and display a test report.

.PARAMETER Color1
New Background Color # code

.PARAMETER Color2
New foreground Color # code

.PARAMETER LogoURL
URL to the new Logo

.EXAMPLE
Set-XDHealthReportColors -Color1 '#d22c26' -Color2 '#2bb74e' -LogoURL 'https://gist.githubusercontent.com/default-monochrome.png'

#>
Function Set-XDHealthReportColors {
	[Cmdletbinding()]
	PARAM(
		[string]$Color1 = '#061820',
		[string]$Color2 = '#FFD400',
		[string]$LogoURL = 'https://c.na65.content.force.com/servlet/servlet.ImageServer?id=0150h000003yYnkAAE&oid=00DE0000000c48tMAA'
	)
    
	$mod = Import-Module XDHealthCheck -Force -PassThru
	$file = Get-Item (Join-Path $mod.ModuleBase -ChildPath '\Private\Reports-Colors.ps1')
	Import-Module $file.FullName
 
	Set-ItemProperty -Path HKCU:\Software\XDHealth -Name Color1 -Value $($Color1)
	Set-ItemProperty -Path HKCU:\Software\XDHealth -Name Color2 -Value $($Color2)
	Set-ItemProperty -Path HKCU:\Software\XDHealth -Name LogoURL -Value $($LogoURL)

	Import-Module XDHealthCheck -Force

	[string]$HTMLReportname = $env:TEMP + '\Test-color' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html'

	$HeadingText = 'Test | Report | ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)

	New-HTML -TitleText 'Report' -FilePath $HTMLReportname -ShowHTML {
		New-HTMLLogo -RightLogoString $XDHealth_LogoURL
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
		New-HTMLSection @SectionSettings -HeaderText 'Test' -Content {
			New-HTMLSection -HeaderText 'Test2' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable (Get-Process | Select-Object -First 5) }
			New-HTMLSection -HeaderText 'Test3' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable (Get-Service | Select-Object -First 5) }
		}
	}

} #end Function
 
Export-ModuleMember -Function Set-XDHealthReportColors
#endregion
 
#endregion
 
