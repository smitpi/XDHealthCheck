
<#PSScriptInfo

.VERSION 1.0.0

.GUID 2546a5c6-3f4a-4fc1-9150-f735f56aca14

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
Created [14/07/2019_08:32] Initital Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 XDHealthCheck Netscaler

#>

Param()



Function Get-CitrixNetscalerDetails {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[string]$NSIP,
		[Parameter(Mandatory = $true, Position = 1)]
		[PSCredential]$NSCredentials,
		[Parameter(Mandatory = $false, Position = 2)]
		[switch]$RunAsPSRemote = $false,
		[Parameter(Mandatory = $false, Position = 3)]
		[string]$RemoteServer,
		[Parameter(Mandatory = $false, Position = 4)]
		[PSCredential]$RemoteCredentials)

	function getns {
		[CmdletBinding()]
		param($NSIP, [SecureString] $NSCredentials)
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Connecting to Netscaler"
		Connect-NetScaler -IPAddress $NSIP -Credential $NSCredentials
Try {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Site Details"
		[PSCustomObject]@{
			DateCollected   = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			NSDetails       = [PSCustomObject]@{
				Name                = (Get-NSHostname).hostname
				'Last Backup Date'  = (Get-NSBackup)[ - 1].creationtime
				'Last Backup Name'  = (Get-NSBackup)[ - 1].filename
				'Last Backup Level' = (Get-NSBackup)[ - 1].Level
				Version             = (Get-NSVersion).DisplayName
				'HA State'         = (Get-NSHANode | Where-Object { $_.ipaddress -like $nsip }).state
				'HA Status'         = (Get-NSHANode | Where-Object { $_.ipaddress -like $nsip }).hastatus
			} | Select-Object Name,'Last Backup Date','Last Backup Name','Last Backup Level',Version,'HA State','HA Status'
			NSIP4           = Get-NSIPResource | Select-Object ipaddress, type, vserver
			NSCert          = Get-NSSSLCertificate | Select-Object certkey, daystoexpiration, subject, linkcertkeyname
			NSLBVServer     = Get-NSLBVirtualServer | Select-Object	name, ipv46, port, servicetype, curstate, effectivestate, health
			NSLBSG          = Get-NSLBServiceGroup | ForEach-Object { Get-NSLBServiceGroupMemberBinding -Name $_.servicegroupname | Select-Object servername, servicegroupname, ip, port, svrstate, state }
			NSGateway       = Get-NSVPNVirtualServer | Select-Object name, ipv46, type, curstate, state, csvserver, vserverfqdn
			NSContentSwitch = Get-NSCSVirtualServer | Select-Object name, ipv46, type, curstate, state
		} | Select-Object DateCollected, NSDetails, NSIP4, NSCert, NSLBVServer, NSLBSG, NSGateway, NSContentSwitch
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Disconnecting"

		Disconnect-NetScaler
}
catch { }
		#$ALLNS
	}
	$NSDetails = @()
	if ($RunAsPSRemote -eq $true) { $NSDetails = Invoke-Command -ComputerName $RemoteServer -ScriptBlock ${Function:getns} -ArgumentList  @($NSIP, $NSCredentials) -Credential $RemoteCredentials }
	else { $NSDetails = getns -NSIP $NSIP -NSCredentials $NSCredentials }
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [End] All Details"
	$NSDetails
} #end Function

