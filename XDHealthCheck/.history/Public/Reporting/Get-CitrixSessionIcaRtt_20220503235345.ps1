
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

.EXAMPLE
Get-CitrixSessionIcaRtt

#>
Function Get-CitrixSessionIcaRtt {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/XDHealthCheck/Get-CitrixSessionIcaRtt")]
	   [OutputType([System.Object[]])]
				 PARAM(
                 [Parameter(Mandatory = $true)]
                    [ValidateNotNull()]
                    [ValidateNotNullOrEmpty()]
                    [string]$AdminServer,
                    [Parameter(Mandatory = $true)]
                    [ValidateNotNull()]
                    [ValidateNotNullOrEmpty()]
                    [int32]$hours,
					[ValidateSet('Excel', 'HTML')]
					[string]$Export = 'Host',
                	[ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                	[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
                )
$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -hours $hours

[System.Collections.ArrayList]$IcaRttObject = @()
foreach ($sessid in $mon.SessionMetrics.sessionid | Sort-Object -Unique) {
    $session = $mon.Sessions | Where-Object {$_.SessionKey -like $sessid}
    $user = $mon.Users | Where-Object {$_.id -like $session.userid}
    $Measure = $mon.SessionMetrics | Where-Object {$_.SessionId -like $sessid} | Measure-Object -Property IcaRttMS -Average   
            [void]$IcaRttObject.Add([pscustomobject]@{
                    StartDate = [datetime]$session.StartDate
                    EndDate   = [datetime]$session.EndDate
                    'AVG IcaRtt'  = [math]::Round($Measure.Average)
                    UserName      = $user.UserName
                    UPN           = $user.Upn
                })


}

	if ($Export -eq 'Excel') { $IcaRttObject | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixSessionIcaRtt-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Show }
	if ($Export -eq 'HTML') { $IcaRttObject | Out-GridHtml -DisablePaging -Title "CitrixSessionIcaRtt" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixSessionIcaRtt-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $IcaRttObject }


} #end Function
