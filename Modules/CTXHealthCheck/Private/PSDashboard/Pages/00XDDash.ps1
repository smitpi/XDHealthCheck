New-UDPage -Name "XD Health Check" -Icon home -DefaultHomePage -Content {
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {         		
		$job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($CTXParameters)
		do {
			Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white' } -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal		   
		}   until( $job.State -notlike 'Running')
$CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)
$TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
$2DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[1]) | select *
$3DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *

Sync-UDElement -Id 'Healcheck1'
Sync-UDElement -Id 'Healcheck2'
Sync-UDElement -Id 'Healcheck3'
Sync-UDElement -Id 'Checkxml1'

} # onclick


New-UDCollapsible -Items {
#region Section0
New-UDCollapsibleItem -Title 'Live Results' -Id 'Checkxml1' -Endpoint {
param($CheckXML)
$CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)

$LastRunXML =$CheckXML.DateCollected.split("_")
$Dayxml = $LastRunXML[0].Split("-")[0]
$Monthxml = $LastRunXML[0].Split("-")[1]
$yearxml = $LastRunXML[0].Split("-")[2]

$LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1] 

$HeddingText = "XenDesktop Check " + $LastRunXML
New-UDLayout -Columns 1 -Content {
    New-UDCard -Text $HeddingText -TextSize Small -TextAlignment right
       New-UDGrid -Title 'Citrix Sessions' -Endpoint {$CheckXML.CitrixRemoteFarmDetails.SessionCounts| Out-UDGridData}
       New-UDGrid -Title 'Citrix Controllers' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.Controllers.Summary | Out-UDGridData}
       New-UDGrid -Title 'Citrix DB Connection' -Endpoint {  $CheckXML.CitrixRemoteFarmDetails.DBConnection | Out-UDGridData}
       New-UDGrid -Title 'Citrix Licenses' -Endpoint {$CheckXML.CitrixLicenseInformation | Out-UDGridData}
       New-UDGrid -Title 'RDS Licenses' -Endpoint {  $CheckXML.RDSLicenseInformation.$RDSLicensType| Out-UDGridData}
       New-UDGrid -Title 'Citrix Error Counts' -Endpoint {   ($CheckXML.CitrixServerEventLogs.SingleServer | select ServerName, Errors, Warning)| Out-UDGridData}
       New-UDGrid -Title 'Citrix Events Top Events' -Endpoint {  ($CheckXML.CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count) | Out-UDGridData}
       New-UDGrid -Title 'StoreFront Site' -Endpoint {   $CheckXML.StoreFrontDetails.SiteDetails| Out-UDGridData}
       New-UDGrid -Title 'StoreFront Server' -Endpoint {  $CheckXML.StoreFrontDetails.ServerDetails | Out-UDGridData}
       New-UDGrid -Title 'Citrix Config Changes in the last 7 days' -Endpoint {  ($CheckXML.CitrixConfigurationChanges.Summary | where { $_.name -ne "" } | Sort-Object count -Descending | select -First 5 -Property count, name) | Out-UDGridData}
       New-UDGrid -Title 'Citrix Server Performace' -Endpoint {  ($CheckXML.ServerPerformance)| Out-UDGridData}
       New-UDGrid -Title 'Citrix Delivery Groups' -Endpoint {  $CheckXML.CitrixRemoteFarmDetails.DeliveryGroups| Out-UDGridData}
       New-UDGrid -Title 'Citrix UnRegistered Desktops' -Endpoint {  $CheckXML.CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops| Out-UDGridData}
       New-UDGrid -Title 'Citrix UnRegistered Servers' -Endpoint {  $CheckXML.CitrixRemoteFarmDetails.Machines.UnRegisteredServers| Out-UDGridData}
       New-UDGrid -Title 'Citrix Tainted Objects' -Endpoint {  $CheckXML.CitrixRemoteFarmDetails.ADObjects.TaintedObjects| Out-UDGridData}

}
} 
#endregion

#region Section1
	New-UDCollapsibleItem -Title 'Latest Health Check Report' -Content {
		New-UDCard -Id 'Healcheck1' -BackgroundColor grey -Endpoint {
			param ($TodayReport)
			$TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	New-UDHtml ([string](Get-Content $TodayReport.FullName)) }
}
#endregion

#region Section2
New-UDCollapsibleItem -Title 'Second Last Health Check Report' -Content {
	New-UDCard -Id 'Healcheck2' -BackgroundColor grey -Endpoint {
		param ($2DAYSReport)
		$2DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[1]) | select *
New-UDHtml ([string](Get-Content $2DAYSReport.FullName)) }
}
#endregion

#region Section3
New-UDCollapsibleItem -Title 'Latest Health Check Report'-Content {
	New-UDCard -Id 'Healcheck3' -BackgroundColor grey -Endpoint {
		param ($3DAYSReport)
		$3DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *
New-UDHtml ([string](Get-Content $3DAYSReport.FullName)) }
}
#endregion

} # Main Collapsible

} # Page