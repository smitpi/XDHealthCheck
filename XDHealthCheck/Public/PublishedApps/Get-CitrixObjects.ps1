
<#PSScriptInfo

.VERSION 1.0.3

.GUID 07f17625-4521-42d4-91a3-d02507d2e7b7

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





<#

.DESCRIPTION
Citrix XenDesktop HTML Health Check Report

#>

Param()



Function Get-CitrixObjects {
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


	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Config"
Function GetAllConfig {
		param($AdminServer, $VerbosePreference)

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
}
else {
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
    $BrokerGroups = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | Select-Object Fullname
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
    GroupAccess            = @(($BrokerGroups.FullName) | Out-String).Trim()
} | Select-Object DesktopGroupName, Uid, DeliveryType, DesktopKind, Description, DesktopsDisconnected, DesktopsFaulted, DesktopsInUse, DesktopsUnregistered, Enabled, IconUid, InMaintenanceMode, SessionSupport, TotalApplicationGroups, TotalApplications, TotalDesktops, Tags, UserAccess, GroupAccess
$CTXDeliveryGroup += $CusObject
}

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Application config"
$HostedApps = @()
foreach ($DeskG in ($CTXDeliveryGroup | Where-Object { $_.DeliveryType -like 'DesktopsAndApps' })) {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DeskG.DesktopGroupName.ToString())"
	$PublishedApps = Get-BrokerApplication -AssociatedDesktopGroupUid $DeskG.Uid -AdminAddress $AdminServer
	foreach ($PublishedApp in $PublishedApps) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Published Application: $($DeskG.DesktopGroupName.ToString()) - $($PublishedApp.PublishedName.ToString())"
		$PublishedAppGroup = @()
		$PublishedAppUser = @()
			foreach ($AppAssociatedUser in $PublishedApp.AssociatedUserFullNames) {
				#$ADObject = Get-ADObject -Filter {$AppAssociatedUser}
					$ADObject =	Get-ADObject -Filter 'name -eq $AppAssociatedUser'
				if ($ADObject.ObjectClass -like 'user') { $PublishedAppUser += $ADObject.Name }
				else { $PublishedAppGroup += $ADObject.Name }
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
		    PublishedName            = $PublishedApp.PublishedName
		    PublishedAppName         = $PublishedApp.Name
		    PublishedAppGroupAccess  = @(($PublishedAppGroup) | Out-String).Trim()
    	    PublishedAppUserAccess    = @(($PublishedAppUser) | Out-String).Trim()
} | Select-Object DesktopGroupName, DesktopGroupUid, DesktopGroupUsersAccess, DesktopGroupGroupAccess, ApplicationName, ApplicationType, AdminFolderName, ClientFolder, Description, Enabled, CommandLineExecutable, CommandLineArgument, WorkingDirectory, Tags, PublishedName, PublishedAppName, PublishedAppGroupAccess, PublishedAppUserAccess
$HostedApps += $CusObject
}
}

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Published Applications"

$CusObject = New-Object PSObject -Property @{
	DateCollected  = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
	MashineCatalog = $CTXMachineCatalog
	DeliveryGroups = $CTXDeliveryGroup
	PublishedApps  = $HostedApps
}
$CusObject
}

$AppDetail = @()
if ($RunAsPSRemote -eq $true) { $AppDetail = Invoke-Command -ComputerName $AdminServer -ScriptBlock ${Function:GetAllConfig} -ArgumentList  @($AdminServer, $VerbosePreference) -Credential $RemoteCredentials }
else { $AppDetail = GetAllConfig -AdminServer $AdminServer -VerbosePreference $VerbosePreference }
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] All Details"
$AppDetail | Select-Object DateCollected, MashineCatalog, DeliveryGroups, PublishedApps
} #end Function
