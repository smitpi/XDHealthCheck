
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



Function Get-AllPublishedApplications {
    PARAM(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$AdminServer,
        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$RemoteCredentials,
        [Parameter(Mandatory = $false, Position = 2)]
        [switch]$RunAsPSRemote = $false)


    Function GetAllConfig{
    param($AdminServer, $VerbosePreference)
        Add-PSSnapin citrix*
        Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [BEGIN] Getting All Delivery Groups"
        $DG = Get-BrokerDesktopGroup -AdminAddress $AdminServer
        $ReadAbleDG = @()
        foreach ($item in $DG)
        {
            $sp = $item.name.Split("-")
            [string]$HR = $sp[-1].ToString() + " (" + $sp[-2] + ")"

            $BrokerAccess = @()
            $BrokerGroups = @()
            $BrokerAccess = Get-BrokerAccessPolicyRule -DesktopGroupUid $item.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike "" } } | select UPN
    $BrokerGroups = Get-BrokerAccessPolicyRule -DesktopGroupUid $item.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | select Fullname
$CusObject = New-Object PSObject -Property @{
    HumanReadable          = $HR
    DesktopGroupName       = $item.name
    Uid                    = $item.uid
    DeliveryType           = $item.DeliveryType
    DesktopKind            = $item.DesktopKind
    DesktopsDisconnected   = $item.DesktopsDisconnected
    DesktopsFaulted        = $item.DesktopsFaulted
    DesktopsInUse          = $item.DesktopsInUse
    DesktopsUnregistered   = $item.DesktopsUnregistered
    Enabled                = $item.Enabled
    IconUid                = $item.IconUid
    InMaintenanceMode      = $item.InMaintenanceMode
    SessionSupport         = $item.SessionSupport
    TotalApplicationGroups = $item.TotalApplicationGroups
    TotalApplications      = $item.TotalApplications
    TotalDesktops          = $item.TotalDesktops
    IncludedUser           = @($BrokerAccess.UPN)
    IncludeADGroups        = @($BrokerGroups.FullName)
} | select HumanReadable, DesktopGroupName, Uid, DeliveryType, DesktopKind, DesktopsDisconnected, DesktopsFaulted, DesktopsInUse, DesktopsUnregistered, Enabled, IconUid, InMaintenanceMode, SessionSupport, TotalApplicationGroups, TotalApplications, TotalDesktops, IncludedUser, IncludeADGroups
$ReadAbleDG += $CusObject
}


$HostedApps = @()
foreach ($DeskG in ($ReadAbleDG | where { $_.DeliveryType -like 'DesktopsAndApps' }))
{
    Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DeskG.DesktopGroupName.ToString())"
    $PublishedApps = Get-BrokerApplication -AssociatedDesktopGroupUid $DeskG.Uid -AdminAddress $AdminServer
    foreach ($PublishedApp in $PublishedApps)
    {
        Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Published Application: $($PublishedApp.BrowserName.ToString())"
        $PublishedAppGroup = @()
        $PublishedAppUser = @()
        foreach ($item in $PublishedApp.AssociatedUserFullNames)
        {
            try
            {
                $group = $null
                $group = Get-ADGroup $item
                if ($group -ne $null) { $PublishedAppGroup += $group.SamAccountName }
            }
            catch { }
        }
        foreach ($item2 in $PublishedApp.AssociatedUserUPNs)
        {
            try
            {
                $PublishedAppUser += $item2
                #$user = $user2 = $null
                #$user = Get-ADUser -f { UserPrincipalName -eq $item2 }
                #$user2 = Get-ADUser -f { UserPrincipalName -eq $item2 } -Server ds1.ad.absa.co.za
                #if ($user -ne $null) { $PublishedAppUser += "CORP\" + $user.SamAccountName }
                #if ($user2 -ne $null) { $PublishedAppUser += "D_ABSA\" + $user2.SamAccountName }
            }
            catch { }
        }
        $CusObject = New-Object PSObject -Property @{
            HumanReadable        = $DeskG.HumanReadable
            DesktopGroupName     = $DeskG.DesktopGroupName
            DesktopGroupUid      = $DeskG.Uid
            DesktopGroupUsers    = $DeskG.IncludedUser
            DesktopGroupADGroups = $DeskG.IncludeADGroups
            PublishedApp         = $PublishedApp.PublishedName
            PublishedAppName     = $PublishedApp.Name
            PublishedAppGroup    = $PublishedAppGroup
            PublishedAppUser     = $PublishedAppUser
        } | select  HumanReadable, DesktopGroupName, DesktopGroupUid, DesktopGroupUsers, DesktopGroupADGroups, PublishedApp, PublishedAppName, PublishedAppGroup, PublishedAppUser
    $HostedApps += $CusObject
}
}

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Published Applications"
$CusObject = New-Object PSObject -Property @{
    DateCollected  = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
    DeliveryGroups = $ReadAbleDG
    PublishedApps  = $HostedApps
}
$CusObject
}

$AppDetail = @()
if ($RunAsPSRemote -eq $true) { $AppDetail = Invoke-Command -ComputerName $AdminServer -ScriptBlock ${Function:GetAllConfig} -ArgumentList  @($AdminServer,$VerbosePreference) -Credential $RemoteCredentials }
else { $AppDetail = GetAllConfig -AdminAddress $AdminServer}
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [End] All Details"
$AppDetail | select DateCollected, DeliveryGroups,PublishedApps

} #end Function
