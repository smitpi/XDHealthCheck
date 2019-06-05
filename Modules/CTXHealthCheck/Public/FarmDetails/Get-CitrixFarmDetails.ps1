
<#PSScriptInfo

.VERSION 1.0.3

.GUID b59eb9d3-7d4d-4956-96cf-fb2ed5053e19

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
Date Created - 05/05/2019_08:57
Date Updated - 13/05/2019_04:40
Date Updated - 22/05/2019_20:13
Date Updated - 24/05/2019_19:25

.PRIVATEDATA

#>







<#

.DESCRIPTION
Xendesktop Farm Details

#>

Param()



Function Get-CitrixFarmDetails {
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



function AllConfig {
        param($AdminServer, $RemoteCredentials,$VerbosePreference)

Add-PSSnapin Citrix*

function Get-CTXSiteDetails($AdminServer) {

$site = Get-BrokerSite -AdminAddress $AdminServer
$CustomCTXObject = New-Object PSObject -Property @{
    Summary                 = $site | select Name,ConfigLastChangeTime,LicenseEdition,LicenseModel,LicenseServerName
    AllDetails              = $site
}

$CustomCTXObject

 }

function Get-CTXControllers($AdminServer) {
    $RegistedDesktops = @()
    $controllsers = Get-BrokerController -AdminAddress $AdminServer
    foreach ($server in $controllsers) {
        $CustomCTXObject = New-Object PSObject -Property @{
             Name                 = $server.dnsname
            'Desktops Registered' = $server.DesktopsRegistered
            'Last Activity Time'  = $server.LastActivityTime
            'Last Start Time'     = $server.LastStartTime
            State                 = $server.State
            ControllerVersion     = $server.ControllerVersion
        } |select Name,'Desktops Registered','Last Activity Time', 'Last Start Time',State,ControllerVersion

        $RegistedDesktops += $CustomCTXObject
    }
    $CustomCTXObject = New-Object PSObject -Property @{
        Summary                 = $RegistedDesktops
        AllDetails              = $controllsers
    }

$CustomCTXObject
}

function Get-CTXBrokerMachine($AdminServer) {
$NonRemotepc = Get-BrokerDesktopGroup -AdminAddress $AdminServer | where {$_.IsRemotePC -eq $false} | foreach {Get-BrokerMachine -MaxRecordCount 10000 -AdminAddress $AdminBox -DesktopGroupName $_.name | select DNSName,CatalogName,DesktopGroupName,CatalogUid,AssociatedUserNames,DesktopGroupUid,DeliveryType,DesktopKind,DesktopUid,FaultState,IPAddress,IconUid,OSType,PublishedApplications,RegistrationState,WindowsConnectionSetting }
$UnRegServer = $NonRemotepc | Where-Object { $_.RegistrationState -like "unreg*" -and $_.DeliveryType -notlike "DesktopsOnly" } | select DNSName, CatalogName, DesktopGroupName, AssociatedUserNames, FaultState
$UnRegDesktop = $NonRemotepc | Where-Object { $_.RegistrationState -like "unreg*" -and $_.DeliveryType -like "DesktopsOnly" } | select DNSName, CatalogName, DesktopGroupName, AssociatedUserNames, FaultState
    $CusObject = New-Object PSObject -Property @{
            AllMachines                  = $NonRemotepc
            UnRegisteredServers          = $UnRegServer
            UnRegisteredDesktops         = $UnRegDesktop
    } |select AllMachines,UnRegisteredServers,UnRegisteredDesktops
    $CusObject
}

function Get-CTXSessions($AdminServer) { Get-BrokerSession -MaxRecordCount 10000 -AdminAddress $AdminServer }

function Get-CTXADObjects($AdminServer) {
 $tainted = $adobjects = $CusObject = $null
 $adobjects = Get-AcctADAccount -MaxRecordCount 10000 -AdminAddress $AdminServer
 $tainted = $adobjects | Where-Object { $_.state -like "tainted*" }
 $CusObject = New-Object PSObject -Property @{
      AllObjects                  = $adobjects
      TaintedObjects              = $tainted
    } |select AllObjects,TaintedObjects
    $CusObject
}

function Get-CTXBrokerDesktopGroup($AdminServer) {
    $DG = Get-BrokerDesktopGroup -AdminAddress $AdminServer
    $ReadAbleDG = @()
    foreach ($item in $DG) {
    $BrokerAccess = @()
    $BrokerGroups = @()
    $BrokerAccess = Get-BrokerAccessPolicyRule -DesktopGroupUid $item.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notLike "" } } | select Fullname
    $BrokerGroups = Get-BrokerAccessPolicyRule -DesktopGroupUid $item.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | select Fullname
    $CusObject = New-Object PSObject -Property @{
        Name                   = $item.name
        Uid                    = $item.uid
        IncludedUser           = @($BrokerAccess.FullName)
        IncludeADGroups        = @($BrokerGroups.FullName)
        PublishedName          = $item.PublishedName
        DeliveryType           = $item.DeliveryType
        DesktopKind            = $item.DesktopKind
        IsRemotePC             = $item.IsRemotePC
        Enabled                = $item.Enabled
        TotalDesktops          = $item.TotalDesktops
        DesktopsAvailable      = $item.DesktopsAvailable
        DesktopsInUse          = $item.DesktopsInUse
        DesktopsUnregistered   = $item.DesktopsUnregistered
        InMaintenanceMode      = $item.InMaintenanceMode
        Sessions               = $item.Sessions
        SessionSupport         = $item.SessionSupport
        TotalApplicationGroups = $item.TotalApplicationGroups
        TotalApplications      = $item.TotalApplications
        Tags                   = $item.Tags

    } | select Name,Uid,IncludedUser,IncludeADGroups,PublishedName,DeliveryType,DesktopKind,IsRemotePC,Enabled,TotalDesktops,DesktopsAvailable,DesktopsInUse,DesktopsUnregistered,InMaintenanceMode,Sessions,SessionSupport,TotalApplicationGroups,TotalApplications,Tags
    $ReadAbleDG += $CusObject
}
$CusObject = New-Object PSObject -Property @{
            AllDetails    = $ReadAbleDG
            Summary       = $ReadAbleDG | select Name,DeliveryType,Sessions,TotalDesktops,DesktopsAvailable,DesktopsInUse,DesktopsUnregistered,InMaintenanceMode,TotalApplications,TotalApplicationGroups
}
$CusObject
}

function Get-CTXDBConnection($AdminServer) {
    $dbArray = @()

    $dbconnection = (Test-BrokerDBConnection -DBConnection(Get-BrokerDBConnection -AdminAddress $AdminBox))

    if ([bool]($dbconnection.ExtraInfo.'Database.Status') -eq $False) { [string]$dbstatus = "Unavalable" }
    else { [string]$dbstatus = $dbconnection.ExtraInfo.'Database.Status' }

    $CCTXObject = New-Object PSObject -Property @{
                "Service Status"        = $dbconnection.ServiceStatus.ToString()
                "DB Connection Status"  = $dbstatus
                "Is Mirroring Enabled"  = $dbconnection.ExtraInfo.'Database.IsMirroringEnabled'.ToString()
                "DB Last Backup Date"   = $dbconnection.ExtraInfo.'Database.LastBackupDate'.ToString()
    } |  select  "Service Status","DB Connection Status", "Is Mirroring Enabled","DB Last Backup Date"
    $dbArray =  $CCTXObject.psobject.Properties | Select-Object -Property Name, Value
    $dbArray
}

Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Site Details"
$SiteDetails    = Get-CTXSiteDetails -AdminServer $AdminServer
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Controllers Details"
$Controllers    = Get-CTXControllers -AdminServer $AdminServer
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Machines Details"
$Machines       = Get-CTXBrokerMachine -AdminServer $AdminServer
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Sessions Details"
$Sessions       = Get-CTXSessions -AdminServer $AdminServer
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] ADObjects Details"
$ADObjects      = Get-CTXADObjects -AdminServer $AdminServer
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] DeliveryGroups Details"
$DeliveryGroups = Get-CTXBrokerDesktopGroup -AdminServer $AdminServer
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] DBConnection Details"
$DBConnection   = Get-CTXDBConnection -AdminServer $AdminServer
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Session Counts Details"
$SessionCounts  = New-Object PSObject -Property @{
                'Active Sessions'       = ($Sessions | Where-Object -Property Sessionstate -EQ "Active").count
                'Disconnected Sessions' = ($Sessions | Where-Object -Property Sessionstate -EQ "Disconnected").count
                'Unregistered Servers'  = ($Machines.UnRegisteredServers |Measure-Object).count
                'Unregistered Desktops' = ($Machines.UnRegisteredDesktops|Measure-Object).count
                'Tainted Objects'       = ($ADObjects.TaintedObjects |Measure-Object).Count
                } | select 'Active Sessions','Disconnected Sessions','Unregistered Servers','Unregistered Desktops', 'Tainted Objects'


$CustomCTXObject = New-Object PSObject -Property @{
    DateCollected    = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
    SiteDetails      = $SiteDetails
    Controllers      = $Controllers
    Machines         = $Machines
    Sessions         = $Sessions
    ADObjects        = $ADObjects
    DeliveryGroups   = $DeliveryGroups
    DBConnection     = $DBConnection
    SessionCounts    = $SessionCounts
} | select DateCollected,SiteDetails,Controllers,Machines,Sessions,ADObjects,DeliveryGroups,DBConnection,SessionCounts


$CustomCTXObject

}

$FarmDetails = @()
if ($RunAsPSRemote -eq $true) { $FarmDetails = Invoke-Command -ComputerName $AdminServer -ScriptBlock ${Function:AllConfig} -ArgumentList  @($AdminServer,$RemoteCredentials,$VerbosePreference) -Credential $RemoteCredentials }
else { $FarmDetails = AllConfig -AdminAddress $AdminServer }
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [End] All Details"
$FarmDetails | select DateCollected,SiteDetails, Controllers, Machines, Sessions, ADObjects, DeliveryGroups, DBConnection, SessionCounts

} #end Function

