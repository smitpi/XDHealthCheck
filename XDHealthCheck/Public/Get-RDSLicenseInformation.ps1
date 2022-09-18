
<#PSScriptInfo

.VERSION 1.0.15

.GUID 103eea54-f3e2-4cb2-abe1-78ac793afdbc

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
 Report on RDS License Usage 

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
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\RDS_License_Information-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$CTXObject.'Per Device' | Export-Excel -Title 'Per Device' -WorksheetName 'Per Device' @ExcelOptions
		$CTXObject.'Per User' | Export-Excel -Title 'Per User' -WorksheetName 'Per User' @ExcelOptions
	}
	if ($Export -eq 'HTML') { 
		$ReportTitle = 'RDS_License_Information'
		$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
		New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
				New-HTMLLogo -RightLogoString $XDHealth_LogoURL
			}
			if ($CTXObject.'Per Device') { New-HTMLTab -Name 'Per Device' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($CTXObject.'Per Device') @TableSettings}}}
			if ($CTXObject.'Per User') { New-HTMLTab -Name 'Per User' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($CTXObject.'Per User') @TableSettings}}}
		}     
	}
	if ($Export -eq 'Host') { 
		$CTXObject
	}


} #end Function

