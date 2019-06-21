
<#PSScriptInfo

.VERSION 1.0.5

.GUID 8f756c95-9e99-4932-bdd9-b63c4b98405b

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
Created [23/05/2019_00:00]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:26]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports

.PRIVATEDATA

#>

Function Get-FullUserDetail {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$UserToQuery,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$DomainFQDN,
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$DomainCredentials,
		[Parameter(Mandatory = $false, Position = 3)]
		[switch]$RunAsPSRemote = $false,
		[Parameter(Mandatory = $false, Position = 4)]
		[String]$PSRemoteServerName,
		[Parameter(Mandatory = $false, Position = 5)]
        [PSCredential]$PSRemoteCredentials
)

	function AllConfig {
		param($UserToQuery, $DomainFQDN,[PSCredential]$DomainCredentials, $VerbosePreference)

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] User Details"

		$UserSummery = Get-ADUser $UserToQuery -Server $DomainFQDN -Credential $DomainCredentials -Properties * | Select-Object Name, GivenName, Surname, UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate, samaccountname
		$AllUserDetails = Get-ADUser $UserToQuery -Properties * -Server $DomainFQDN -Credential $DomainCredentials
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] User Groups"
		$AllUserGroups = Get-ADUser $UserToQuery -Properties * -Server $DomainFQDN -Credential $DomainCredentials | Select-Object -ExpandProperty memberof | ForEach-Object { Get-ADGroup $_ -Server $DomainFQDN -Credential $DomainCredentials }
		$CusObject = New-Object PSObject -Property @{
			DateCollected  = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			UserSummery    = $UserSummery
			AllUserDetails = $AllUserDetails
			AllUserGroups  = $AllUserGroups
		}
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] User Details"
		$CusObject
	}
	$FarmDetails = @()
	if ($RunAsPSRemote -eq $true) { $FarmDetails = Invoke-Command -ComputerName $PSRemoteServerName -ScriptBlock ${Function:AllConfig} -ArgumentList  @($UserToQuery, $DomainFQDN, $DomainCredentials, $VerbosePreference) -Credential $PSRemoteCredentials }
	else { $FarmDetails = AllConfig -UserToQuery $UserToQuery -DomainFQDN $DomainFQDN -DomainCredentials $DomainCredentials -VerbosePreference $VerbosePreference }
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [End] All Details"
	$FarmDetails


} #end Function

