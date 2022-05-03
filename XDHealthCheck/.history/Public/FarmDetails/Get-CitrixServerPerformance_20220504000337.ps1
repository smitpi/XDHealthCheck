
<#PSScriptInfo

.VERSION 1.0.13

.GUID 28827783-e97e-432f-bf46-c01e8c3c8299

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

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
Updated [06/03/2021_20:58] Script Fle Info was updated
Updated [15/03/2021_23:28] Script Fle Info was updated

#> 



<#

.DESCRIPTION 
Function for Citrix XenDesktop HTML Health Check Report

#>
# .ExternalHelp  XDHealthCheck-help.xml


Function Get-CitrixServerPerformance {
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Uptime Details for $($server.ToString())"
	$OS = Get-CimInstance Win32_OperatingSystem -ComputerName $Server | Select-Object *
	$Uptime = (Get-Date) - ($OS.LastBootUpTime)
	$updays = [math]::Round($uptime.Days, 0)

	[void]$ServerPerfMon.Add([pscustomobject]@{
			DateCollected      = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			ServerName         = $Server
			'CPU %'            = [Decimal]::Round(($perf[0].CookedValue), 2).tostring()
			'Memory %'         = [Decimal]::Round(($perf[1].CookedValue), 2).tostring()
			'C Drive % Free'   = [Decimal]::Round(($perf[2].CookedValue), 2).tostring()
			Uptime             = $updays.tostring()
			'Stopped Services' = $Services
		})
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Performance Details for $($server.ToString())"
}
$ServerPerfMon
} #end Function

	$services = [String]::Join(' ; ', ((Get-Service -ComputerName $Server | Where-Object {$_.starttype -eq "Automatic" -and $_.status -eq "Stopped"}).DisplayName))

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Uptime Details for $($server.ToString())"
	$OS =  get-CimInstance Win32_OperatingSystem -ComputerName $Server | Select-Object *
	$Uptime = (Get-Date) - ($OS.LastBootUpTime)
	$updays = [math]::Round($uptime.Days, 0)

	[void]$ServerPerfMon.Add([pscustomobject]@{
		DateCollected      = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		ServerName         = $Server
		'CPU %'            = [Decimal]::Round(($perf[0].CookedValue), 2).tostring()
		'Memory %'         = [Decimal]::Round(($perf[1].CookedValue), 2).tostring()
		'C Drive % Free'    = [Decimal]::Round(($perf[2].CookedValue), 2).tostring()
		Uptime             = $updays.tostring()
		'Stopped Services' = $Services
	})
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Performance Details for $($server.ToString())"
}
$ServerPerfMon
} #end Function

