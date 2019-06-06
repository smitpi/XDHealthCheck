
<#PSScriptInfo

.VERSION 1.0.1

.GUID 07f17625-4521-42d4-91a3-d02507d2e7b7

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

Param()



Function Get-CitrixObjects {
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $false, Position = 1)]
		[switch]$GetMachineCatalog = $false,
		[Parameter(Mandatory = $false, Position = 2)]
		[switch]$GetDeliveryGroup = $false,
		[Parameter(Mandatory = $false, Position = 3)]
		[switch]$GetPublishedApps = $false,
		[Parameter(Mandatory = $false, Position = 4)]
		[switch]$CSVExport = $false,
		[Parameter(Mandatory = $false, Position = 5)]
		[switch]$RunAsPSRemote = $false,
		[Parameter(Mandatory = $false, Position = 6)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)


Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Config"
Function GetAllConfig {
	param($AdminServer, $VerbosePreference,$GetMachineCatalog,$GetDeliveryGroup,$GetPublishedApps,$CSVExport)

Add-PSSnapin citrix*
if ($GetMachineCatalog){
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Machine Catalogs"
$CTXMachineCatalog = @()
$MachineCatalogs = Get-BrokerCatalog -AdminAddress $AdminServer
foreach ($MachineCatalog in $MachineCatalogs)
    {
    Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Machine Catalog: $($MachineCatalog.name.ToString())"
    $MasterImage = Get-ProvScheme -AdminAddress $AdminServer | Where-Object -Property IdentityPoolName -Like $MachineCatalog.Name
    if ($MasterImage.MasterImageVM -notlike ''){
        $MasterImagesplit = ($MasterImage.MasterImageVM).Split("\") 
        $masterSnapshotcount = ($MasterImagesplit |where {$_ -like '*.snapshot'}).count
        $mastervm = ($MasterImagesplit |where {$_ -like '*.vm'}).Replace(".vm",'')
        if ($masterSnapshotcount -gt 1) {$masterSnapshot = ($MasterImagesplit |where {$_ -like '*.snapshot'})[-1].Replace(".snapshot",'')}
        else {$masterSnapshot = ($MasterImagesplit |where {$_ -like '*.snapshot'}).Replace(".snapshot",'')}
    }
    else {
        $mastervm = ''
        $masterSnapshot = ''
        $masterSnapshotcount = 0
    }
    $CatObject = New-Object PSObject -Property @{
		MachineCatalogName                = $MachineCatalog.name
		AllocationType                    = $MachineCatalog.AllocationType
        Description                       = $MachineCatalog.Description
        IsRemotePC                        = $MachineCatalog.IsRemotePC
        MachinesArePhysical               = $MachineCatalog.MachinesArePhysical
        MinimumFunctionalLevel            = $MachineCatalog.MinimumFunctionalLevel
        PersistUserChanges                = $MachineCatalog.PersistUserChanges
        ProvisioningType                  = $MachineCatalog.ProvisioningType
        SessionSupport                    = $MachineCatalog.SessionSupport
        Uid                               = $MachineCatalog.Uid
        UnassignedCount                   = $MachineCatalog.UnassignedCount
        UsedCount                         = $MachineCatalog.UsedCount
        CleanOnBoot                       = $MasterImage.CleanOnBoot
        MasterImageVM                     = $mastervm
        MasterImageSnapshotName           = $masterSnapshot
        MasterImageSnapshotCount          = $masterSnapshotcount
        MasterImageVMDate                 = $MasterImage.MasterImageVMDate
        UseFullDiskCloneProvisioning      = $MasterImage.UseFullDiskCloneProvisioning
        UseWriteBackCache                 = $MasterImage.UseWriteBackCache
    } | select MachineCatalogName,AllocationType,Description,IsRemotePC,MachinesArePhysical,MinimumFunctionalLevel,PersistUserChanges,ProvisioningType,SessionSupport,Uid,UnassignedCount,UsedCount,CleanOnBoot,MasterImageVM,MasterImageSnapshotName,MasterImageSnapshotCount,MasterImageVMDate,UseFullDiskCloneProvisioning,UseWriteBackCache
    $CTXMachineCatalog += $CatObject 
}
} #if
else {$CTXMachineCatalog = $null}

if ($GetDeliveryGroup) {
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Delivery Groups"
$BrokerDesktopGroup = Get-BrokerDesktopGroup -AdminAddress $AdminServer
$CTXDeliveryGroup = @()
foreach ($DesktopGroup in $BrokerDesktopGroup) {
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DesktopGroup.name.ToString())"
	$BrokerAccess = @()
	$BrokerGroups = @()
	$BrokerAccess = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike "" } } | select UPN
	$BrokerGroups = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | select Fullname
    if ([bool]$BrokerAccess.UPN) {$UsersCSV = [String]::Join(';', $BrokerAccess.UPN)}
    else{$UsersCSV = ''}
    if ([bool]$BrokerGroups.FullName) {$GroupsCSV = [String]::Join(';', $BrokerGroups.FullName)}
    else{$GroupsCSV = ''}    
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
        Tags                   = $DesktopGroup.Tags
		IncludedUser           = @($BrokerAccess.UPN)
		IncludeADGroups        = @($BrokerGroups.FullName)
		IncludedUserCSV        = $UsersCSV
		IncludeADGroupsCSV     = $GroupsCSV
		} 
		$CTXDeliveryGroup += $CusObject
	}
} #if
else {$CTXDeliveryGroup = $null}

if ($GetPublishedApps) {
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Delivery Groups"
$BrokerDesktopGroup = Get-BrokerDesktopGroup -AdminAddress $AdminServer
$CTXDeliveryGroupApps = @()
foreach ($DesktopGroup in $BrokerDesktopGroup) {
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DesktopGroup.name.ToString())"
	$BrokerAccess = @()
	$BrokerGroups = @()
	$BrokerAccess = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike "" } } | select UPN
	$BrokerGroups = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | select Fullname
    if ([bool]$BrokerAccess.UPN) {$UsersCSV = [String]::Join(';', $BrokerAccess.UPN)}
    else{$UsersCSV = ''}
    if ([bool]$BrokerGroups.FullName) {$GroupsCSV = [String]::Join(';', $BrokerGroups.FullName)}
    else{$GroupsCSV = ''}    
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
        Tags                   = $DesktopGroup.Tags
		IncludedUser           = @($BrokerAccess.UPN)
		IncludeADGroups        = @($BrokerGroups.FullName)
		IncludedUserCSV        = $UsersCSV
		IncludeADGroupsCSV     = $GroupsCSV
		} 
		$CTXDeliveryGroupApps += $CusObject
	}

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Application config"
$HostedApps = @()
foreach ($DeskG in ($CTXDeliveryGroupApps | where { $_.DeliveryType -like 'DesktopsAndApps' })) {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DeskG.DesktopGroupName.ToString())"
	$PublishedApps = Get-BrokerApplication -AssociatedDesktopGroupUid $DeskG.Uid -AdminAddress $AdminServer
	foreach ($PublishedApp in $PublishedApps) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Published Application: $($DeskG.DesktopGroupName.ToString()) - $($PublishedApp.PublishedName.ToString())"
		$PublishedAppGroup = @()
		$PublishedAppUser = @()
		foreach ($AppAssociatedUser in $PublishedApp.AssociatedUserFullNames) {
			try {
				$group = $null
				$group = Get-ADGroup $AppAssociatedUser
				if ($group -ne $null) { $PublishedAppGroup += $group.SamAccountName }
			}
			catch { }
		}
		foreach ($AppAssociatedUser2 in $PublishedApp.AssociatedUserUPNs) {
			try {
				if ($AppAssociatedUser2 -ne '') { $PublishedAppUser += $AppAssociatedUser2}
			}
			catch { }
		}
        $PublishedAppUserCSV = [String]::Join(';', $PublishedAppUser)
        $PublishedAppGroupCSV = [String]::Join(';', $PublishedAppGroup)
		$CusObject = New-Object PSObject -Property @{
			DesktopGroupName         = $DeskG.DesktopGroupName
			DesktopGroupUid          = $DeskG.Uid
			DesktopGroupUsers        = $DeskG.IncludedUser
			DesktopGroupADGroups     = $DeskG.IncludeADGroups
            DesktopGroupUsersCSV     = $DeskG.IncludedUserCSV
            DesktopGroupADGroupsCSV  = $DeskG.IncludeADGroupsCSV
            ApplicationName          = $PublishedApp.ApplicationName
            ApplicationType          = $PublishedApp.ApplicationType
            AdminFolderName          = $PublishedApp.AdminFolderName
            ClientFolder             = $PublishedApp.ClientFolder
            Description              = $PublishedApp.Description
            Enabled                  = $PublishedApp.Enabled
            CommandLineExecutable    = $PublishedApp.CommandLineExecutable
            CommandLineArguments     = $PublishedApp.CommandLineArguments
            WorkingDirectory         = $PublishedApp.WorkingDirectory
            Tags                     = $PublishedApp.Tags
			PublishedName            = $PublishedApp.PublishedName
			PublishedAppName         = $PublishedApp.Name                    
			PublishedAppGroup        = $PublishedAppGroup
			PublishedAppUser         = $PublishedAppUser
			PublishedAppGroupCSV     = $PublishedAppGroupCSV
			PublishedAppUserCSV      = $PublishedAppUserCSV
		} 
$HostedApps += $CusObject
		}
	}
} #if
else {$HostedApps = $null}

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Published Applications"
if ($CSVExport) {
    $CTXDeliveryGroup = $CTXDeliveryGroup | select DesktopGroupName,Uid,DeliveryType,DesktopKind,Description,DesktopsDisconnected,DesktopsFaulted,DesktopsInUse,DesktopsUnregistered,Enabled,IconUid,InMaintenanceMode,SessionSupport,TotalApplicationGroups,TotalApplications,TotalDesktops,Tags,IncludedUserCSV,IncludeADGroupsCSV
    $HostedApps = $HostedApps | select  DesktopGroupName,DesktopGroupUid,DesktopGroupUsersCSV,DesktopGroupADGroupsCSV,ApplicationName,ApplicationType,AdminFolderName,ClientFolder,Description,Enabled,CommandLineExecutable,CommandLineArguments,WorkingDirectory,Tags,PublishedName,PublishedAppName,PublishedAppGroupCSV,PublishedAppUserCSV
    }
else {
    $CTXDeliveryGroup = $CTXDeliveryGroup | select DesktopGroupName,Uid,DeliveryType,DesktopKind,Description,DesktopsDisconnected,DesktopsFaulted,DesktopsInUse,DesktopsUnregistered,Enabled,IconUid,InMaintenanceMode,SessionSupport,TotalApplicationGroups,TotalApplications,TotalDesktops,Tags,IncludedUser,IncludeADGroups
    $HostedApps = $HostedApps | select  DesktopGroupName,DesktopGroupUid,DesktopGroupUsers,DesktopGroupADGroups,ApplicationName,ApplicationType,AdminFolderName,ClientFolder,Description,Enabled,CommandLineExecutable,CommandLineArguments,WorkingDirectory,Tags,PublishedName,PublishedAppName,PublishedAppGroup,PublishedAppUser
    }

$CusObject = New-Object PSObject -Property @{
	DateCollected  = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
    MashineCatalog = $CTXMachineCatalog
  	DeliveryGroups = $CTXDeliveryGroup
	PublishedApps  = $HostedApps
    }
$CusObject
}

$AppDetail = @()
if ($RunAsPSRemote -eq $true) { $AppDetail = Invoke-Command -ComputerName $AdminServer -ScriptBlock ${Function:GetAllConfig} -ArgumentList  @($AdminServer, $VerbosePreference,$GetMachineCatalog,$GetDeliveryGroup,$GetPublishedApps,$CSVExport) -Credential $RemoteCredentials }
else { $AppDetail = GetAllConfig -AdminServer $AdminServer -VerbosePreference $VerbosePreference -GetMachineCatalog $GetMachineCatalog -GetDeliveryGroup $GetDeliveryGroup -GetPublishedApps $GetPublishedApps -CSVExport $CSVExport}
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending] All Details"
$AppDetail | select DateCollected,MashineCatalog,DeliveryGroups,PublishedApps
} #end Function
