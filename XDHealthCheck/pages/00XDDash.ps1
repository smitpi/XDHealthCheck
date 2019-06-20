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
New-UDCollapsibleItem -Title 'Red Flags' -Content {
New-UDCard -id 'Checkxml1' -Endpoint {
param ($HealthXML)
$HealthXML = Import-Clixml (Get-ChildItem $reportsfolder\XDHealth\*.xml)
New-UDLayout -Columns 1 -Content {
		  New-UDGrid -Title 'Red Flags' -BackgroundColor whi  -NoPaging -NoFilter -Endpoint { $HealthXML.Redflags | Out-UDGridData }}
}
} -Active
#region Section1
New-UDCollapsibleItem -Title ("Health Check Report - " + $htmlindex[0].LastWriteTime.tostring()) -Content {
	New-UDCard -Id 'Healcheck1' -Endpoint {
			param ($TodayReport)
            $htmlindex = Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending
            $TodayReport = Get-Item ($htmlindex[0]) | Select-Object *
	New-UDHtml ([string](Get-Content $TodayReport.FullName)) }
}
#endregion
#region Section2
New-UDCollapsibleItem -Title ("Health Check Report - " + $htmlindex[1].LastWriteTime.tostring()) -Content {
	New-UDCard -Id 'Healcheck2' -Endpoint {
param ($2DAYSReport)
$htmlindex = Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending
$2DAYSReport = Get-Item ($htmlindex[1]) | Select-Object *
New-UDHtml ([string](Get-Content $2DAYSReport.FullName)) }
}
#endregion
#region Section3
New-UDCollapsibleItem -Title ("Health Check Report - " + $htmlindex[2].LastWriteTime.tostring()) -Content {
New-UDCard -Id 'Healcheck3' -Endpoint {
param ($3DAYSReport)
$htmlindex = Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending
$3DAYSReport = Get-Item ($htmlindex[2]) | Select-Object *

New-UDHtml ([string](Get-Content $3DAYSReport.FullName)) }
#endregion

} # Main Collapsible
#endregion

}
} # Page

$XDDashPage
<#


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
