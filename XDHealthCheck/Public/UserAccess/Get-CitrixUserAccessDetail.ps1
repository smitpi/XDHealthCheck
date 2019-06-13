
<#PSScriptInfo

.VERSION 1.0.3

.GUID 42427037-9fe8-465e-a2bf-6d57f9a70509

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
Created [22/05/2019_19:53]
Updated [22/05/2019_20:18]
Updated [06/06/2019_19:26]
Updated [09/06/2019_09:18]

.PRIVATEDATA

#>







<#

.DESCRIPTION
For the CTX Dashboard

#>

Param()




function Get-CitrixUserAccessDetail {
                PARAM(
                [Parameter(Mandatory=$true, Position=0)]
                [ValidateNotNull()]
                [ValidateNotNullOrEmpty()]
                [string]$Username,
                [Parameter(Mandatory=$true, Position=1)]
                [ValidateNotNull()]
                [ValidateNotNullOrEmpty()]
                [string]$AdminServer)

Add-PSSnapin citrix*
$HSADesktop = $ValidUser =$userDeliveryGroup =$DesktopGroupAccess = $null
$DesktopGroupAccess = @()
$UserDeliveryGroup = @()
$UserDeliveryGroupUid = @()
$PublishedApps =@()
$PublishedDesktops =@()
$DirectPublishedDesktops = @()
$DirectPublishedApps = @()
$NoAccessPublishedApps = @()
$AccessPublishedApps = @()

$User = Get-ADUser $Username  -Properties *| select Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
$AllUserGroups = Get-ADUser $Username -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object {Get-ADGroup $_ | select SamAccountName }
$HSADesktop = $AllUserGroups|Where-Object {$_.SamAccountName -like "Citrix-HSA-Desktop"}

$BrokerAccessPolicy = Get-BrokerAccessPolicyRule -AdminAddress $AdminServer -AllowedConnections ViaAG | select IncludedUsers,DesktopGroupName,DesktopGroupUid

foreach ($AccessPolicy in $BrokerAccessPolicy) {
$IncludedGroups = $AccessPolicy | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | select Fullname
$IncludedUsersUPN  = $AccessPolicy | ForEach-Object { $_.IncludedUsers  | Where-Object { $_.upn -notlike "" }} | select UPN

foreach ($Group in $IncludedGroups) {
    $CheckMemberof = $null
    $CheckMemberof = $AllUserGroups | where {$_.SamAccountName -like $Group.FullName}
    if ($null -ne $CheckMemberof) {
            $userDeliveryGroup += $AccessPolicy.DesktopGroupName
            $UserDeliveryGroupUid  += $AccessPolicy.DesktopGroupUid
    }
}

foreach ($UserUpn in $IncludedUsersUPN) {
    if ($UserUpn.upn -like $User.UserPrincipalName) {
        $userDeliveryGroup += $AccessPolicy.DesktopGroupName
        $UserDeliveryGroupUid  += $AccessPolicy.DesktopGroupUid
     }
}

$DesktopGroupAccess += New-Object PSObject -Property @{
        DesktopGroupName       = $AccessPolicy.DesktopGroupName
        DesktopGroupUid        = $AccessPolicy.DesktopGroupUid
        IncludedGroups         = ($AccessPolicy | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | select Fullname).fullname
        IncludedUsersName      = ($AccessPolicy | ForEach-Object { $_.IncludedUsers  | Where-Object { $_.upn -notlike "" }} | select Name).name
        IncludedUsersUPN       = ($AccessPolicy | ForEach-Object { $_.IncludedUsers  | Where-Object { $_.upn -notlike "" }} | select UPN).UPN
       }
}

$DirectPublishedApps += Get-BrokerApplication -AssociatedUserUPN $User.UserPrincipalName -AdminAddress $AdminServer
$PublishedApps += $UserDeliveryGroupUid | ForEach-Object {Get-BrokerApplication -AssociatedDesktopGroupUid $_ -AdminAddress $AdminServer}
foreach ($app in $PublishedApps ) {
    $CheckMemberof = $null
    $CheckMemberof = $AllUserGroups | where {$_.SamAccountName -like $app.AssociatedUserFullNames}
    if ($null -ne $CheckMemberof) {$AccessPublishedApps += $app}
    else {$NoAccessPublishedApps += $app}
    }

$DirectPublishedDesktops = Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 5000 | where {$_.AssociatedUserUPNs -like $User.UserPrincipalName} | select DNSName,DesktopGroupName,OSType
if ([bool]$HSADesktop -eq $true) {
$userDeliveryGroup = $userDeliveryGroup | sort -Unique
foreach ($DelGroup in $userDeliveryGroup) {
$desktopkind = Get-BrokerMachine -DesktopGroupName $DelGroup
  if ( $desktopkind.DesktopKind  -like 'Shared') {
  $PublishedDesktops += New-Object PSObject -Property @{
    DNSNAme =  'Hosted Desktop'
    DesktopGroupName = $DelGroup
    OsType         = $desktopkind.OSType
   } | select DNSName,DesktopGroupName,OSType
  }
}
}
$ValidUser = @()
$ValidUser = New-Object PSObject -Property @{
        UserDetail            = $User
        AllUserGroups         = $AllUserGroups
        HSADesktop            = [bool]$HSADesktop
        UserDeliveryGroup     = $userDeliveryGroup
        UserDeliveryGroupUid  = $UserDeliveryGroupUid
        DirectPublishedApps   = $DirectPublishedApps | Select PublishedName,AssociatedUserUPNs,AssociatedUserNames,AssociatedUserFullNames,Description,enabled
        AccessPublishedApps   = $AccessPublishedApps | Select PublishedName,AssociatedUserUPNs,AssociatedUserNames,AssociatedUserFullNames,Description,enabled
        NoAccessPublishedApps = $NoAccessPublishedApps | Select PublishedName,AssociatedUserUPNs,AssociatedUserNames,AssociatedUserFullNames,Description,enabled
        PublishedDesktops     = $PublishedDesktops
        DirectPublishedDesktops     = $DirectPublishedDesktops
} | select UserDetail,AllUserGroups,HSADesktop,userDeliveryGroup,UserDeliveryGroupUid,DirectPublishedApps,AccessPublishedApps,NoAccessPublishedApps,PublishedDesktops,DirectPublishedDesktops
$ValidUser
}
