
<#PSScriptInfo

.VERSION 0.1.1

.GUID 30604ec8-78ac-49d4-956e-2e4d9368b85f

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ctx ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [14/11/2021_03:31] Initital Script Creating
Updated [14/11/2021_07:05] Added more functions

.PRIVATEDATA

#> 




<# 

.DESCRIPTION 
Set the color for html reports

#> 


<#
.SYNOPSIS
Set the color and logo for HTML Reports

.DESCRIPTION
Set the color and logo for HTML Reports. It updates the registry keys in HKCU:\Software\XDHealth with the new details and display a test report.

.PARAMETER Color1
New Background Color # code

.PARAMETER Color2
New foreground Color # code

.PARAMETER LogoURL
URL to the new Logo

.EXAMPLE
Set-XDHealthReportColors -Color1 '#d22c26' -Color2 '#2bb74e' -LogoURL 'https://gist.githubusercontent.com/default-monochrome.png'

#>
Function Set-XDHealthReportColors {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Set-XDHealthReportColors')]
	[Cmdletbinding()]
	PARAM(
		[string]$Color1 = '#2b1200',
		[string]$Color2 = '#f37000',
		[string]$LogoURL = 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome.png'
	)
    if (Test-Path HKCU:\Software\XDHealth) {
    	Set-ItemProperty -Path HKCU:\Software\XDHealth -Name Color1 -Value $($Color1)
	    Set-ItemProperty -Path HKCU:\Software\XDHealth -Name Color2 -Value $($Color2)
	    Set-ItemProperty -Path HKCU:\Software\XDHealth -Name LogoURL -Value $($LogoURL)
    } else {
        New-Item -Path HKCU:\Software\XDHealth
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color1 -Value $($Color1)
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color2 -Value $($Color2)
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name LogoURL -Value $($LogoURL)
    }
    $global:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
    $global:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
    $global:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL

	#region Html Settings
	$global:TableSettings = @{
		Style           = 'cell-border'
		TextWhenNoData  = 'No Data to display here'
		Buttons         = 'searchBuilder', 'pdfHtml5', 'excelHtml5'
		FixedHeader     = $true
		HideFooter      = $true
		SearchHighlight = $true
		PagingStyle     = 'full'
		PagingLength    = 10
	}
	$global:SectionSettings = @{
		BackgroundColor       = 'grey'
		CanCollapse           = $true
		HeaderBackGroundColor = $XDHealth_Color1
		HeaderTextAlignment   = 'center'
		HeaderTextColor       = $XDHealth_Color2
		HeaderTextSize        = '15'
		BorderRadius          = '20px'
	}
	$global:TableSectionSettings = @{
		BackgroundColor       = 'white'
		CanCollapse           = $true
		HeaderBackGroundColor = $XDHealth_Color2
		HeaderTextAlignment   = 'center'
		HeaderTextColor       = $XDHealth_Color1
		HeaderTextSize        = '15'
	}
	#endregion

	[string]$HTMLReportname = $env:TEMP + '\Test-color' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html'

	$HeadingText = 'Test | Report | ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)

	New-HTML -TitleText 'Report' -FilePath $HTMLReportname -ShowHTML {
		New-HTMLLogo -RightLogoString $XDHealth_LogoURL
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
		New-HTMLSection @SectionSettings -HeaderText 'Test' -Content {
			New-HTMLSection -HeaderText 'Test2' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable (Get-Process | Select-Object -First 5) }
			New-HTMLSection -HeaderText 'Test3' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable (Get-Service | Select-Object -First 5) }
		}
	}

} #end Function
