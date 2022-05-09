
<#PSScriptInfo

.VERSION 0.1.0

.GUID 0ce11878-fa8b-442f-b178-9fcd71b6d844

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT 

.TAGS ctx

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [09/05/2022_12:55] Initial Script Creating

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Calculate the uptime of VDA Servers 

#> 


<#
.SYNOPSIS
Calculate the uptime of VDA Servers.

.DESCRIPTION
Calculate the uptime of VDA Servers. The script will filter out desktop machines and only report on severs. 
If the script cant remotely connect to the vda server, then the last registration date will be used.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixVDAUptime -AdminServer $CTXDDC

#>
Function Get-CitrixVDAUptime {
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/XDHealthCheck/Get-CitrixVDAUptime")]
        [OutputType([System.Object[]])]
        PARAM(
            [Parameter(Mandatory = $true, Position = 0)]
            [ValidateNotNull()]
            [ValidateNotNullOrEmpty()]
            [string]$AdminServer,
            [ValidateSet('Excel', 'HTML')]
            [string]$Export = 'Host',
            [ValidateScript( { if (Test-Path $_) { $true }
                    else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                })]
            [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
        )
      try {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] VDA Uptime"	
		[System.Collections.ArrayList]$VDAUptime = @() 
		Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 1000000 | Where-Object {$_.DesktopGroupName -notlike $null -and $_.OSType -notlike "*10" -and $_.OSType -notlike "*11" } | ForEach-Object {
			try {	
				$OS = Get-CimInstance Win32_OperatingSystem -ComputerName $_.DNSName -ErrorAction Stop | Select-Object *
				$Uptime = New-TimeSpan -Start $OS.LastBootUpTime -End (Get-Date)
				$updays = [math]::Round($uptime.Days, 0)
			} catch {
				try {
					Write-Warning "`t`tUnable to remote to $($_.DNSName), defaulting uptime to LastRegistrationTime"
					$Uptime = New-TimeSpan -Start $_.LastRegistrationTime -End (Get-Date)
					$updays = [math]::Round($uptime.Days, 0)
				} catch {$updays = 'Unknown'}
			}


			[void]$VDAUptime.Add([pscustomobject]@{
					ComputerName         = $_.dnsname
					DesktopGroupName     = $_.DesktopGroupName
					SessionCount         = $_.SessionCount
					InMaintenanceMode    = $_.InMaintenanceMode
					MachineInternalState = $_.MachineInternalState
					Uptime               = $updays
					LastRegistrationTime = $_.LastRegistrationTime
				})
		}
	} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}



	if ($Export -eq 'Excel') { $VDAUptime | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixVDAUptime-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Title 'CitrixVDAUptime' -WorksheetName CitrixVDAUptime -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3 -Show }
	if ($Export -eq 'HTML') { $VDAUptime | Out-GridHtml -DisablePaging -Title "CitrixVDAUptime" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixVDAUptime-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $VDAUptime }


} #end Function
