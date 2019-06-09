New-UDPage -Name 'XDDash' -Icon gear -Endpoint {
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

}