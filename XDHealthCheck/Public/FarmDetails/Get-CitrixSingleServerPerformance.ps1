
<#PSScriptInfo

.VERSION 1.0.7

.GUID 28827783-e97e-432f-bf46-c01e8c3c8299

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
Created [05/05/2019_08:59]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:25]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports

.PRIVATEDATA

#>















<#

.DESCRIPTION
Xendesktop Farm Details

#>

Param()



Function Get-CitrixSingleServerPerformance {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Server,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Performance Details for $($server.ToString())"
	$CtrList = @(
		"\Processor(_Total)\% Processor Time",
		"\memory\% committed bytes in use",
		"\LogicalDisk(C:)\% Free Space",
		"\LogicalDisk(D:)\% Free Space"
	)
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Perfmon Details for $($server.ToString())"
	$perf = Get-Counter $CtrList -ComputerName $server  -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Services Details for $($server.ToString())"
	$services = Get-Service -ComputerName $server citrix* | Where-Object { ($_.starttype -eq "Automatic" -and $_.status -eq "Stopped") }
	if ([bool]$Services.DisplayName -eq $true) { $ServicesJoin = [String]::Join(';', $Services.DisplayName) }
	else { $ServicesJoin = '' }

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Uptime Details for $($server.ToString())"
	$OS = Get-CimInstance Win32_OperatingSystem -ComputerName $server | Select-Object *
	$Uptime = (Get-Date) - ($OS.LastBootUpTime)
	$updays = [math]::Round($uptime.Days, 0)

	$CTXObject = New-Object PSCustomObject -Property @{
		DateCollected      = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		ServerName         = $Server
		'CPU %'            = [Decimal]::Round(($perf[0].CookedValue), 2).tostring()
		'Memory %'         = [Decimal]::Round(($perf[1].CookedValue), 2).tostring()
		'CDrive % Free'    = [Decimal]::Round(($perf[2].CookedValue), 2).tostring()
		'DDrive % Free'      = [Decimal]::Round(($perf[3].CookedValue), 2).tostring()
		Uptime             = $updays.tostring()
		'Stopped Services' = $ServicesJoin
	} | Select-Object ServerName, 'CPU %', 'Memory %', 'CDrive % Free', 'DDrive % Free', Uptime, 'Stopped Services'
	$CTXObject
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Performance Details for $($server.ToString())"

} #end Function
