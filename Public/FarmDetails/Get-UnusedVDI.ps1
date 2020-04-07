
<#PSScriptInfo

.VERSION 1.0.0

.GUID 63d2a7b2-1363-4bdf-a836-497840001e90

.AUTHOR Pierre Smit

.COMPANYNAME

.COPYRIGHT

.TAGS citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [09/09/2019_14:10] Initital Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 List VDIs not used

#>

Param()



Function Get-UnusedVDI {
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int32]$Days,
		[Parameter(Mandatory = $false, Position = 2)]
		[switch]$ExportToExcel = $false,
		[ValidateScript( { if (-Not ($_ | Test-Path) ) { throw "Folder does not exist" } return $true })]
		[string]$ReportPath)

	Add-PSSnapin citrix*

	$LastLogonDate = (Get-Date).AddDays(-$Days)
	$Result = @()
	$ListVDI = Get-BrokerMachine -OSType "Windows 10" -IsAssigned $true -maxrecordcount 10000 -adminaddress $AdminServer | Where-Object { $_.LastConnectionTime -le $LastLogonDate -and $null -ne $_.LastConnectionTime -and $_.CatalogName -ne 'REMOTE-PC' } | Select-Object DNSName, DesktopGroupName, AssociatedUserNames, LastConnectionTime, MachineName | Sort-Object -Property DNSName

	foreach ($svdi in $listvdi) {
		try {
			$Events = $null
			$AllEvents = Get-WinEvent -ComputerName $svdi.DNSName -FilterHashTable @{LogName = 'Microsoft-Windows-Winlogon/Operational'; ID = '811'; StartTime = $LastLogonDate } | Where-Object { $_.UserId -ne "S-1-5-18" }
			$Events = ($AllEvents | Select-Object TimeCreated, UserId | Group-Object -Property UserId | Sort-Object -Property Count -Descending)[0]
			$LastEvent = ($AllEvents | Select-Object TimeCreated, UserId | Sort-Object -Property TimeCreated -Descending)[0]
		} catch { Write-Warning "[$((Get-Date -Format HH:mm:ss).ToString())] Could not find events on: $($svdi.dnsname.ToString())" }

	if ($Events.Count -gt 0) {
		try {
			$username = $null
				$username = "CORP\" + (Get-ADUser $Events.name | ForEach-Object { $_.name })
		} catch { $username = "D_ABSA\" + (Get-ADUser $Events.Name -Server ds1.ad.absa.co.za | ForEach-Object { $_.name }) }
		$VDAEvent = New-Object PSObject -Property @{
			DNSName               = $svdi.DNSName
			DesktopGroupName      = $svdi.DesktopGroupName
			AssociatedUserNames   = @(($svdi.AssociatedUserNames) | Out-String).Trim()
			CTXLastConnectionTime = $svdi.LastConnectionTime
			AssignmentDate        = (Get-LogLowLevelOperation -adminaddress $AdminServer  -Text ("Add User*" + $svdi.MachineName + "*") | Sort-Object -Property EndTime -Descending)[0] | ForEach-Object { $_.EndTime }
			OtherLogonCount       = $Events.Count
			OtherLastLogon        = $LastEvent.TimeCreated
			OtherLogonUsername    = $username
		} | Select-Object DNSName, DesktopGroupName, AssociatedUserNames, CTXLastConnectionTime, AssignmentDate, OtherLogonCount, OtherLastLogon, OtherLogonUsername
		$result += $VDAEvent
	} else {
		$VDAEvent = New-Object PSObject -Property @{
			DNSName               = $svdi.DNSName
			DesktopGroupName      = $svdi.DesktopGroupName
			AssociatedUserNames   = @(($svdi.AssociatedUserNames) | Out-String).Trim()
			CTXLastConnectionTime = $svdi.LastConnectionTime
			AssignmentDate        = (Get-LogLowLevelOperation -adminaddress $AdminServer  -Text ("Add User*" + $svdi.MachineName + "*") | Sort-Object -Property EndTime -Descending)[0] | ForEach-Object { $_.EndTime }
			OtherLogonCount       = "none"
			OtherLastLogon        = "none"
			OtherLogonUsername    = "none"
		} | Select-Object DNSName, DesktopGroupName, AssociatedUserNames, CTXLastConnectionTime, AssignmentDate, OtherLogonCount, OtherLastLogon, OtherLogonUsername
		$result += $VDAEvent
	}
	}
	if ($ExportToExcel) { $Result | Export-Excel -Path ($ReportPath + "\UnUsedVDI_" + (Get-Date -Format dd_MM_yyyy) + ".xlsx") -WorksheetName 'VDI' -AutoSize -AutoFilter }
	else { $Result }
} #end Function

