$XDDashPage = New-UDPage -Name "XD Health Check" -Icon home -DefaultHomePage -Content {
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

Sync-UDElement -Id 'Healcheck1' -Broadcast
Sync-UDElement -Id 'Healcheck2' -Broadcast
Sync-UDElement -Id 'Healcheck3' -Broadcast
Sync-UDElement -Id 'Checkxml1' -Broadcast

} # onclick


New-UDCollapsible -Items {
#region Section1
New-UDCollapsibleItem -Title 'Latest Health Check Report' -Content {
		New-UDCard -Id 'Healcheck1' -Endpoint {
			param ($TodayReport)
			$TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	New-UDHtml ([string](Get-Content $TodayReport.FullName)) }
} -Active
#endregion

#region Section2
New-UDCollapsibleItem -Title 'Second Last Health Check Report' -Content {
	New-UDCard -Id 'Healcheck2' -Endpoint {
param ($2DAYSReport)
$2DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[1]) | select *
New-UDHtml ([string](Get-Content $2DAYSReport.FullName)) }
}
#endregion
#region Section3
New-UDCollapsibleItem -Title '3rd Last Health Check Report'-Content {
New-UDCard -Id 'Healcheck3' -Endpoint {
param ($3DAYSReport)
$3DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *
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
