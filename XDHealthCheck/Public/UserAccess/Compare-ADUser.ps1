
<#PSScriptInfo

.VERSION 1.0.3

.GUID d972299f-af10-4c8b-a5fa-1ce80d8892af

.AUTHOR Pierre Smit

.COMPANYNAME

.COPYRIGHT

.TAGS AD

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [07/06/2019_03:58]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports

.PRIVATEDATA

#>







<#

.DESCRIPTION
Find the diferences in ad groups

#>

Param()



Function Compare-ADUser {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username1,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username2,
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
		[String]$PSRemoteServerName,
		[Parameter(Mandatory = $false, Position = 5)]
        [PSCredential]$PSRemoteCredentials)

		$ValidUser1 = Get-FullUserDetail -UserToQuery $Username1 -DomainFQDN $DomainFQDN -DomainCredentials $DomainCredentials -RunAsPSRemote -PSRemoteServerName $PSRemoteServerName -PSRemoteCredentials $PSRemoteCredentials
		$ValidUser2 = Get-FullUserDetail -UserToQuery $Username2 -DomainFQDN $DomainFQDN -DomainCredentials $DomainCredentials -RunAsPSRemote -PSRemoteServerName $PSRemoteServerName -PSRemoteCredentials $PSRemoteCredentials
		$userDetailList1 = $ValidUser1.UserSummery.psobject.Properties | Select-Object -Property Name, Value
		$userDetailList2 = $ValidUser2.UserSummery.psobject.Properties | Select-Object -Property Name, Value

		$user1Headding = $ValidUser1.UserSummery.Name
		$user2Headding = $ValidUser2.UserSummery.Name
		$user1HeaddingMissing = $ValidUser1.UserSummery.Name + " Missing"
		$user2HeaddingMissing = $ValidUser2.UserSummery.Name + " Missing"

		$allusergroups1 = $ValidUser1.AllUserGroups | Select-Object samaccountname
		$allusergroups2 = $ValidUser2.AllUserGroups | Select-Object samaccountname

		$Compare = Compare-Object -ReferenceObject $allusergroups1 -DifferenceObject $allusergroups2 -Property samaccountname -IncludeEqual

		$SameGroups = $Compare | Where-Object { $_.SideIndicator -eq '==' } | Select-Object samaccountname
		$User1Missing = $Compare | Where-Object { $_.SideIndicator -eq '=>' } | Select-Object samaccountname
		$User2Missing = $Compare | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object samaccountname


		$User1Details = New-Object PSObject  -Property @{
			ValidUser1           = $ValidUser1
			userDetailList1      = $userDetailList1
			user1Headding        = $user1Headding
			user1HeaddingMissing = $user1HeaddingMissing
			allusergroups1       = $allusergroups1
			User1Missing         = $User1Missing
		}
		$User2Details = New-Object PSObject  -Property @{
			ValidUser2           = $ValidUser2
			userDetailList2      = $userDetailList2
			user2Headding        = $user2Headding
			user2HeaddingMissing = $user2HeaddingMissing
			allusergroups2       = $allusergroups2
			User2Missing         = $User2Missing
		}

		$Details = New-Object PSObject  -Property @{
			User1Details = $User1Details
			User2Details = $User2Details
			SameGroups   = $SameGroups
		}
		$Details

	} #end Function

