﻿
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
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixVDAUptime')]
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
		Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 1000000 | Where-Object {$_.DesktopGroupName -notlike $null -and $_.OSType -notlike '*10' -and $_.OSType -notlike '*11' } | ForEach-Object {
			try {
				$ctxobject = $_	
				$OS = Get-CimInstance Win32_OperatingSystem -ComputerName $_.DNSName -ErrorAction Stop | Select-Object *
				$Uptime = New-TimeSpan -Start $OS.LastBootUpTime -End (Get-Date)
				$updays = [math]::Round($uptime.Days, 0)
			} catch {
				try {
					Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"
					Write-Warning "Unable to remote to $($ctxobject.DNSName), defaulting uptime to LastRegistrationTime"
					if ($ctxobject.RegistrationState -like 'Registered') {
						$Uptime = New-TimeSpan -Start $ctxobject.LastRegistrationTime -End (Get-Date)
						$updays = [math]::Round($uptime.Days, 0)
					} else {$updays = 'Unknown'}
				} catch {
					Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"
					$updays = 'Unknown'
    }
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

	if ($Export -eq 'Excel') { 
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_VDA_Uptime-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$VDAUptime | Export-Excel -Title CitrixVDAUptime -WorksheetName CitrixVDAUptime @ExcelOptions
 }
	if ($Export -eq 'HTML') { 
		$ReportTitle = 'Citrix VDA Uptime'
		$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
		New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
				New-HTMLLogo -RightLogoString $XDHealth_LogoURL
			}
			if ($VDAUptime) { New-HTMLTab -Name 'VDA Uptime' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($VDAUptime) @TableSettings}}}
		}
	}
	if ($Export -eq 'Host') { $VDAUptime }


} #end Function
