#region Page2
$XDAuditPage = New-UDPage -Name "Audit Results" -Icon folder_open -Content {
New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {
        $job = Start-RSJob -ScriptBlock { Initialize-CitrixAudit -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($env:PSParameters)
		do {
            Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white'} -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal
}   until( $job.State -notlike 'Running')
    $AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | Select-Object *
    $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
    Sync-UDElement -Id 'Audit1' -Broadcast
    Sync-UDElement -Id 'AuditXML1' -Broadcast
    Sync-UDElement -Id 'AuditXML2' -Broadcast
    Sync-UDElement -Id 'AuditXML3' -Broadcast
    Sync-UDElement -Id 'AuditXML4' -Broadcast
} # onclick

New-UDCollapsible -Items {
New-UDCollapsibleItem -Id 'AuditXML1' -Title 'Latest Health Check Report'-Content {
    New-UDCard -Id 'Audit1' -Endpoint {
	param ($AuditReport)
    $AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | Select-Object *
	New-UDHtml ([string](Get-Content $AuditReport.FullName))
}
} -Active
#region Machine
New-UDCollapsibleItem -Id 'AuditXML2' -Endpoint {
		New-UDInput -Title "Machine Catalogs" -Content {
            $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
            $SelectCatalog =  $auditXML.MashineCatalog  | Select-Object MachineCatalogName | ForEach-Object {$_.MachineCatalogName}
        New-UDInputField -Name machineCatalog -Values @($SelectCatalog) -Type select
        } -Endpoint {
				param(
					[string]$machineCatalog)

        New-UDInputAction -Toast $machineCatalog
		New-UDInputAction -Content @(
        $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
        $showcatalog = $auditXML.MashineCatalog | Where-Object {$_.MachineCatalogName -like $machineCatalog}
		$showcataloglist = $showcatalog.psobject.Properties | Select-Object -Property Name, Value

	    New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
	    New-UDLayout -Columns 1 -Content {
		    New-UDGrid -Title 'Catalog Details' -NoPaging -NoFilter -PageSize 25 -Endpoint { $showcataloglist | Out-UDGridData }}
        )}
} -Title "Machine Catalog Details" -FontColor black
#endregion
#region Delivery
New-UDCollapsibleItem -Id 'AuditXML3'  -Endpoint {
		New-UDInput -Title "Delivery Groups" -Content {
            $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
            $SelecGroup =  $auditXML.DeliveryGroups  | Select-Object DesktopGroupName | ForEach-Object {$_.DesktopGroupName}
        New-UDInputField -Name DeliveryGroups -Values @($SelecGroup) -Type select
        } -Endpoint {
				param(
					[string]$DeliveryGroups)

        New-UDInputAction -Toast $DeliveryGroups
		New-UDInputAction -Content @(
        $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
        $showDeliveryGroups = $auditXML.DeliveryGroups | Where-Object {$_.DesktopGroupName -like $DeliveryGroups}
		$showDeliveryGroupslist = $showDeliveryGroups.psobject.Properties | Select-Object -Property Name, Value

	    New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
	    New-UDLayout -Columns 1 -Content {
		    New-UDGrid -Title 'Delivery Groups' -NoPaging -NoFilter -PageSize 25 -Endpoint { $showDeliveryGroupslist | Out-UDGridData }}
        )}
} -Title "Delivery Groups Details" -FontColor black
#endregion
#region Apps
New-UDCollapsibleItem -Id 'AuditXML4'  -Endpoint {
		New-UDInput -Title "Published Applications" -Content {
            $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
            $SelectApp =  $auditXML.PublishedApps  | Select-Object PublishedName | ForEach-Object {$_.PublishedName}
            #$AppUnique = $SelectApp | sort -Unique
        New-UDInputField -Name PubApp -Values @($SelectApp) -Type select
        } -Endpoint {
				param([string]$PubApp)

        New-UDInputAction -Toast $PubApp
		New-UDInputAction -Content @(
        $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)

        $showPubApp = $auditXML.PublishedApps | Where-Object {$_.PublishedName -like $PubApp}
        $ShowAppDelGroup =  $showPubApp | Select-Object DesktopGroupName
		$showPubApplist = $showPubApp[0].psobject.Properties | Select-Object -Property Name, Value
	  
	    New-UDHeading -Text (Get-Date -DisplayHint DateTime).ToString() -Size 2
        New-UDLayout -Columns 3 -Content {
            New-UDGrid -Title 'Delivery Groups for Application' -NoPaging -NoFilter -Endpoint { $ShowAppDelGroup | Out-UDGridData }
		    New-UDGrid -Title 'Published Application' -NoPaging -NoFilter -Endpoint { $showPubApplist | Out-UDGridData }
        }   
          
        )}
} -Title "Published Application Details" -FontColor black
}
} -ArgumentList @("CTXAdmin", "CTXDDC", "CTXStoreFront", "RDSLicensServer", "RDSLicensType", "ReportsFolder", "ParametersFolder", "DashboardTitle", "SaveExcelReport")
#endregion

$XDAuditPage

