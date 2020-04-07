
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




function Get-UserCitrixAccess {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(Mandatory = $false, Position = 1)]
		[switch]$RunAsPSRemote = $false,
		[Parameter(Mandatory = $false, Position = 2)]
		[String]$PSRemoteServerName,
		[Parameter(Mandatory = $false, Position = 3)]
        [PSCredential]$PSRemoteCredentials)

		function AllConfig {
			param($username, $VerbosePreference)
		$AllUserGroups = Get-ADUser -Identity $username -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object { Get-ADGroup $_ | Select-Object SamAccountName }
		$DLGGroups = $AllUserGroups | Where-Object { $_.SamAccountName -like "*DLG*" } | ForEach-Object { $_.SamAccountName }
		$PUBGroups = $AllUserGroups | Where-Object { $_.SamAccountName -like "*PUB*" } | ForEach-Object { $_.SamAccountName }
		if ($AllUserGroups | Where-Object { $_.SamAccountName -like "Citrix-PROD-AA-PUB-Desktop" }) {
			$HostedDesktop = $DLGGroups
		}
		else {$HostedDesktop = 'No Hosted Desktops'}

		}
		$Details = @()

		if ($RunAsPSRemote -eq $true) { $Details = Invoke-Command -ComputerName $PSRemoteServerName -ScriptBlock ${Function:AllConfig} -ArgumentList  @($username, $VerbosePreference) -Credential $PSRemoteCredentials }

		else { $Details = AllConfig -username $Username -VerbosePreference $VerbosePreference }
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [End] All Details"
		$Details


	}
