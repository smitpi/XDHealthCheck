
<#PSScriptInfo

.VERSION 1.0.0

.GUID 7e12eb19-2c68-42cc-94d4-ba8fa2fd7161

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
Created [09/06/2019_13:08] Initital Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 ctxhealthcheck 

#> 

Param()



$CTXFunctions = New-UDEndpointInitialization -Module @("CTXHealthCheck", "PoshRSJob") -Variable @("ReportsFolder", "ParametersFolder", "CTXAdmin", "PSParameters","$env:PSParameters") -Function @("Get-FullUserDetail", "Initialize-CitrixAudit", "Initialize-CitrixHealthCheck")
$Theme = Get-UDTheme -Name Default 


$XDUD = New-UDPage -Name "XD Dash" -Icon server -Content {

########################################
## Build other variables
#########################################
$CTXControllers = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerController | select dnsname } | foreach { $_.dnsname }
$CTXLicenseServer = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerSite -AdminAddress $AdminServer | select LicenseServerName } | foreach { $_.LicenseServerName }
$CTXStoreFrontFarm = Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-STFServerGroup | select -ExpandProperty ClusterMembers | select hostname | foreach { ([System.Net.Dns]::GetHostByName(($_.hostname))).Hostname } }
$CTXCore = $CTXControllers + $CTXStoreFrontFarm + $CTXLicenseServer | sort -Unique

########################################
## Connect and get info
########################################
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
$CitrixLicenseInformation = Get-CitrixLicenseInformation -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$CitrixRemoteFarmDetails = Get-CitrixFarmDetails -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$CitrixServerEventLogs = Get-CitrixServerEventLogs -Serverlist $CTXCore -Days 1 -RemoteCredentials $CTXAdmin -Verbose
$RDSLicenseInformation = Get-RDSLicenseInformation -LicenseServer $RDSLicensServer  -RemoteCredentials $CTXAdmin -Verbose
$CitrixConfigurationChanges = Get-CitrixConfigurationChanges -AdminServer $CTXDDC -Indays 7 -RemoteCredentials $CTXAdmin -Verbose
$StoreFrontDetails = Get-StoreFrontDetails -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
#$ServerPerformance = Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin -Verbose

########################################
## Adding more reports / scripts
########################################

$HeddingText = "XenDesktop Report for Farm: " + $CitrixRemoteFarmDetails.SiteDetails.Summary.Name + " on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)  + " " + (Get-Date -Format HH:mm)

New-UDCard -Text $HeddingText -TextSize Medium -TextAlignment center
New-UDLayout -Columns 1 -Content{
       New-UDGrid -Title 'Citrix Sessions' -Endpoint {$CitrixRemoteFarmDetails.SessionCounts| Out-UDGridData}
       New-UDGrid -Title 'Citrix Controllers' -Endpoint { $CitrixRemoteFarmDetails.Controllers.Summary | Out-UDGridData}
       New-UDGrid -Title 'Citrix DB Connection' -Endpoint {  $CitrixRemoteFarmDetails.DBConnection | Out-UDGridData}
       New-UDGrid -Title 'Citrix Licenses' -Endpoint {$CitrixLicenseInformation | Out-UDGridData}
       New-UDGrid -Title 'RDS Licenses' -Endpoint {  $RDSLicenseInformation.$RDSLicensType| Out-UDGridData}
       New-UDGrid -Title 'Citrix Error Counts' -Endpoint {   ($CitrixServerEventLogs.SingleServer | select ServerName, Errors, Warning)| Out-UDGridData}
       New-UDGrid -Title 'Citrix Events Top Events' -Endpoint {  ($CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count) | Out-UDGridData}
       New-UDGrid -Title 'StoreFront Site' -Endpoint {   $StoreFrontDetails.SiteDetails| Out-UDGridData}
       New-UDGrid -Title 'StoreFront Server' -Endpoint {  $StoreFrontDetails.ServerDetails | Out-UDGridData}
       New-UDGrid -Title 'Citrix Config Changes in the last 7 days' -Endpoint {  ($CitrixConfigurationChanges.Summary | where { $_.name -ne "" } | Sort-Object count -Descending | select -First 5 -Property count, name) | Out-UDGridData}
       New-UDGrid -Title 'Citrix Server Performace' -Endpoint {  ($ServerPerformance)| Out-UDGridData}
       New-UDGrid -Title 'Citrix Delivery Groups' -Endpoint {  $CitrixRemoteFarmDetails.DeliveryGroups| Out-UDGridData}
       New-UDGrid -Title 'Citrix UnRegistered Desktops' -Endpoint {  $CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops| Out-UDGridData}
       New-UDGrid -Title 'Citrix UnRegistered Servers' -Endpoint {  $CitrixRemoteFarmDetails.Machines.UnRegisteredServers| Out-UDGridData}
       New-UDGrid -Title 'Citrix Tainted Objects' -Endpoint {  $CitrixRemoteFarmDetails.ADObjects.TaintedObjects| Out-UDGridData}
}
}

Get-UDDashboard | Stop-UDDashboard

$Dashboard = New-UDDashboard -Title "XenDektop Dashboard" -Pages @($XDUD) -EndpointInitialization $CTXFunctions -Theme $Theme

Start-UDDashboard -Dashboard $Dashboard -Port 107
Start-Process http://localhost:107

#endregion

