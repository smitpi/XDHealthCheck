
<#PSScriptInfo

.VERSION 1.0.13

.GUID be2256e1-4b2c-460a-aa7f-10eac8f6d0c4

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Collects perform data for the core servers. 

#> 



} #end Function

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


#>

<#
.SYNOPSIS
Collects perform data for the core servers.

.DESCRIPTION
Collects perform data for the core servers.

.PARAMETER Export
Export the result to a report file. (Excel, html or Screen)

.PARAMETER ReportPath
Where to save the report.

.PARAMETER ComputerName
List of Computers to query.

.EXAMPLE
Get-CitrixServerPerformance -ComputerName $CTXCore

#>
Function Get-CitrixServerPerformance {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixServerPerformance')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string[]]$ComputerName,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	[System.Collections.ArrayList]$ServerPerfMon = @()
	foreach ($server in $ComputerName) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Performance Details for $($server.ToString())"
		$CtrList = @(
			'\Processor(_Total)\% Processor Time',
			'\memory\% committed bytes in use',
			'\LogicalDisk(C:)\% Free Space'
		)
		$perf = Get-Counter $CtrList -ComputerName $Server -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Services Details for $($server.ToString())"
		$services = [String]::Join(' ; ', ((Get-Service -ComputerName $Server | Where-Object {$_.starttype -eq 'Automatic' -and $_.status -eq 'Stopped'}).DisplayName))

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Uptime Details for $($server.ToString())"
		$OS = Get-CimInstance Win32_OperatingSystem -ComputerName $Server | Select-Object *
		$Uptime = New-TimeSpan -Start $OS.LastBootUpTime -End (Get-Date)
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

	if ($Export -eq 'Excel') {
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_Server_Performance-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$ServerPerfMon | Export-Excel -Title CitrixServerPerformance -WorksheetName CitrixServerPerformance @ExcelOptions
	}
	if ($Export -eq 'HTML') {
		$ReportTitle = 'Citrix Server Performance'
        $HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
        New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
            New-HTMLHeader {
                New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
                New-HTMLLogo -RightLogoString $XDHealth_LogoURL
            }
            if ($ServerPerfMon) { New-HTMLTab -Name 'Performance' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($ServerPerfMon) @TableSettings}}}
        }
	}
	if ($Export -eq 'Host') {
		$ServerPerfMon
	}
} #end Function
