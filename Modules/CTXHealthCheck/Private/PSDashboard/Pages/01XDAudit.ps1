
#region Page2
New-UDPage -Name "XD Audit Results" -Icon bomb -Content {
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {         		
        $job = Start-RSJob -ScriptBlock { Initialize-CitrixAudit -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($CTXParameters)
		do {
            Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white'} -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal		   
}   until( $job.State -notlike 'Running')
    $AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    Sync-UDElement -Id 'Audit1'
} # onclick
New-UDCollapsible -Items {
    New-UDCollapsibleItem -Title 'Latest Health Check Report'-Content {
    New-UDCard -Id 'Audit1' -Endpoint {
	param ($AuditReport)
    $AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	New-UDHtml ([string](Get-Content $AuditReport.FullName))
}
}
}
}
#endregion
