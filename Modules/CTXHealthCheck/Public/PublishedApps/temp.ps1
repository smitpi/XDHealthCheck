Add-PSSnapin citrix*
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Mashine Catalogs"
$CTXMashineCatalog = @()
$MashineCatalogs = Get-BrokerCatalog -AdminAddress $AdminServer
foreach ($MashineCatalog in $MashineCatalogs)
    {
    Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Mashine Catalog: $($MashineCatalog.name.ToString())"
    $MasterImage = Get-ProvScheme -AdminAddress $AdminServer | Where-Object -Property IdentityPoolName -Like $MashineCatalog.Name
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
		MashineCatalogName                = $MashineCatalog.name
		AllocationType                    = $MashineCatalog.AllocationType
        Description                       = $MashineCatalog.Description
        IsRemotePC                        = $MashineCatalog.IsRemotePC
        MachinesArePhysical               = $MashineCatalog.MachinesArePhysical
        MinimumFunctionalLevel            = $MashineCatalog.MinimumFunctionalLevel
        PersistUserChanges                = $MashineCatalog.PersistUserChanges
        ProvisioningType                  = $MashineCatalog.ProvisioningType
        SessionSupport                    = $MashineCatalog.SessionSupport
        Uid                               = $MashineCatalog.Uid
        UnassignedCount                   = $MashineCatalog.UnassignedCount
        UsedCount                         = $MashineCatalog.UsedCount
        CleanOnBoot                       = $MasterImage.CleanOnBoot
        MasterImageVM                     = $mastervm
        MasterImageSnapshotName           = $masterSnapshot
        MasterImageSnapshotCount          = $masterSnapshotcount
        MasterImageVMDate                 = $MasterImage.MasterImageVMDate
        UseFullDiskCloneProvisioning      = $MasterImage.UseFullDiskCloneProvisioning
        UseWriteBackCache                 = $MasterImage.UseWriteBackCache
    } | select MashineCatalogName,AllocationType,Description,IsRemotePC,MachinesArePhysical,MinimumFunctionalLevel,PersistUserChanges,ProvisioningType,SessionSupport,Uid,UnassignedCount,UsedCount,CleanOnBoot,MasterImageVM,MasterImageSnapshotName,MasterImageSnapshotCount,MasterImageVMDate,UseFullDiskCloneProvisioning,UseWriteBackCache
    $CTXMashineCatalog += $CatObject 
}

