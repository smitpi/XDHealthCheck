
<#PSScriptInfo

.VERSION 1.0.2

.GUID a90021c2-9c0b-462b-a0c2-5bffaadab328

.AUTHOR Pierre Smit

.COMPANYNAME  

.COPYRIGHT

.TAGS Windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [09/06/2019_12:53]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports

.PRIVATEDATA

#> 





<#

.DESCRIPTION 
Xendesktop Farm Details

#>

Param()



Function Get-CitrixServerPerformance {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[array]$Serverlist,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)

	$CitrixServerPerformance = @()
	foreach ($Server in $Serverlist) {
		$SingleServer = Get-CitrixSingleServerPerformance -Server $Server -RemoteCredentials $RemoteCredentials
		$CusObject = New-Object PSObject -Property @{
			DateCollected      = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			Servername         = $SingleServer.ServerName
			'CPU_%'            = $SingleServer.'CPU_%'
			'Memory_%'         = $SingleServer.'Memory_%'
			'CDrive_Free'      = $SingleServer.'CDrive_Free'
			'DDrive_Free'      = $SingleServer.'DDrive_Free'
			Uptime             = $SingleServer.Uptime
			'Stopped_Services' = $SingleServer.StoppedServices
		} | Select-Object ServerName, 'CPU_%', 'Memory_%', 'CDrive_Free', 'DDrive_Free', Uptime, 'Stopped_Services'
		$CitrixServerPerformance += $CusObject
	}

	$CitrixServerPerformance
} #end Function

