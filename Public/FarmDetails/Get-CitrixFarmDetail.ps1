
<#PSScriptInfo

.VERSION 1.0.13

.GUID b59eb9d3-7d4d-4956-96cf-fb2ed5053e19

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

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

