#region Page1
New-UDPage -Name "XD Health Check" -Icon home -DefaultHomePage -Content {
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {         		
        $job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($CTXParameters)
		do {
            Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white'} -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal		   
}   until( $job.State -notlike 'Running')
    $TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    $2DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[1]) | select *
    $3DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *

    Sync-UDElement -Id 'Healcheck1'
    Sync-UDElement -Id 'Healcheck2'
    Sync-UDElement -Id 'Healcheck3'

} # onclick
New-UDCollapsible -Items {
    New-UDCollapsibleItem -Title 'Latest Health Check Report'-Content {
    New-UDCard -Id 'Healcheck1' -BackgroundColor grey -Endpoint {
	param ($TodayReport)
    $TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	New-UDHtml ([string](Get-Content $TodayReport.FullName))}
} -Active -BackgroundColor grey
}

New-UDCollapsible -Items {
    New-UDCollapsibleItem -Title 'Second Last Health Check Report'-Content {
    New-UDCard -Id 'Healcheck2' -BackgroundColor grey -Endpoint {
	param ($2DAYSReport)
    $2DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[1]) | select *
	New-UDHtml ([string](Get-Content $2DAYSReport.FullName))}
} -BackgroundColor grey
} -BackgroundColor grey

New-UDCollapsible -Items {
    New-UDCollapsibleItem -Title 'Latest Health Check Report'-Content {
    New-UDCard -Id 'Healcheck3' -BackgroundColor grey -Endpoint {
	param ($3DAYSReport)
    $3DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *
	New-UDHtml ([string](Get-Content $3DAYSReport.FullName))}
} -BackgroundColor grey
} -BackgroundColor grey
}
#endregion