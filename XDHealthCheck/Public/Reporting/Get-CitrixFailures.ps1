
<#PSScriptInfo

.VERSION 0.1.0

.GUID b4f0c061-0297-4851-a511-dad5ba5a8b96

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
Created [03/05/2022_22:44] Initial Script Creating

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Creates a report from monitoring data about machine and connection failures 

#> 

<#
.SYNOPSIS
Creates a report from monitoring data about machine and connection failures

.DESCRIPTION
Creates a report from monitoring data about machine and connection failures

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER hours
Limit the report to this time fame

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixFailures -AdminServer $CTXDDC

#>
Function Get-CitrixFailures {
    [Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixFailures')]
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

    [System.Collections.ArrayList]$mashineFails = @()
    foreach ($MFail in $mon.MachineFailureLogs) {
        $device = $mon.Machines | Where-Object {$_.id -like $MFail.MachineId}
        [void]$mashineFails.Add([pscustomobject]@{
                Name                     = $device.Name
                IP                       = $device.IPAddress
                OSType                   = $device.OSType
                FailureDate              = [datetime]$MFail.FailureStartDate
                FaultState               = $MFail.FaultState 
                LastDeregisteredCode     = $MachineDeregistration[$MFail.LastDeregisteredCode]
                CurrentRegistrationState = $RegistrationState[$device.CurrentRegistrationState]
                CurrentFaultState        = $device.FaultState
            })
    }

    [System.Collections.ArrayList]$ConnectionFails = @()
    foreach ($CFail in $mon.ConnectionFailureLogs) {
        $user = $mon.Users | Where-Object {$_.id -like $CFail.UserId}
        $device = $mon.Machines | Where-Object {$_.id -like $CFail.MachineId}
        [void]$ConnectionFails.Add([pscustomobject]@{
                UserName       = $user.UserName
                Upn            = $user.Upn
                Name           = $device.Name
                IP             = $device.IPAddress
                FailureDate    = [datetime]$CFail.FailureDate
                FailureDetails = $SessionFailureCode[$CFail.ConnectionFailureEnumValue]
            })
    }


    if ($Export -eq 'Excel') { 
        $mashineFails | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixFailures-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName MachineFailures -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
        $ConnectionFails | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixFailures-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName ConnectionFailures -AutoSize -AutoFilter -Title 'Connection Failures' -TitleBold -TitleSize 28 -Show
    }
    if ($Export -eq 'HTML') { 
        $mashineFails | Out-HtmlView -DisablePaging -Title 'Mashine Failures' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\Citrix-Machine-Failures-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
        $ConnectionFails | Out-HtmlView -DisablePaging -Title 'Connection Failures' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\Citrix-Connection-Failures-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
        
    }
    if ($Export -eq 'Host') { 
        [pscustomobject]@{
            mashineFails    = $mashineFails
            ConnectionFails = $ConnectionFails
        }
    }


} #end Function
