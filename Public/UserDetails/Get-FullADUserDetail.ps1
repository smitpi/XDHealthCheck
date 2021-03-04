
<#PSScriptInfo

.VERSION 1.0.8

.GUID 8f756c95-9e99-4932-bdd9-b63c4b98405b

.AUTHOR Pierre Smit

.COMPANYNAME

.COPYRIGHT

.TAGS AD

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES ActiveDirectory

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [23/05/2019_00:00]
Updated [24/05/2019_19:25]
Updated [26/05/2019_15:58]
Updated [26/05/2019_16:05]
Updated [26/05/2019_16:41]
Updated [26/05/2019_16:47]
Updated [26/05/2019_16:48] testing
Updated [03/06/2019_12:13]
Updated [20/06/2019_19:58]

.PRIVATEDATA

#>



<#

.DESCRIPTION
Get user AD details



#>
Param()



Function Get-FullADUserDetail {
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$UserToQuery)


	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] User Details"
	$UserSummery = Get-ADUser $UserToQuery -Properties * | Select-Object Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
	$AllUserDetails = Get-ADUser $UserToQuery -Properties * 
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] User Groups"
	$AllUserGroups = Get-ADUser $UserToQuery -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object { Get-ADGroup $_ }
	$CusObject = New-Object PSObject -Property @{
		DateCollected  = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		UserSummery    = $UserSummery
		AllUserDetails = $AllUserDetails
		AllUserGroups  = $AllUserGroups
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] User Details"
	$CusObject
	
} #end Function

