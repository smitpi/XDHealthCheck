#region Page2
$XDAuditPagelive = New-UDPage -Name "Live Audit Results" -Icon folder_open -Content {
	New-UDMuPaper -Content { New-UDHeading -Text 'XenDesktop Audit Results' -Size 3 } -Elevation 4
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {
		Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white' } -Persistent -BackgroundColor green
		Initialize-CitrixAudit  -XMLParameterFilePath $XMLParameterFilePath -Verbose
		Hide-UDModal
		$Cache:auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
		Sync-UDElement -Id 'xml3' -Broadcast
		Sync-UDElement -Id 'AuditXML1' -Broadcast
		Sync-UDElement -Id 'AuditXML2' -Broadcast
		Sync-UDElement -Id 'AuditXML3' -Broadcast
		Sync-UDElement -Id 'AuditXML4' -Broadcast
	} # onclick
	New-UDCard -BackgroundColor "#e5e5e5" -Id 'xml3' -Endpoint {
		param($Cache:auditXML)
		$Cache:auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
		$LastRunXML = $Cache:auditXML.DateCollected.split("_")
		$Dayxml = $LastRunXML[0].Split("-")[0]
		$Monthxml = $LastRunXML[0].Split("-")[1]
		$yearxml = $LastRunXML[0].Split("-")[2]

		$LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1]

		$HeddingText = " Data Refreshed on: " + ($LastRun).ToLongDateString() + ", " + ($LastRun).ToLongTimeString()
		New-UDMuPaper -Content { New-UDHeading -Text $HeddingText -Size 6 } -Elevation 4
	}
	New-UDCollapsible -Items {
		#region Summery details
		New-UDCollapsibleItem -BackgroundColor '#E5E5E5' -Id 'AuditXML1' -Title 'Audit Results' -Endpoint {
			New-UDRow {
				New-UDColumn -Size 12 {
					New-UDLayout -Columns 1  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Mashine Catalog Summery' -Endpoint { $Cache:auditXML.MashineCatalogSum | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Delivery Group Summery' -Endpoint { $Cache:auditXML.DeliveryGroupsSum | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Published Application Summery' -Endpoint { $Cache:auditXML.PublishedAppsSum | Out-UDGridData }
					}
				}
			}
		}
		#endregion
		#region Machine
		New-UDCollapsibleItem -BackgroundColor '#E5E5E5' -Id 'AuditXML2' -Endpoint {
			New-UDInput -Content {
				$Cache:auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
				[System.Collections.ArrayList]$SelectCatalog = @()
				$SelectCatalog = $Cache:auditXML.MashineCatalog | Select-Object MachineCatalogName | ForEach-Object { $_.MachineCatalogName }
				$SelectCatalog.Insert(0, "Select a Mashine Catalog")
				New-UDInputField -Name machineCatalog -Values @($SelectCatalog) -Type select -Placeholder "Machine Catalog"
			} -Endpoint {
				param(
					[string]$machineCatalog)

				New-UDInputAction -Toast $machineCatalog
				New-UDInputAction -Content @(
					$Cache:auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
					$showcatalog = $Cache:auditXML.MashineCatalog | Where-Object { $_.MachineCatalogName -like $machineCatalog }
					$showcataloglist = $showcatalog.psobject.Properties | Select-Object -Property Name, Value
					New-UDLayout -Columns 1 -Content {
						New-UDGrid -Title 'Catalog Details' -NoPaging -NoFilter -PageSize 25 -Endpoint { $showcataloglist | Out-UDGridData } }
				) }
		} -Title "Machine Catalog Details" -FontColor black
		#endregion
		#region Delivery
		New-UDCollapsibleItem -BackgroundColor '#E5E5E5' -Id 'AuditXML3'  -Endpoint {
			New-UDInput -Content {
				$Cache:auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
				[System.Collections.ArrayList]$SelecGroup = @()
				$SelecGroup = $Cache:auditXML.DeliveryGroups | Select-Object DesktopGroupName | ForEach-Object { $_.DesktopGroupName }
				$SelecGroup.Insert(0, "Select a Delivery Groups")
				New-UDInputField -Name DeliveryGroups -Values @($SelecGroup) -Type select -Placeholder "Delivery Groups"
			} -Endpoint {
				param(
					[string]$DeliveryGroups)

				New-UDInputAction -Toast $DeliveryGroups
				New-UDInputAction -Content @(
					$Cache:auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
					$showDeliveryGroups = $Cache:auditXML.DeliveryGroups | Where-Object { $_.DesktopGroupName -like $DeliveryGroups }
					$showDeliveryGroupslist = $showDeliveryGroups.psobject.Properties | Select-Object -Property Name, Value

					New-UDLayout -Columns 1 -Content {
						New-UDGrid -Title 'Delivery Groups' -NoPaging -NoFilter -PageSize 25 -Endpoint { $showDeliveryGroupslist | Out-UDGridData } }
				) }
		} -Title "Delivery Groups Details" -FontColor black
		#endregion
		#region Apps
		New-UDCollapsibleItem -BackgroundColor '#E5E5E5' -Id 'AuditXML4'  -Endpoint {
			New-UDInput -Content {
				$Cache:auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
				[System.Collections.ArrayList]$SelectApp = @()
				$SelectApp = $Cache:auditXML.PublishedApps | Select-Object PublishedName | ForEach-Object { $_.PublishedName }
				$SelectApp.Insert(0, "Select a Published Application")

				#$AppUnique = $SelectApp | sort -Unique
				New-UDInputField -Name PubApp -Values @($SelectApp) -Type select -Placeholder "Published Applications"
			} -Endpoint {
				param([string]$PubApp)

				New-UDInputAction -Toast $PubApp
				New-UDInputAction -Content @(
					$Cache:auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)

					$showPubApp = $Cache:auditXML.PublishedApps | Where-Object { $_.PublishedName -like $PubApp }
					$ShowAppDelGroup = $showPubApp | Select-Object DesktopGroupName
					$showPubApplist = $showPubApp[0].psobject.Properties | Select-Object -Property Name, Value

					New-UDLayout -Columns 3 -Content {
						New-UDGrid -Title 'Delivery Groups for Application' -NoPaging -NoFilter -Endpoint { $ShowAppDelGroup | Out-UDGridData }
						New-UDGrid -Title 'Published Application' -NoPaging -NoFilter -Endpoint { $showPubApplist | Out-UDGridData }
					}

				) }
		} -Title "Published Application Details" -FontColor black

	}
} -ArgumentList @("DateCollected", "CTXDDC", "CTXStoreFront", "RDSLicensServer", "RDSLicensType", "TrustedDomains", "ReportsFolder", "ParametersFolder", "DashboardTitle", "SaveExcelReport", "SendEmail", "EmailFrom", "EmailTo", "SMTPServer", "SMTPServerPort", "SMTPEnableSSL", 'XMLParameterFilePath', 'XMLParameter')
#endregion

$XDAuditPagelive

<#
 #
 $auditjob = Start-RSJob -ScriptBlock { Initialize-CitrixAudit  -XMLParameterFilePath $XMLParameterFilePath } -ModulesToImport (Join-Path (Get-Item $PSScriptRoot).Parent xdhealthcheck.psm1)-VariablesToImport @('ParametersFolder','XMLParameterFilePath', 'XMLParameter')
		do {
			Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white' } -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal
		}   until( $auditjob.State -notlike 'Running')
		$Cache:auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
		Sync-UDElement -Id 'xml3' -Broadcast
		Sync-UDElement -Id 'AuditXML1' -Broadcast
		Sync-UDElement -Id 'AuditXML2' -Broadcast
		Sync-UDElement -Id 'AuditXML3' -Broadcast
		Sync-UDElement -Id 'AuditXML4' -Broadcast
 #>
