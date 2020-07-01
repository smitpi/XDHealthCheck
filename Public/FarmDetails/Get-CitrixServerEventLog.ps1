
<#PSScriptInfo

.VERSION 1.0.11

.GUID 092feba0-b391-4f5a-a3db-41b191cc52fc

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
Created [05/05/2019_08:59]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:25]
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



Function Get-CitrixServerEventLog {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[array]$Serverlist,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int32]$Days,
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)

	function events {
  param($Server, $days, $VerbosePreference)
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Eventlog Details"

		$eventtime = (Get-Date).AddDays(-$days)
		$ctxevent = Get-WinEvent -ComputerName $server -FilterHashTable @{LogName = 'Application', 'System'; Level = 2, 3; StartTime = $eventtime } -ErrorAction SilentlyContinue | Select-Object MachineName, TimeCreated, LogName, ProviderName, Id, LevelDisplayName, Message
		$servererrors = $ctxevent | Where-Object -Property LevelDisplayName -EQ "Error"
		$serverWarning = $ctxevent | Where-Object -Property LevelDisplayName -EQ "Warning"
		$TopProfider = $ctxevent | Where-Object { $_.LevelDisplayName -EQ "Warning" -or $_.LevelDisplayName -eq "Error" } | Group-Object -Property ProviderName | Sort-Object -Property count -Descending | Select-Object Name, Count

		$CTXObject = New-Object PSObject -Property @{
			ServerName  = ([System.Net.Dns]::GetHostByName(($env:computerName))).hostname
			Errors      = $servererrors.Count
			Warning     = $serverWarning.Count
			TopProfider = $TopProfider
			All         = $ctxevent
		}
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Eventlog Details"
		$CTXObject
	}

	$Eventlogs = @()
	foreach ($server in $Serverlist) {
		$logs = Invoke-Command -ComputerName $Server -ScriptBlock ${Function:events} -ArgumentList  @($Server, $days, $VerbosePreference) -Credential $RemoteCredentials
		$Eventlogs += $logs
	}

	$Eventlogs | ForEach-Object {
		$TotalErrors = $TotalErrors + $_.Errors
		$TotalWarnings = $TotalWarnings + $_.Warning
 }
	[array]$TotalProvider += $Eventlogs | ForEach-Object { $_.TopProfider }
	[array]$TotalAll += $Eventlogs | ForEach-Object { $_.all }

	$CTXObject = New-Object PSObject -Property @{
		DateCollected = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		SingleServer  = $Eventlogs | Select-Object ServerName, Errors, Warning, TopProfider, All
		TotalErrors   = $TotalErrors
		TotalWarnings = $TotalWarnings
		TotalProvider = $TotalProvider | Sort-Object -Property count -Descending
		TotalAll      = $TotalAll
	}
	$CTXObject

} #end Function

