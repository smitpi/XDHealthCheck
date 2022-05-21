
<#PSScriptInfo

.VERSION 1.0.11

.GUID 07f17625-4521-42d4-91a3-d02507d2e7b7

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

		if (-not(Get-PSSnapin -Registered | Where-Object {$_.name -like 'Citrix*'})) {Add-PSSnapin citrix* -ErrorAction SilentlyContinue}
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


