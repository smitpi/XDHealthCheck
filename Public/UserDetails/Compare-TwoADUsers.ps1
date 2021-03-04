
<#PSScriptInfo

.VERSION 1.0.10

.GUID 541ded25-9c56-4f57-bd42-8cb0799f331b

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT

.TAGS Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [17/05/2019_04:24]
Updated [22/05/2019_20:14]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:26]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports
Updated [01/07/2020_14:43] Script Fle Info was updated
Updated [01/07/2020_15:42] Script Fle Info was updated
Updated [01/07/2020_16:07] Script Fle Info was updated
Updated [01/07/2020_16:13] Script Fle Info was updated

.PRIVATEDATA

#> 





















<#

.DESCRIPTION 
Function for Citrix XenDesktop HTML Health Check Report

#>

Param()

Function Compare-TwoADUsers {
		PARAM(
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username1,
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username2)

	$ValidUser1 = Get-ADUser $Username1 -Properties * | Select-Object Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
	$ValidUser2 = Get-ADUser $Username2 -Properties * | Select-Object Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
	$userDetailList1 = $ValidUser1.psobject.Properties | Select-Object -Property Name, Value
	$userDetailList2 = $ValidUser2.psobject.Properties | Select-Object -Property Name, Value

	$user1Headding = $ValidUser1.Name
	$user2Headding = $ValidUser2.Name
	$user1HeaddingMissing = $ValidUser1.Name + ' Missing'
	$user2HeaddingMissing = $ValidUser2.Name + ' Missing'

	$allusergroups1 = Get-ADUser $Username1 -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object { Get-ADGroup $_ } | Select-Object samaccountname
	$allusergroups2 = Get-ADUser $Username2 -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object { Get-ADGroup $_ } | Select-Object samaccountname

	$Compare = Compare-Object -ReferenceObject $allusergroups1 -DifferenceObject $allusergroups2 -Property samaccountname -IncludeEqual

	$SameGroups = $Compare | Where-Object { $_.SideIndicator -eq '==' } | Select-Object samaccountname
	$User1Missing = $Compare | Where-Object { $_.SideIndicator -eq '=>' } | Select-Object samaccountname
	$User2Missing = $Compare | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object samaccountname


	$User1Details = New-Object PSObject -Property @{
		ValidUser1           = $ValidUser1
		userDetailList1      = $userDetailList1
		user1Headding        = $user1Headding
		user1HeaddingMissing = $user1HeaddingMissing
		allusergroups1       = $allusergroups1
		User1Missing         = $User1Missing
	}
	$User2Details = New-Object PSObject -Property @{
		ValidUser2           = $ValidUser2
		userDetailList2      = $userDetailList2
		user2Headding        = $user2Headding
		user2HeaddingMissing = $user2HeaddingMissing
		allusergroups2       = $allusergroups2
		User2Missing         = $User2Missing
	}

	$Details = New-Object PSObject -Property @{
		User1Details = $User1Details
		User2Details = $User2Details
		SameGroups   = $SameGroups
	}
	$Details

} #end Function
