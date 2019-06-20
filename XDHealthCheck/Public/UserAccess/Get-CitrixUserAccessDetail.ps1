
<#PSScriptInfo

.VERSION 1.0.5

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
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports

.PRIVATEDATA

#>











<#

.DESCRIPTION
Citrix XenDesktop HTML Health Check Report

#>

Param()




function Get-CitrixUserAccessDetail {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$DomainFQDN,
		[Parameter(Mandatory = $true, Position = 3)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$DomainCredentials,
		[Parameter(Mandatory = $false, Position = 4)]
		[switch]$RunAsPSRemote = $false,
		[Parameter(Mandatory = $false, Position = 5)]
		[String]$PSRemoteServerName)

	function AllConfig {
		param($username,$adminserver, $DomainFQDN,[PSCredential]$DomainCredentials, $VerbosePreference)
        
        Add-PSSnapin citrix*
    	$HSADesktop = $ValidUser = $userDeliveryGroup = $DesktopGroupAccess = $null
		$DesktopGroupAccess = @()
		$UserDeliveryGroup = @()
		$UserDeliveryGroupUid = @()
		$PublishedApps = @()
		$PublishedDesktops = @()
		$DirectPublishedDesktops = @()
		$DirectPublishedApps = @()
		$NoAccessPublishedApps = @()
		$AccessPublishedApps = @()
        
		$User = Get-ADUser $username -Server $DomainFQDN -Credential $DomainCredentials -Properties * | Select-Object Name, GivenName, Surname, UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate, samaccountname
		$AllUserGroups = Get-ADUser $username -Properties * -Server $DomainFQDN -Credential $DomainCredentials | Select-Object -ExpandProperty memberof | ForEach-Object { Get-ADGroup $_ -Server $DomainFQDN -Credential $DomainCredentials }
		$HSADesktop = $AllUserGroups | Where-Object { $_.SamAccountName -like "Citrix-HSA-Desktop" }

		$BrokerAccessPolicy = Get-BrokerAccessPolicyRule -AdminAddress $AdminServer -AllowedConnections ViaAG | Select-Object IncludedUsers, DesktopGroupName, DesktopGroupUid

		foreach ($AccessPolicy in $BrokerAccessPolicy) {
			$IncludedGroups = $AccessPolicy | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | Select-Object Fullname
			$IncludedUsersUPN = $AccessPolicy | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike "" } } | Select-Object UPN

			foreach ($Group in $IncludedGroups) {
				$CheckMemberof = $null
				$CheckMemberof = $AllUserGroups | Where-Object { $_.SamAccountName -like $Group.FullName }
				if ($null -ne $CheckMemberof) {
					$userDeliveryGroup += $AccessPolicy.DesktopGroupName
					$UserDeliveryGroupUid += $AccessPolicy.DesktopGroupUid
				}
			}

			foreach ($UserUpn in $IncludedUsersUPN) {
				if ($UserUpn.upn -like $User.UserPrincipalName) {
					$userDeliveryGroup += $AccessPolicy.DesktopGroupName
					$UserDeliveryGroupUid += $AccessPolicy.DesktopGroupUid
				}
			}

			$DesktopGroupAccess += New-Object PSObject -Property @{
				DesktopGroupName  = $AccessPolicy.DesktopGroupName
				DesktopGroupUid   = $AccessPolicy.DesktopGroupUid
				IncludedGroups    = ($AccessPolicy | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | Select-Object Fullname).fullname
				IncludedUsersName = ($AccessPolicy | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike "" } } | Select-Object Name).name
				IncludedUsersUPN  = ($AccessPolicy | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike "" } } | Select-Object UPN).UPN
			}
		}

		$DirectPublishedApps += Get-BrokerApplication -AssociatedUserUPN $User.UserPrincipalName -AdminAddress $AdminServer
		$PublishedApps += $UserDeliveryGroupUid | ForEach-Object { Get-BrokerApplication -AssociatedDesktopGroupUid $_ -AdminAddress $AdminServer }
		foreach ($app in $PublishedApps ) {
			$CheckMemberof = $null
			$CheckMemberof = $AllUserGroups | Where-Object { $_.SamAccountName -like $app.AssociatedUserFullNames }
			if ($null -ne $CheckMemberof) { $AccessPublishedApps += $app }
			else { $NoAccessPublishedApps += $app }
		}

		$DirectPublishedDesktops = Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 5000 | Where-Object { $_.AssociatedUserUPNs -like $User.UserPrincipalName } | Select-Object DNSName, DesktopGroupName, OSType
		if ([bool]$HSADesktop -eq $true) {
			$userDeliveryGroup = $userDeliveryGroup | Sort-Object -Unique
			foreach ($DelGroup in $userDeliveryGroup) {
				$desktopkind = Get-BrokerMachine -DesktopGroupName $DelGroup
				if ( $desktopkind.DesktopKind -like 'Shared') {
					$PublishedDesktops += New-Object PSObject -Property @{
						DNSNAme          = 'Hosted Desktop'
						DesktopGroupName = $DelGroup
						OsType           = $desktopkind.OSType
					} | Select-Object DNSName, DesktopGroupName, OSType
				}
			}
		}
		$ValidUser = @()
		$ValidUser = New-Object PSObject -Property @{
			UserDetail              = $User
			AllUserGroups           = $AllUserGroups
			HSADesktop              = [bool]$HSADesktop
			UserDeliveryGroup       = $userDeliveryGroup
			UserDeliveryGroupUid    = $UserDeliveryGroupUid
			DirectPublishedApps     = $DirectPublishedApps | Select-Object PublishedName, AssociatedUserUPNs, AssociatedUserNames, AssociatedUserFullNames, Description, enabled
			AccessPublishedApps     = $AccessPublishedApps | Select-Object PublishedName, AssociatedUserUPNs, AssociatedUserNames, AssociatedUserFullNames, Description, enabled
			NoAccessPublishedApps   = $NoAccessPublishedApps | Select-Object PublishedName, AssociatedUserUPNs, AssociatedUserNames, AssociatedUserFullNames, Description, enabled
			PublishedDesktops       = $PublishedDesktops
			DirectPublishedDesktops = $DirectPublishedDesktops
		} | Select-Object UserDetail, AllUserGroups, HSADesktop, userDeliveryGroup, UserDeliveryGroupUid, DirectPublishedApps, AccessPublishedApps, NoAccessPublishedApps, PublishedDesktops, DirectPublishedDesktops
		$ValidUser
	}
	$Details = @()
	if ($RunAsPSRemote -eq $true) { $Details = Invoke-Command -ComputerName $PSRemoteServerName -ScriptBlock ${Function:AllConfig} -ArgumentList  @($username,$adminserver, $DomainFQDN,$DomainCredentials, $VerbosePreference) -Credential $DomainCredentials }
	else { $Details = AllConfig -username $Username -adminserver $AdminServer -DomainFQDN $DomainFQDN -DomainCredentials $DomainCredentials -VerbosePreference $VerbosePreference }
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [End] All Details"
	$Details


}
