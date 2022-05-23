
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
FQDN of the Citrix Data Collector


.EXAMPLE
Get-CitrixObjects -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote

#>
Function Get-CitrixObjects {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixObjects')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer)


	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Config"

	if (-not(Get-PSSnapin -Registered | Where-Object {$_.name -like 'Citrix*'})) {Add-PSSnapin citrix* -ErrorAction SilentlyContinue}

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] XDSite"
	$XDSite = Get-XDSite -AdminAddress $adminserver
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] Controllers"
	$Controllers = $XDSite.Controllers | Select-Object DnsName,ControllerState,ControllerVersion,DesktopsRegistered,LastActivityTime,LastStartTime,OSType,OSVersion
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] Databases"
	$DataBases = $XDSite.Databases
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] Licenses"
	$Licenses = Get-XDLicensing -AdminAddress $adminserver | Select-Object LicenseServer,LicensingBurnInDate,LicensingModel,ProductCode,ProductEdition,ProductVersion

	#region Catalogs
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Machine Catalogs"
	[System.Collections.ArrayList]$CTXMachineCatalog = @()
	$MachineCatalogs = Get-BrokerCatalog -AdminAddress $AdminServer
	foreach ($MachineCatalog in $MachineCatalogs) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Machine Catalog: $($MachineCatalog.name.ToString())"
		$MasterImage = Get-ProvScheme -AdminAddress $AdminServer | Where-Object -Property IdentityPoolName -Like $MachineCatalog.Name
		if ($MasterImage.MasterImageVM -notlike '') {
			$MasterImagesplit = ($MasterImage.MasterImageVM).Split('\')
			$masterSnapshotcount = ($MasterImagesplit | Where-Object { $_ -like '*.snapshot' }).count
			$mastervm = ($MasterImagesplit | Where-Object { $_ -like '*.vm' }).Replace('.vm', '')
			if ($masterSnapshotcount -gt 1) { $masterSnapshot = ($MasterImagesplit | Where-Object { $_ -like '*.snapshot' })[-1].Replace('.snapshot', '') }
			else { $masterSnapshot = ($MasterImagesplit | Where-Object { $_ -like '*.snapshot' }).Replace('.snapshot', '') }
		} else {
			$mastervm = ''
			$masterSnapshot = ''
			$masterSnapshotcount = 0
		}
		[void]$CTXMachineCatalog.Add([PSCustomObject]@{
			MachineCatalogName           = $MachineCatalog.name
			AllocationType               = $MachineCatalog.AllocationType
			Description                  = $MachineCatalog.Description
			MinimumFunctionalLevel       = $MachineCatalog.MinimumFunctionalLevel
			PersistUserChanges           = $MachineCatalog.PersistUserChanges
			ProvisioningType             = $MachineCatalog.ProvisioningType
			SessionSupport               = $MachineCatalog.SessionSupport
			UnassignedCount              = $MachineCatalog.UnassignedCount
			UsedCount                    = $MachineCatalog.UsedCount
			AssignedCount                = $MachineCatalog.AssignedCount
			AvailableCount               = $MachineCatalog.AvailableCount
			PvsAddress                   = $MachineCatalog.PvsAddress
			PvsDomain                    = $MachineCatalog.PvsDomain
			CleanOnBoot                  = $MasterImage.CleanOnBoot
			MasterImageVM                = $mastervm
			MasterImageSnapshotName      = $masterSnapshot
			MasterImageSnapshotCount     = $masterSnapshotcount
			MasterImageVMDate            = $MasterImage.MasterImageVMDate
			UseFullDiskCloneProvisioning = $MasterImage.UseFullDiskCloneProvisioning
			UseWriteBackCache            = $MasterImage.UseWriteBackCache
		})
	}
	#endregion

	#region desktop groups
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Delivery Groups"
	$BrokerDesktopGroup = Get-BrokerDesktopGroup -AdminAddress $AdminServer
	[System.Collections.ArrayList]$CTXDeliveryGroup = @()
	foreach ($DesktopGroup in $BrokerDesktopGroup) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DesktopGroup.name.ToString())"
		$BrokerAccess = @()
		$BrokerGroups = @()
		$BrokerAccess = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike '' } } | Select-Object UPN
		$BrokerGroups = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like '' } } | Select-Object Name
		[void]$CTXDeliveryGroup.Add([PSCustomObject]@{
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
		})
	}
	#endregion

	#region pub apps
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Application config"
		[System.Collections.ArrayList]$HostedApps = @()
		$PublishedApps = Get-BrokerApplication -AdminAddress $AdminServer
		foreach ($PublishedApp in $PublishedApps) {
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Published Application:$($PublishedApp.PublishedName.ToString())"
			[system.Collections.ArrayList]$DesktopGroups = @()
			[void]$DesktopGroups.Add(($PublishedApp.AssociatedDesktopGroupUids | ForEach-Object {(Get-BrokerDesktopGroup -Uid $($_)).name}))
			[System.Collections.ArrayList]$PublishedAppGroup = @()
			[System.Collections.ArrayList]$PublishedAppUser = @($PublishedApp.AssociatedUserNames | Where-Object { $_ -notlike $null })
			$index = 0
			foreach ($upn in $PublishedApp.AssociatedUserNames) {
				if ($null -like $upn) { $PublishedAppGroup += @($PublishedApp.AssociatedUserNames)[$index] }
				$index ++
			}
			[void]$HostedApps.Add([PSCustomObject]@{
				ApplicationName         = $PublishedApp.ApplicationName
				ApplicationType         = $PublishedApp.ApplicationType
				DesktopGroups           = @(($DesktopGroups) | Out-String).Trim()
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
			})
		}
	#endregion

	#region servers
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Server Details"
	[System.Collections.ArrayList]$VDAServers = @()
	Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 100000 | Where-Object { $_.OSType -like '*20*' } | ForEach-Object {
		[void]$VDAServers.Add([PSCustomObject]@{
			DNSName           = $_.DNSName
			CatalogName       = $_.CatalogName
			DesktopGroupName  = $_.DesktopGroupName
			IPAddress         = $_.IPAddress
			AgentVersion      = $_.AgentVersion
			OSType            = $_.OSType
			RegistrationState = $_.RegistrationState
			InMaintenanceMode = $_.InMaintenanceMode
		})
	}
#endregion

	#region desktops
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Workstation Details"
	[System.Collections.ArrayList]$VDAWorkstations = @()
	Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 100000 | Where-Object { $_.OSType -notlike 'Windows 20*' } | ForEach-Object {
		[void]$VDAWorkstations.Add([PSCustomObject]@{
			DNSName             = $_.DNSName
			CatalogName         = $_.CatalogName
			DesktopGroupName    = $_.DesktopGroupName
			IPAddress           = $_.IPAddress
			AgentVersion        = $_.AgentVersion
			AssociatedUserNames = @(($_.AssociatedUserNames) | Out-String).Trim()
			OSType              = $_.OSType
			RegistrationState   = $_.RegistrationState
			InMaintenanceMode   = $_.InMaintenanceMode
		})
	}
	#endregion

	$ObjectCount = [PSCustomObject]@{
		Sitename        = $XDSite.name
		Controllers     = $Controllers.count
		Catalogs        = $CTXMachineCatalog.count
		DesktopGroup    = $CTXDeliveryGroup.count
		PublishedApps   = $HostedApps.count
		VDAServers      = $VDAServers.count
		VDAWorkstations = $VDAWorkstations.count
	}

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Published Applications"
	$CusObject = New-Object PSObject -Property @{
		DateCollected   = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		ObjectCount     = $ObjectCount 
		Controllers		= $Controllers
		Databases       = $DataBases
		Licenses        = $Licenses
		MachineCatalog  = $CTXMachineCatalog
		DeliveryGroups  = $CTXDeliveryGroup
		PublishedApps   = $HostedApps
		VDAServers      = $VDAServers
		VDAWorkstations = $VDAWorkstations
	}
	$CusObject
} #end Function



