
if (Test-Path HKCU:\Software\XDHealth) {

	$global:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
	$global:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
	$global:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL

} else {
	New-Item -Path HKCU:\Software\XDHealth
	New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color1 -Value '#2b1200'
	New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color2 -Value '#f37000'
	New-ItemProperty -Path HKCU:\Software\XDHealth -Name LogoURL -Value 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome.png'

	$global:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
	$global:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
	$global:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL
}


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
$global:TabSettings = @{
    TextTransform             = 'uppercase'
    #IconSolid                 = 'file-export'
    IconBrands                = 'mix'
    TextSize                  = '16' 
    TextColor                 =  '#00203F'
    IconSize                  = '16'
    IconColor                 =  '#00203F'
}
#endregion


