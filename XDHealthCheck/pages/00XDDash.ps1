$XDDashPage = New-UDPage -Name "Health Check" -Icon medkit -Content {
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {
		$job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($env:PSParameters)
		do {
			Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white' } -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal
		}   until( $job.State -notlike 'Running')
		$HealthXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)

		$htmlindex = Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending
		$TodayReport = Get-Item ($htmlindex[0]) | Select-Object *
		$2DAYSReport = Get-Item ($htmlindex[1]) | Select-Object *
		$3DAYSReport = Get-Item ($htmlindex[2]) | Select-Object *

		Sync-UDElement -Id 'Healcheck1' -Broadcast
		Sync-UDElement -Id 'Healcheck2' -Broadcast
		Sync-UDElement -Id 'Healcheck3' -Broadcast
		Sync-UDElement -Id 'Checkxml1' -Broadcast

	} # onclick
	$htmlindex = Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending
	$TodayReport = Get-Item ($htmlindex[0]) | Select-Object *
	$2DAYSReport = Get-Item ($htmlindex[1]) | Select-Object *
	$3DAYSReport = Get-Item ($htmlindex[2]) | Select-Object *
	$HealthXML = Import-Clixml (Get-ChildItem $reportsfolder\XDHealth\*.xml)

New-UDCollapsible -Items {
New-UDCollapsibleItem -BackgroundColor '#E5E5E5'  -Title 'Red Flags' -Content {
	New-UDCard -id 'Checkxml1' -Endpoint {
		param ($HealthXML)
		$HealthXML = Import-Clixml (Get-ChildItem $reportsfolder\XDHealth\*.xml)
		New-UDLayout -Columns 1 -Content {
			New-UDGrid -Title 'Red Flags' -BackgroundColor whi  -NoPaging -NoFilter -Endpoint { $HealthXML.Redflags | Out-UDGridData } }
	}
} -Active
#region Section1
New-UDCollapsibleItem -BackgroundColor '#E5E5E5' -Title ("Health Check Report - " + $htmlindex[0].LastWriteTime.tostring()) -Content {
	New-UDCard -Id 'Healcheck1' -Endpoint {
		param ($TodayReport)
		$htmlindex = Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending
		$TodayReport = Get-Item ($htmlindex[0]) | Select-Object *
		New-UDHtml ([string](Get-Content $TodayReport.FullName)) }
}
#endregion
		#region Section2
New-UDCollapsibleItem -BackgroundColor '#E5E5E5' -Title ("Health Check Report - " + $htmlindex[1].LastWriteTime.tostring()) -Content {
	New-UDCard -Id 'Healcheck2' -Endpoint {
		param ($2DAYSReport)
		$htmlindex = Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending
		$2DAYSReport = Get-Item ($htmlindex[1]) | Select-Object *
		New-UDHtml ([string](Get-Content $2DAYSReport.FullName)) }
}
		#endregion
		#region Section3
New-UDCollapsibleItem -BackgroundColor '#E5E5E5' -Title ("Health Check Report - " + $htmlindex[2].LastWriteTime.tostring()) -Content {
	New-UDCard -Id 'Healcheck3' -Endpoint {
		param ($3DAYSReport)
		$htmlindex = Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending
		$3DAYSReport = Get-Item ($htmlindex[2]) | Select-Object *

		New-UDHtml ([string](Get-Content $3DAYSReport.FullName)) }
	#endregion

} # Main Collapsible
		#endregion
		#region Section0

}
} # Page

$XDDashPage
<#
New-UDCollapsibleItem -BackgroundColor '#E5E5E5' -Title 'Live Results' -Id 'Checkxml1' -Endpoint {
	param($CheckXML)
	$CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)

	$LastRunXML = $CheckXML.DateCollected.split("_")
	$Dayxml = $LastRunXML[0].Split("-")[0]
	$Monthxml = $LastRunXML[0].Split("-")[1]
	$yearxml = $LastRunXML[0].Split("-")[2]

	$LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1]

	$HeddingText = "XenDesktop Check " + $LastRunXML
			New-UDMuPaper -Content { New-UDHeading -Text $HeddingText -Size 3 } -Elevation 4
			New-UDMuPaper -Content {
			New-UDRow {
				New-UDColumn -Size 12 {
					New-UDLayout -Columns  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Sessions' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.SessionCounts | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Controllers' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.Controllers.Summary | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix DB Connection' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.DBConnection | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Licenses' -Endpoint { $CheckXML.CitrixLicenseInformation | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'RDS Licenses' -Endpoint { $CheckXML.RDSLicenseInformation.$RDSLicensType | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Error Counts' -Endpoint { ($CheckXML.CitrixServerEventLogs.SingleServer | Select-Object ServerName, Errors, Warning) | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Events Top Events' -Endpoint { ($CheckXML.CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count) | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'StoreFront Site' -Endpoint { $CheckXML.StoreFrontDetails.SiteDetails | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'StoreFront Server' -Endpoint { $CheckXML.StoreFrontDetails.ServerDetails | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Config Changes in the last 7 days' -Endpoint { ($CheckXML.CitrixConfigurationChanges.Summary | Where-Object { $_.name -ne "" } | Sort-Object count -Descending | Select-Object -First 5 -Property count, name) | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Server Performace' -Endpoint { ($CheckXML.ServerPerformance) | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Delivery Groups' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.DeliveryGroups | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix UnRegistered Desktops' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix UnRegistered Servers' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.Machines.UnRegisteredServers | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Tainted Objects' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.ADObjects.TaintedObjects | Out-UDGridData }
					}
				}
			}
	} -Elevation 4
	#endregion
	}


$CheckXML.CitrixRemoteFarmDetails.SessionCounts.psobject.Properties | foreach {('"' + $_.name + '"')} | Join-String -Separator ","

#region Section1
	New-UDCollapsibleItem -Title 'Latest Health Check Report' -Content {
		New-UDCard -Id 'Healcheck1' -Endpoint {
			param ($TodayReport)
			$TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	New-UDHtml ([string](Get-Content $TodayReport.FullName)) }
}
#endregion
New-UDCollapsibleItem -Title 'Latest Audit Report' -Content {
param ($AuditReport)
$AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
 New-UDHtml ([string](Get-Content $AuditReport.FullName)) }

  #
#>
