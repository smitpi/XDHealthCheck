<#PSScriptInfo

.VERSION 0.1.0

.GUID ea455247-d7c4-47b4-b918-ad6b9439cfc3

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
Created [17/05/2022_14:22] Initial Script Creating

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
ResourceUtilizationSummary for machines 

#> 



<#
.SYNOPSIS
Resource Utilization Summary for machines

.DESCRIPTION
Resource Utilization Summary for machines

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER hours
Limit the report to this time frame

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixResourceUtilizationSummary -AdminServer $CTXDDC -hours 24 -Export Excel -ReportPath C:\temp

#>
Function Get-CitrixResourceUtilizationSummary {
    [Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixResourceUtilizationSummary')]
    [OutputType([System.Object[]])]
    PARAM(
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
    
    $now = Get-Date -Format yyyy-MM-ddTHH:mm:ss.ffZ
    $past = ((Get-Date).AddHours(-$hours)).ToString('yyyy-MM-ddTHH:mm:ss.ffZ')
    $headers = @{ 'Accept' = 'application/json; odata=verbose'}

    $urisettings = @{
        UseDefaultCredentials = $true
        headers               = $headers
        Method                = 'Get'
    }

    $ResourceUtilizationSummary = (Invoke-RestMethod -Uri http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/ResourceUtilizationSummary?`$filter = CreatedDate ge datetime'$($past)' and CreatedDate le datetime'$($now)' @urisettings).d
    [System.Collections.ArrayList]$ResourceUtilization = @()
    $grouped = $ResourceUtilizationSummary | Group-Object MachineId
    foreach ($resource in $grouped) {
        Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] ResourceUtilization $($grouped.IndexOf($resource)) of $($grouped.count)"
        $machine = (Invoke-RestMethod -Uri $resource.Group[0].Machine.__deferred.uri @urisettings).d
        [void]$ResourceUtilization.add([PSCustomObject]@{
                Name              = $machine.DnsName
                AvgPercentCpu     = [Decimal]::Round((($resource.group | Measure-Object -Property AvgPercentCpu -Average).Average))
                AvgUsedMemory     = [Decimal]::Round((($resource.group | Measure-Object -Property AvgUsedMemory -Average).Average) / 1gb, 2)
                AvgTotalMemory    = [Decimal]::Round((($resource.group | Measure-Object -Property AvgTotalMemory -Average).Average) / 1gb, 2)
                TotalSessionCount = [Decimal]::Round((($resource.group | Measure-Object -Property TotalSessionCount -Average).Average))
            })
    }


    if ($Export -eq 'Excel') { 
        $ExcelOptions = @{
            Path             = $(Join-Path -Path $ReportPath -ChildPath "\CitrixResourceUtilizationSummary-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
            AutoSize         = $True
            AutoFilter       = $True
            TitleBold        = $True
            TitleSize        = '28'
            TitleFillPattern = 'LightTrellis'
            TableStyle       = 'Light20'
            FreezeTopRow     = $True
            FreezePane       = '3'
        }
        if ($ResourceUtilization) { $ResourceUtilization | Export-Excel -Title MachineFailures -WorksheetName MachineFailures @ExcelOptions }
    }
                              
    if ($Export -eq 'HTML') { $ResourceUtilization | Out-HtmlView -DisablePaging -Title 'CitrixResourceUtilizationSummary' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixResourceUtilizationSummary-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
    if ($Export -eq 'Host') { $ResourceUtilization }


} #end Function
