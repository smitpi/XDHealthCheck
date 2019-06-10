New-UDPage -Name "XD Audit Results" -Icon bomb -Content {
New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {         		
        $job = Start-RSJob -ScriptBlock { Initialize-CitrixAudit -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($CTXParameters)
		do {
            Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white'} -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal		   
}   until( $job.State -notlike 'Running')
    $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
    $AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    Sync-UDElement -Id 'Audit1'
    Sync-UDElement -Id 'Auditxml1'
} # onclick

New-UDCollapsible -Items {
#region Section2
New-UDCollapsibleItem -Title 'Audit Results' -Id 'Auditxml1' -Endpoint {
param($auditXML)
$auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)

$LastRunXML =$auditXML.DateCollected.split("_")
$Dayxml = $LastRunXML[0].Split("-")[0]
$Monthxml = $LastRunXML[0].Split("-")[1]
$yearxml = $LastRunXML[0].Split("-")[2]

$LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1] 

$HeddingText = "XenDesktop Audit " + $LastRunXML
New-UDLayout -Columns 1 -Content{
    New-UDCard -Text $HeddingText -TextSize Small -TextAlignment right
    New-UDGrid -Title 'Citrix Mashine Catalog' -NoPaging -Endpoint {$auditXML.MashineCatalog| Out-UDGridData}
    New-UDGrid -Title 'Citrix Delivery Groups'-NoPaging -Endpoint { $auditXML.DeliveryGroups | Out-UDGridData}
    New-UDGrid -Title 'Citrix PublishedApps' -NoPaging -Endpoint { $auditXML.PublishedApps | Out-UDGridData}
}
} 
#endregion
#region Section1
New-UDCollapsibleItem -Title 'HTML Audit Results'-Content {
		New-UDCard -Id 'Audit1' -Endpoint {
			param ($AuditReport)
			$AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	    New-UDHtml ([string](Get-Content $AuditReport.FullName))
}
} -FontColor black
#endregion


} # Main Collapsible
} #Page