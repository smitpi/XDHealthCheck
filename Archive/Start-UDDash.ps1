#region begin Scheduler
# https://docs.universaldashboard.io/endpoints/scheduled-endpoints
# An UDEndpoint is a scriptblock that runs at a interval defined by UDEndpointSchedule
# Data can be stored in $Cache:VariableName and is available throughout the dashboard.
$Schedule = New-UDEndpointSchedule -Every 1 -Minute
$CTXFunctions = New-UDEndpointInitialization -Module @("CTXHealthCheck", "PoshRSJob") -Variable @("ReportsFolder", "ParametersFolder", "CTXAdmin", "PSParameters") -Function @("Get-FullUserDetail", "Initialize-CitrixAudit", "Initialize-CitrixHealthCheck")
$Theme = Get-UDTheme -Name Default 


$AllUsersEndpoint = New-UDEndpoint -Schedule $Schedule -Endpoint {

########################################
## Build other variables
#########################################
$Cache:CTXControllers = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerController | select dnsname } | foreach { $_.dnsname }
$Cache:CTXLicenseServer = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerSite -AdminAddress $AdminServer | select LicenseServerName } | foreach { $_.LicenseServerName }
$Cache:CTXStoreFrontFarm = Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-STFServerGroup | select -ExpandProperty ClusterMembers | select hostname | foreach { ([System.Net.Dns]::GetHostByName(($_.hostname))).Hostname } }
$Cache:CTXCore = $CTXControllers + $CTXStoreFrontFarm + $CTXLicenseServer | sort -Unique

########################################
## Connect and get info
########################################
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
$Cache:CitrixLicenseInformation = Get-CitrixLicenseInformation -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$Cache:CitrixRemoteFarmDetails = Get-CitrixFarmDetails -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$Cache:CitrixServerEventLogs = Get-CitrixServerEventLogs -Serverlist $CTXCore -Days 1 -RemoteCredentials $CTXAdmin -Verbose
$Cache:RDSLicenseInformation = Get-RDSLicenseInformation -LicenseServer $RDSLicensServer  -RemoteCredentials $CTXAdmin -Verbose
$Cache:CitrixConfigurationChanges = Get-CitrixConfigurationChanges -AdminServer $CTXDDC -Indays 7 -RemoteCredentials $CTXAdmin -Verbose
$Cache:StoreFrontDetails = Get-StoreFrontDetails -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$Cache:ServerPerformance = Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin -Verbose

}



$report = New-UDPage -Name 'XDDash Inter' -DefaultHomePage -Icon gear -Content {
$HeddingText = "XenDesktop Report for Farm: " + $Cache:CitrixRemoteFarmDetails.SiteDetails.Summary.Name + " on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)  + " " + (Get-Date -Format HH:mm)
New-UDCard -Text $HeddingText -TextSize Medium -TextAlignment center
New-UDLayout -Columns 1 -Content{
       New-UDGrid -Title 'Citrix Sessions' -Endpoint {$Cache:CitrixRemoteFarmDetails.SessionCounts| Out-UDGridData}
       New-UDGrid -Title 'Citrix Controllers' -Endpoint { $Cache:CitrixRemoteFarmDetails.Controllers.Summary | Out-UDGridData}
       New-UDGrid -Title 'Citrix DB Connection' -Endpoint {  $Cache:CitrixRemoteFarmDetails.DBConnection | Out-UDGridData}
       New-UDGrid -Title 'Citrix Licenses' -Endpoint {$Cache:CitrixLicenseInformation | Out-UDGridData}
       New-UDGrid -Title 'RDS Licenses' -Endpoint {  $Cache:RDSLicenseInformation.$RDSLicensType| Out-UDGridData}
       New-UDGrid -Title 'Citrix Error Counts' -Endpoint {   ($Cache:CitrixServerEventLogs.SingleServer | select ServerName, Errors, Warning)| Out-UDGridData}
       New-UDGrid -Title 'Citrix Events Top Events' -Endpoint {  ($Cache:CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count) | Out-UDGridData}
       New-UDGrid -Title 'StoreFront Site' -Endpoint {   $Cache:StoreFrontDetails.SiteDetails| Out-UDGridData}
       New-UDGrid -Title 'StoreFront Server' -Endpoint {  $Cache:StoreFrontDetails.ServerDetails | Out-UDGridData}
       New-UDGrid -Title 'Citrix Config Changes in the last 7 days' -Endpoint {  ($Cache:CitrixConfigurationChanges.Summary | where { $_.name -ne "" } | Sort-Object count -Descending | select -First 5 -Property count, name) | Out-UDGridData}
       New-UDGrid -Title 'Citrix Server Performace' -Endpoint {  ($Cache:ServerPerformance)| Out-UDGridData}
       New-UDGrid -Title 'Citrix Delivery Groups' -Endpoint {  $Cache:CitrixRemoteFarmDetails.DeliveryGroups| Out-UDGridData}
       New-UDGrid -Title 'Citrix UnRegistered Desktops' -Endpoint {  $Cache:CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops| Out-UDGridData}
       New-UDGrid -Title 'Citrix UnRegistered Servers' -Endpoint {  $Cache:CitrixRemoteFarmDetails.Machines.UnRegisteredServers| Out-UDGridData}
       New-UDGrid -Title 'Citrix Tainted Objects' -Endpoint {  $Cache:CitrixRemoteFarmDetails.ADObjects.TaintedObjects| Out-UDGridData}
}

} -Endpoint @($Cache:AllUsersEndpoint)

$Pages = Get-ChildItem (Join-Path $PSScriptRoot "Pages") | ForEach-Object {
. $_.FullName
}

Get-UDDashboard | Stop-UDDashboard

$Dashboard = New-UDDashboard -Title 'XD Dash'  -Pages @($report) -EndpointInitialization $CTXFunctions -Theme $Theme

Start-UDDashboard -Dashboard $Dashboard -Port 10010 -Endpoint @($AllUsersEndpoint)

Start-Process http://localhost:10010

