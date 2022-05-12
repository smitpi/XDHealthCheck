
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
Get-CitrixFailures -AdminServer $CTXDDC

#>
Function Get-CitrixFailures {
    [Cmdletbinding(DefaultParameterSetName = 'Fetch odata',HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixFailures')]
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


    if ($mon.MachineFailureLogs.count -eq 0) {Write-Warning "No Machine Failures during this time frame"}
    else {
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
    }

    if ($mon.ConnectionFailureLogs.count -eq 0) {Write-Warning "No connection Failures during this time frame"}
    else {
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
    }


    if ($Export -eq 'Excel') { 
        $ExcelOptions = @{
            Path             = $(Join-Path -Path $ReportPath -ChildPath "\CitrixFailures-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
            AutoSize         = $True
            AutoFilter       = $True
            TitleBold        = $True
            TitleSize        = '28'
            TitleFillPattern = 'LightTrellis'
            TableStyle       = 'Light20'
            FreezeTopRow     = $True
            FreezePane       = '3'
        }
        if ($mashineFails) {$mashineFails   | Export-Excel -Title MachineFailures -WorksheetName MachineFailures @ExcelOptions}
        if ($ConnectionFails) {$ConnectionFails | Export-Excel -Title ConnectionFailures -WorksheetName ConnectionFailures @ExcelOptions}
    }
    if ($Export -eq 'HTML') { 
      New-HTML -TitleText "CitrixFailures-$(Get-Date -Format yyyy.MM.dd-HH.mm)" -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixFailures-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
           if ($mashineFails) { New-HTMLTab -Name 'Mashine Failures' -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor $color1 -IconSize 16 -IconColor $color2 -HtmlData {New-HTMLPanel -Content { New-HTMLTable -DataTable $($mashineFails) @TableSettings}}}
           if ($ConnectionFails) { New-HTMLTab -Name 'Connection Failures' -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor $color1 -IconSize 16 -IconColor $color2 -HtmlData {New-HTMLPanel -Content { New-HTMLTable -DataTable $($ConnectionFails) @TableSettings}}}      
    }
    }
    if ($Export -eq 'Host') { 
        [pscustomobject]@{
            mashineFails    = $mashineFails
            ConnectionFails = $ConnectionFails
        }
    }


} #end Function
