
<#PSScriptInfo

.VERSION 0.1.0

.GUID 8b29da17-5e3b-41dd-ade5-fb88f385fe88

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
Created [03/05/2022_23:16] Initial Script Creating

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Reports on the versions of workspace app your users are using to connect 

#> 


<#
.SYNOPSIS
Reports on the versions of workspace app your users are using to connect

.DESCRIPTION
Reports on the versions of workspace app your users are using to connect

.EXAMPLE
Get-CitrixWorkspaceAppVersions

#>
<#
.SYNOPSIS
Reports on the versions of workspace app your users are using to connect

.DESCRIPTION
Reports on the versions of workspace app your users are using to connect

.PARAMETER MonitorData
Use Get-CitrixMonitoringData to create OData, and use that variable in this parameter.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER hours
Limit the report to this time fame

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -hours $hours
Get-CitrixWorkspaceAppVersions -MonitorData $Mon

#>
Function Get-CitrixWorkspaceAppVersions {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixWorkspaceAppVersions')]
	[OutputType([System.Object[]])]
    PARAM(
        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [PSTypeName('CTXMonitorData')]$MonitorData,

        [Parameter(Mandatory = $true, ParameterSetName = 'Fetch odata')]
        [string]$AdminServer,

        [Parameter(Mandatory = $true, ParameterSetName = 'Fetch odata')]
        [int32]$hours,

        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Fetch odata')]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',

        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Fetch odata')]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )					

    if (-not($MonitorData)) {$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -hours $hours}
    else {$Mon = $MonitorData}

	$index = 1
	[string]$AllCount = $mon.Connections.Count
	[System.Collections.ArrayList]$ClientObject = @()

	foreach ($connect in $mon.Connections) {
		$Userid = ($mon.Sessions | Where-Object { $_.SessionKey -like $connect.SessionKey}).UserId
		$userdetails = $mon.Users | Where-Object { $_.id -like $Userid }
		Write-Output "Collecting data $index of $AllCount"
		$index++
		[void]$ClientObject.Add([pscustomobject]@{
				Domain         = $userdetails.Domain
				UserName       = $userdetails.UserName
				Upn            = $userdetails.Upn
				FullName       = $userdetails.FullName
				ClientName     = $connect.ClientName
				ClientAddress  = $connect.ClientAddress
				ClientVersion  = $connect.ClientVersion
				ClientPlatform = $connect.ClientPlatform
				Protocol       = $connect.Protocol
			})
	}

	if ($Export -eq 'Excel') {
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\CitrixWorkspaceAppVersions-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$ClientObject | Export-Excel -Title CitrixWorkspaceAppVersions -WorksheetName CitrixWorkspaceAppVersions @ExcelOptions}
	if ($Export -eq 'HTML') { $ClientObject | Out-HtmlView -DisablePaging -Title 'CitrixWorkspaceAppVersions' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixWorkspaceAppVersions-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $ClientObject }


} #end Function
