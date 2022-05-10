
<#PSScriptInfo

.VERSION 1.0.13

.GUID 71b2bc51-85ce-407b-ace5-96df009782d3

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
Created [05/05/2019_09:00]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:24]
Updated [06/06/2019_19:25]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports
Updated [01/07/2020_14:43] Script File Info was updated
Updated [01/07/2020_15:42] Script File Info was updated
Updated [01/07/2020_16:07] Script File Info was updated
Updated [01/07/2020_16:13] Script File Info was updated
Updated [06/03/2021_20:58] Script File Info was updated
Updated [15/03/2021_23:28] Script File Info was updated

#> 

<#
.SYNOPSIS
Show the changes that was made to the farm


.DESCRIPTION
Show the changes that was made to the farm

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER Indays
Use this time frame for the report.

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixConfigurationChange -AdminServer $CTXDDC -Indays 7

#>
Function Get-CitrixConfigurationChange {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixConfigurationChange')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int32]$Indays,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	if (-not(Get-PSSnapin -Registered | Where-Object {$_.name -like 'Citrix*'})) {Add-PSSnapin citrix* -ErrorAction SilentlyContinue}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Config Changes Details"

	$startdate = (Get-Date).AddDays(-$Indays)
	$exportpath = (Get-Item (Get-Item Env:\TEMP).value).FullName + '\ctxreportlog.csv'

	if (Test-Path $exportpath) { Remove-Item $exportpath -Force -ErrorAction SilentlyContinue }
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Progress] Exporting Changes"

	Export-LogReportCsv -AdminAddress $AdminServer -OutputFile $exportpath -StartDateRange $startdate -EndDateRange (Get-Date)
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Progress] Importing Changes"

	$LogExportAll = Import-Csv -Path $exportpath -Delimiter ','
	$LogExport = $LogExportAll | Where-Object { $_.'High Level Operation Text' -notlike '' } | Select-Object -Property High*
	$LogSum = $LogExportAll | Group-Object -Property 'High Level Operation Text' -NoElement

	Remove-Item $exportpath -Force -ErrorAction SilentlyContinue
	$CTXObject = New-Object PSObject -Property @{
		DateCollected = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		AllDetails    = $LogExportAll
		Filtered      = $LogExport
		Summary       = $LogSum
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Config Changes Details"
	
	if ($Export -eq 'Excel') { 
		$CTXObject | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixConfigurationChange-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName CitrixConfigurationChange -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
	}
	if ($Export -eq 'HTML') { 
		$CTXObject | Out-HtmlView -DisablePaging -Title 'Mashine Failures' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixConfigurationChange-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
        
	}
	if ($Export -eq 'Host') { 
		$CTXObject
	}
}