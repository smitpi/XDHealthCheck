
<#PSScriptInfo

.VERSION 1.0.3

.GUID 5d786907-3d5c-431d-a8ad-eadbacf8bd5f

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
Created [03/04/2021_10:50] Initital Script Creating
Updated [06/04/2021_09:03] Script Fle Info was updated
Updated [20/04/2021_10:42] Script Fle Info was updated
Updated [22/04/2021_11:42] Script Fle Info was updated

.PRIVATEDATA

#> 

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor




<# 

.DESCRIPTION 
Report on Citrix Configuration.

#> 
Param()

Function Get-CTXONP_ConfigAudit {
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[string]$DDC,
		[Parameter(Mandatory = $true, Position = 6)]
		[ValidateSet('Excel', 'HTML', 'Host')]
		[string]$Export,
		[Parameter(Mandatory = $false, Position = 7)]
		[ValidateScript( { (Test-Path $_) })]
		[string]$ReportPath = $env:temp
	)
    Add-PSSnapin citrix* -ErrorAction SilentlyContinue

    $SiteName = Get-BrokerSite -AdminAddress $DDC | ForEach-Object {$_.Name}
    $CitrixObjects = Get-CitrixObjects -AdminServer $ddc
	$catalogs = $CitrixObjects.MachineCatalog
	$deliverygroups = $CitrixObjects.DeliveryGroups
	$apps = $CitrixObjects.PublishedApps
	$VDAServers = $CitrixObjects.VDAServers
    $workstations = $CitrixObjects.VDAWorkstations

	if ($Export -eq 'Excel') { 
		[string]$ExcelReportname = $ReportPath + "\XD_Audit-$SiteName-" + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx'
		$catalogs | Export-Excel -Path $ExcelReportname -WorksheetName Catalogs -AutoSize -AutoFilter
		$deliverygroups | Export-Excel -Path $ExcelReportname -WorksheetName DeliveryGroups -AutoSize -AutoFilter
		$apps | Export-Excel -Path $ExcelReportname -WorksheetName apps -AutoSize -AutoFilter
		$VDAServers | Export-Excel -Path $ExcelReportname -WorksheetName VDAServers -AutoSize -AutoFilter
		$workstations | Export-Excel -Path $ExcelReportname -WorksheetName VDAWorkstations -AutoSize -AutoFilter -Show 

	} 

	if ($Export -eq 'HTML') { 
		
		$TableSettings = @{
			#Style          = 'stripe'
			Style          = 'cell-border'
			HideFooter     = $true
			OrderMulti     = $true
			TextWhenNoData = 'No Data to display here'
		}

		$SectionSettings = @{
			BackgroundColor       = 'white'
			CanCollapse           = $true
			HeaderBackGroundColor = 'white'
			HeaderTextAlignment   = 'center'
			HeaderTextColor       = 'darkgrey'
		}

		$TableSectionSettings = @{
			BackgroundColor       = 'white'
			HeaderBackGroundColor = 'darkgrey'
			HeaderTextAlignment   = 'center'
			HeaderTextColor       = 'white'
		}
		[string]$HTMLReportname = $ReportPath + "\XD_Audit-$SiteName-" + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html'

		New-HTML -TitleText "$SiteName Config Audit" -FilePath $HTMLReportname -ShowHTML {
			New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
			New-HTMLSection @SectionSettings -Content {
				New-HTMLSection -HeaderText 'Machine Catalogs' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $catalogs }
			}
			New-HTMLSection @SectionSettings -Content {
				New-HTMLSection -HeaderText 'Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $deliverygroups }
			}
			New-HTMLSection @SectionSettings -Content {
				New-HTMLSection -HeaderText 'Published Applications' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $apps }
			}
			New-HTMLSection @SectionSettings -Content {
				New-HTMLSection -HeaderText 'VDI Servers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $VDAServers }
			}
			New-HTMLSection @SectionSettings -Content {
				New-HTMLSection -HeaderText 'VDI Workstations' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $workstations }
			}
		}
		

	}
	if ($Export -eq 'Host') { 
		Write-Color 'Machine Catalogs' -Color Cyan -LinesAfter 2 -StartTab 2
		$catalogs | Format-Table -AutoSize
		Write-Color 'Delivery Groups' -Color Cyan -LinesAfter 2 -StartTab 2
		$deliverygroups | Format-Table -AutoSize
		Write-Color 'Published Applications' -Color Cyan -LinesAfter 2 -StartTab 2
		$apps | Format-Table -AutoSize
		Write-Color 'VDI Devices' -Color Cyan -LinesAfter 2 -StartTab 2
		$machines | Format-Table -AutoSize


	}

	
} #end Function
