
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



Function Get-CitrixPublishedApplications {
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

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Config"
Function GetAllConfig {
	param($AdminServer, $VerbosePreference)

Add-PSSnapin citrix*
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Delivery Groups"
$DG = Get-BrokerDesktopGroup -AdminAddress $AdminServer
$ReadAbleDG = @()
foreach ($item in $DG) {
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($item.name.ToString())"
	$BrokerAccess = @()
	$BrokerGroups = @()
	$BrokerAccess = Get-BrokerAccessPolicyRule -DesktopGroupUid $item.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike "" } } | select UPN
	$BrokerGroups = Get-BrokerAccessPolicyRule -DesktopGroupUid $item.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like "" } } | select Fullname
    if ([bool]$BrokerAccess.UPN) {$UsersCSV = [String]::Join(';', $BrokerAccess.UPN)}
    else{$UsersCSV = ''}
    if ([bool]$BrokerGroups.FullName) {$GroupsCSV = [String]::Join(';', $BrokerGroups.FullName)}
    else{$GroupsCSV = ''}    
    $CusObject = New-Object PSObject -Property @{
		DesktopGroupName       = $item.name
		Uid                    = $item.uid
		DeliveryType           = $item.DeliveryType
		DesktopKind            = $item.DesktopKind
        Description            = $item.Description
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
        Tags                   = $item.Tags
		IncludedUser           = @($BrokerAccess.UPN)
		IncludeADGroups        = @($BrokerGroups.FullName)
		IncludedUserCSV        = $UsersCSV
		IncludeADGroupsCSV     = $GroupsCSV
		} | select DesktopGroupName,Uid,DeliveryType,DesktopKind,Description,DesktopsDisconnected,DesktopsFaulted,DesktopsInUse,DesktopsUnregistered,Enabled,IconUid,InMaintenanceMode,SessionSupport,TotalApplicationGroups,TotalApplications,TotalDesktops,Tags,IncludedUser,IncludeADGroups,IncludedUserCSV,IncludeADGroupsCSV
		$ReadAbleDG += $CusObject
	}

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Application config"
$HostedApps = @()
foreach ($DeskG in ($ReadAbleDG | where { $_.DeliveryType -like 'DesktopsAndApps' })) {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DeskG.DesktopGroupName.ToString())"
	$PublishedApps = Get-BrokerApplication -AssociatedDesktopGroupUid $DeskG.Uid -AdminAddress $AdminServer
	foreach ($PublishedApp in $PublishedApps) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Published Application: $($DeskG.DesktopGroupName.ToString()) - $($PublishedApp.PublishedName.ToString())"
		$PublishedAppGroup = @()
		$PublishedAppUser = @()
		foreach ($item in $PublishedApp.AssociatedUserFullNames) {
			try {
				$group = $null
				$group = Get-ADGroup $item
				if ($group -ne $null) { $PublishedAppGroup += $group.SamAccountName }
			}
			catch { }
		}
		foreach ($item2 in $PublishedApp.AssociatedUserUPNs) {
			try {
				$PublishedAppUser += $item2
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
		} | select  DesktopGroupName,DesktopGroupUid,DesktopGroupUsers,DesktopGroupADGroups,DesktopGroupUsersCSV,DesktopGroupADGroupsCSV,ApplicationName,ApplicationType,AdminFolderName,ClientFolder,Description,Enabled,CommandLineExecutable,CommandLineArguments,WorkingDirectory,Tags,PublishedName,PublishedAppName,PublishedAppGroup,PublishedAppUser,PublishedAppGroupCSV,PublishedAppUserCSV
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
if ($RunAsPSRemote -eq $true) { $AppDetail = Invoke-Command -ComputerName $AdminServer -ScriptBlock ${Function:GetAllConfig} -ArgumentList  @($AdminServer, $VerbosePreference) -Credential $RemoteCredentials }
else { $AppDetail = GetAllConfig -AdminServer $AdminServer -VerbosePreference $VerbosePreference}
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending] All Details"
$AppDetail | select DateCollected, DeliveryGroups, PublishedApps

} #end Function
