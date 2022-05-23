
<#PSScriptInfo

.VERSION 0.1.0

.GUID 1378a9f5-9839-4dfb-8571-ec79f78dae2e

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
Created [03/05/2022_23:51] Initial Script Creating

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Creates a report of users sessions with a AVG IcaRttMS 

#> 


<#
.SYNOPSIS
Creates a report of users sessions with a AVG IcaRttMS

.DESCRIPTION
Creates a report of users sessions with a AVG IcaRttMS

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
 Get-CitrixSessionIcaRtt -AdminServer $CTXDDC

#>
Function Get-CitrixSessionIcaRtt {
        [Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixSessionIcaRtt')]
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

        if (-not($MonitorData)) {
                try {
                        $mon = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount $SessionCount
                } catch {$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount $SessionCount -AllowUnencryptedAuthentication}
        } else {$Mon = $MonitorData}

        [System.Collections.ArrayList]$IcaRttObject = @()
        $UniqueSession = $mon.Sessions.SessionMetrics | Sort-Object -Property SessionId -Unique
        foreach ($sessid in $UniqueSession) {
                Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Sessions $($UniqueSession.IndexOf($sessid)) of $($UniqueSession.count)"
                try {
                        $session = $mon.Sessions | Where-Object {$_.SessionKey -like $sessid.SessionId}
                        $user = ($mon.Sessions.User | Where-Object {$_.id -like $session.userid})[0]
                        $Measure = $mon.Sessions.SessionMetrics | Where-Object {$_.SessionId -like $sessid.SessionId} | Measure-Object -Property IcaRttMS -Average   
                        [void]$IcaRttObject.Add([pscustomobject]@{
                                        StartDate    = [datetime]$session.StartDate
                                        EndDate      = [datetime]$session.EndDate
                                        ObjectCount  = $Measure.Count
                                        'AVG IcaRtt' = [math]::Round($Measure.Average)
                                        UserName     = $user.UserName
                                        UPN          = $user.Upn
                                })

                } catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
        }

        if ($Export -eq 'Excel') { 
                $ExcelOptions = @{
                        Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_Session_IcaRtt-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
                        AutoSize         = $True
                        AutoFilter       = $True
                        TitleBold        = $True
                        TitleSize        = '28'
                        TitleFillPattern = 'LightTrellis'
                        TableStyle       = 'Light20'
                        FreezeTopRow     = $True
                        FreezePane       = '3'
                }
                $IcaRttObject | Export-Excel -Title CitrixSessionIcaRtt -WorksheetName CitrixSessionIcaRtt @ExcelOptions
        }
        if ($Export -eq 'HTML') { 
                $ReportTitle = 'Citrix Session IcaRtt'
                $HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
                New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
                        New-HTMLHeader {
                                New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
                                New-HTMLLogo -RightLogoString $XDHealth_LogoURL
                        }
                        if ($IcaRttObject) { New-HTMLTab -Name 'ICA RTT' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($IcaRttObject) @TableSettings}}}
                }
        }
        if ($Export -eq 'Host') { $IcaRttObject }


} #end Function
