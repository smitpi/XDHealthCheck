
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

.PARAMETER SessionCount
Will collect data for the last x amount of sessions.

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
        [int32]$SessionCount,

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

    if (-not($MonitorData)) {$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount $SessionCount}
    else {$Mon = $MonitorData}


	[System.Collections.ArrayList]$ClientObject = @()
	foreach ($session in $mon.sessions) {
    Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Sessions $($mon.Sessions.IndexOf($session)) of $($mon.Sessions.count)"
		[void]$ClientObject.Add([pscustomobject]@{
				Domain         = $session.User.domain
				UserName       = $session.User.UserName
				Upn            = $session.User.Upn
				FullName       = $session.User.FullName
				ClientName     = $session.CurrentConnection.ClientName
				ClientAddress  = $session.CurrentConnection.ClientAddress
				ClientVersion  = $session.CurrentConnection.ClientVersion
				ClientPlatform = $session.CurrentConnection.ClientPlatform
				Protocol       = $session.CurrentConnection.Protocol
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
