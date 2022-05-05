
if (Test-Path HKCU:\Software\XDHealth) {

    $global:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
    $global:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
    $global:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL

}
else {
        New-Item -Path HKCU:\Software\XDHealth
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color1 -Value '#061820'
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color2 -Value '#FFD400'
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name LogoURL -Value 'https://c.na65.content.force.com/servlet/servlet.ImageServer?id=0150h000003yYnkAAE&oid=00DE0000000c48tMAA'

    $global:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
    $global:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
    $global:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL
}


#region Html Settings
$global:TableSettings = @{
	Style           = 'cell-border'
	TextWhenNoData  = 'No Data to display here'
	Buttons         = 'searchBuilder', 'pdfHtml5', 'excelHtml5'
	AutoSize        = $true
	DisableSearch   = $true
	FixedHeader     = $true
	HideFooter      = $true
	ScrollCollapse  = $true
	ScrollX         = $true
	ScrollY         = $true
	SearchHighlight = $true
}
$global:SectionSettings = @{
	BackgroundColor       = 'grey'
	CanCollapse           = $true
	HeaderBackGroundColor = $XDHealth_Color1
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = $XDHealth_Color2
	HeaderTextSize        = '20'
	BorderRadius          = '25px'
}
$global:TableSectionSettings = @{
	BackgroundColor       = 'white'
	CanCollapse           = $true
	HeaderBackGroundColor = $XDHealth_Color2
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = $XDHealth_Color1
	HeaderTextSize        = '20'
}
#endregion


