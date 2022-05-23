
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

.PARAMETER SessionCount
Will collect data for the last x amount of sessions.

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
$monitor = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount 50
Get-CitrixConnectionFailures -MonitorData $monitor

#>
Function Get-CitrixConnectionFailures {
    [Cmdletbinding(DefaultParameterSetName = 'Fetch odata', HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixConnectionFailures')]
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

    $ConnectionFailure = $mon.Connections.Where({$_.ConnectionFailureLog -notlike $null})
    if ($ConnectionFailure.count -eq 0) {Write-Warning 'No connection Failures during this time frame'}
    else {
        [System.Collections.ArrayList]$ConnectionFails = @()
        foreach ($CFail in $ConnectionFailure.ConnectionFailureLog) {
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Connection Failures $($ConnectionFailure.ConnectionFailureLog.IndexOf($CFail)) of $($ConnectionFailure.ConnectionFailureLog.count)"
            try {
                $user = Invoke-RestMethod -Method Get -Uri "$($CFail.User.__deferred.uri)?`$format=json" -UseDefaultCredentials
                $device = Invoke-RestMethod -Method Get -Uri "$($CFail.Machine.__deferred.uri)?`$format=json" -UseDefaultCredentials
            } catch {
                $user = Invoke-RestMethod -Method Get -Uri "$($CFail.User.__deferred.uri)?`$format=json" -UseDefaultCredentials -AllowUnencryptedAuthentication
                $device = Invoke-RestMethod -Method Get -Uri "$($CFail.Machine.__deferred.uri)?`$format=json" -UseDefaultCredentials -AllowUnencryptedAuthentication
            }
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
            Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_Connection_Failures-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
            AutoSize         = $True
            AutoFilter       = $True
            TitleBold        = $True
            TitleSize        = '28'
            TitleFillPattern = 'LightTrellis'
            TableStyle       = 'Light20'
            FreezeTopRow     = $True
            FreezePane       = '3'
        }
        if ($ConnectionFails) {$ConnectionFails | Export-Excel -Title ConnectionFailures -WorksheetName ConnectionFailures @ExcelOptions}
    }
    if ($Export -eq 'HTML') { 
        $ReportTitle = 'Citrix Connection Failures'
        $HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
        New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
            New-HTMLHeader {
                New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
                New-HTMLLogo -RightLogoString $XDHealth_LogoURL
            }
            if ($ConnectionFails) { New-HTMLTab -Name 'Connection Failures' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($ConnectionFails) @TableSettings}}}
        }
    }
    if ($Export -eq 'Host') { 
        [pscustomobject]@{
            ConnectionFails = $ConnectionFails
        }
    }
} #end Function
