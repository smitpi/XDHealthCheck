
<#PSScriptInfo

.VERSION 1.0.2

.GUID 28827783-e97e-432f-bf46-c01e8c3c8299

.AUTHOR Pierre Smit

.COMPANYNAME Absa Corp:EUV Team

.COPYRIGHT

.TAGS EUV Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Date Created - 05/05/2019_08:59
Date Updated - 13/05/2019_04:40
Date Updated - 22/05/2019_20:13

.PRIVATEDATA

#> 





<#

.DESCRIPTION 
Xendesktop Farm Details

#>

Param()



Function Get-CitrixSingleServerPerformance {
    PARAM(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Server,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$RemoteCredentials)

    Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Performance Details for $($server.ToString())"
    $CtrList = @(
        "\Processor(_Total)\% Processor Time",
        "\memory\% committed bytes in use",
        "\LogicalDisk(C:)\Free Megabytes",
        "\LogicalDisk(D:)\Free Megabytes"
    )
    Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Perfmon Details for $($server.ToString())"
    $perf = Get-Counter $CtrList -ComputerName $server  -ErrorAction SilentlyContinue  | Select-Object -ExpandProperty CounterSamples

    Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Services Details for $($server.ToString())"
    $services = Get-Service -ComputerName $server citrix* | Where-Object { ($_.starttype -eq "Automatic" -and $_.status -eq "Stopped") }
    if ([bool]$Services.DisplayName -eq $true) { $ServicesJoin = [String]::Join(';', $Services.DisplayName) }
    else {$ServicesJoin = ''}

    Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Uptime Details for $($server.ToString())"
    $OS = Get-WmiObject Win32_OperatingSystem -ComputerName $server
    $Uptime = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime)
    $updays = [math]::Round($uptime.Days, 0)

$CTXObject = New-Object PSCustomObject -Property @{
    DateCollected      = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
    ServerName         = $Server
    'CPU_%'            = [Decimal]::Round(($perf[0].CookedValue), 2).tostring()
    'Memory_%'         = [Decimal]::Round(($perf[1].CookedValue), 2).tostring()
    'CDrive_Free'      = [Decimal]::Round(($perf[2].CookedValue) / 1024, 2).tostring()
    'DDrive_Free'      = [Decimal]::Round(($perf[3].CookedValue) / 1024, 2).tostring()
    Uptime             = $updays.tostring()
    'Stopped_Services' = $ServicesJoin
} | select ServerName, 'CPU_%', 'Memory_%', 'CDrive_Free', 'DDrive_Free', Uptime, 'Stopped_Services'
$CTXObject
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending] Performance Details for $($server.ToString())"

} #end Function


function Get-CitrixServerPerformance {
    PARAM(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [array]$Serverlist,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$RemoteCredentials)

$CitrixServerPerformance = @()
foreach ($Server in $Serverlist) {
    $SingleServer = Get-CitrixSingleServerPerformance -Server $Server -RemoteCredentials $RemoteCredentials
        $CusObject = New-Object PSObject -Property @{
            DateCollected      = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
            Servername         = $SingleServer.ServerName
            'CPU_%'            = $SingleServer.'CPU_%'
            'Memory_%'         = $SingleServer.'Memory_%'
            'CDrive_Free'      = $SingleServer.'CDrive_Free'
            'DDrive_Free'      = $SingleServer.'DDrive_Free'
            Uptime             = $SingleServer.Uptime
            'Stopped_Services' = $SingleServer.StoppedServices
        } | select ServerName, 'CPU_%', 'Memory_%', 'CDrive_Free', 'DDrive_Free', Uptime, 'Stopped_Services'
    $CitrixServerPerformance += $CusObject
}

$CitrixServerPerformance
}
