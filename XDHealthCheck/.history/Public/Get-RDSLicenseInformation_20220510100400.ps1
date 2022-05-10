
<#PSScriptInfo

.VERSION 1.0.15

.GUID 284fb68d-acc2-4b5f-aa04-3d0fb6fbcdc0

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
Created [05/05/2019_09:01]
Updated [13/05/2019_04:37]
Updated [13/05/2019_04:38]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:26]
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
<#
.SYNOPSIS
Report on RDS License Usage

.DESCRIPTION
Report on RDS License Usage

.PARAMETER LicenseServer
RDS License server name.

.PARAMETER Export
Export the result to a report file. (Excel, html or Screen)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-RDSLicenseInformation -LicenseServer $RDSLicenseServer

#>
Function Get-RDSLicenseInformation {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-RDSLicenseInformation')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$LicenseServer,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
		)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] RDS Details"
	try {
		$RDSLicense = Get-CimInstance Win32_TSLicenseKeyPack -ComputerName $LicenseServer -ErrorAction stop | Select-Object -Property TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses
	} catch {Write-Warning "Unable to connect to RDS License server: $($LicenseServer)"}
	$CTXObject = New-Object PSObject -Property @{
		'Per Device' = $RDSLicense | Where-Object { $_.TypeAndModel -eq 'RDS Per Device CAL' }
		'Per User'   = $RDSLicense | Where-Object { $_.TypeAndModel -eq 'RDS Per User CAL' }
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] RDS Details"

	if ($Export -eq 'Excel') { 
		$CTXObject | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixConfigurationChange-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName CitrixConfigurationChange -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
	}
	if ($Export -eq 'HTML') { 
		$CTXObject | Out-HtmlView -DisablePaging -Title 'Mashine Failures' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixConfigurationChange-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
        
	}
	if ($Export -eq 'Host') { 
		$CTXObject
	}


} #end Function

