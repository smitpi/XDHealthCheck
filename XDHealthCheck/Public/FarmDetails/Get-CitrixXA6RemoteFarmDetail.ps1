
<#PSScriptInfo

.VERSION 1.0.5

.GUID d1fc83f1-28c0-4360-bfc8-1fc4990f2fbe

.AUTHOR Pierre Smit

.COMPANYNAME

.COPYRIGHT

.TAGS Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [05/05/2019_09:02]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:25]
Updated [09/06/2019_09:18]

.PRIVATEDATA

#>











<#

.DESCRIPTION
Xendesktop Farm Details

#>

Param()



Function Get-CitrixXA6RemoteFarmDetail {
    PARAM(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$AdminServer,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$RemoteCredentials)

Invoke-Command -ComputerName $AdminServer -Credential $RemoteCredentials -ScriptBlock {
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] XA6 Farm Details"

    add-PSSnapin citrix*
    $farmDetails = Get-XAFarm
    $FarmArray = @()
    $Servers = Get-XAServer
    $sessions = Get-XASession | where { $_.State -eq "Active" -and $_.Protocol -eq "Ica"}

    foreach ($xaitem in $Servers) {
        $xaload = Get-XAServerLoad -ServerName $xaitem.ServerName | Select-Object -Property load
        $workergroup = (Get-XAWorkerGroup -ServerName $xaitem.ServerName | % { $_.WorkerGroupName })
        $activeServerSessions = [array]($sessions | where {$_.ServerName -like $xaitem.ServerName })
        [bool]$ping = Test-Connection $xaitem.ServerName -Count 1 -Quiet

        try {
            $null = New-Object System.Net.Sockets.TCPClient -ArgumentList $xaitem.ServerName, 1494
            $port1494 = "true"
        }
        catch { $port1494 = "false" }

        try {
            $null = New-Object System.Net.Sockets.TCPClient -ArgumentList $xaitem.ServerName, 2598
            $port2598 = "true"
        }
        catch { $port2598 = "false" }
    $CTXServers = New-Object PSObject -Property @{
        "Server Name"            = $xaitem.ServerName
        "Ping"                   = $ping.tostring()
        "Port 1494"              = $port1494.tostring()
        "Port 2598"              = $port2598.tostring()
        "Folder"                 = $xaitem.FolderPath
        "Worker Group"           = $workergroup
        "Zone Name"              = $xaitem.ZoneName
        "ElectionPreference"     = $xaitem.ElectionPreference
        "Active Sessions"        = $activeServerSessions.count
        "ServerLoad"             = $xaload.load
        "LogOnsEnabled"          = $xaitem.LogOnsEnabled
        "LogOnMode"              = $xaitem.LogOnMode
    } | select 'Server Name', Ping, 'Port 1494', 'Port 2598', Folder, 'Worker Group', 'Zone Name', ElectionPreference, 'Active Sessions', ServerLoad, LogOnsEnabled, LogOnMode
     $FarmArray += $CTXServers
}
    $CTXfarm = New-Object PSObject -Property @{
    DateCollected         = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
    CTXFarm               = $farmDetails
    CTXServers            = $FarmArray
    }
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending] XA6 Farm Details"

$CTXfarm
} -ArgumentList @($VerbosePreference)




} #end Function

