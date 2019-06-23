$DashLive = New-UDPage -Name "Live Health Check" -Icon address_book -Content {
	New-UDMuPaper -Content { New-UDHeading -Text 'XenDesktop Health Check' -Size 3 } -Elevation 4
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {
		Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white' } -Persistent -BackgroundColor green
		Initialize-CitrixHealthCheck -XMLParameterFilePath $XMLParameterFilePath -Verbose
		Hide-UDModal
		$Cache:CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)
		Sync-UDElement -Id 'xml2' -Broadcast
	}
	New-UDLayout -Columns 1  -Content {
		New-UDCard -BackgroundColor "#e5e5e5" -Id 'xml2' -Endpoint {
			param($Cache:CheckXML)

			$Cache:CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)

			$LastRunXML = $Cache:CheckXML.DateCollected.split("_")
			$Dayxml = $LastRunXML[0].Split("-")[0]
			$Monthxml = $LastRunXML[0].Split("-")[1]
			$yearxml = $LastRunXML[0].Split("-")[2]

			$LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1]

			$HeddingText = " Data Refreshed on: " + ($LastRun).ToLongDateString() + ", " + ($LastRun).ToLongTimeString()
			New-UDMuPaper -Content { New-UDHeading -Text $HeddingText -Size 6 } -Elevation 4

			New-UDRow {
				New-UDColumn -Size 12 {
					New-UDLayout -Columns 2  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Sessions' -Endpoint { ($Cache:CheckXML.CitrixRemoteFarmDetails.SessionCounts.psobject.Properties | Select-Object -Property Name, Value) | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Config Changes in the last 7 days' -Endpoint { ($Cache:CheckXML.CitrixConfigurationChanges.Summary | Where-Object { $_.name -ne "" } | Sort-Object count -Descending | Select-Object -First 5 -Property count, name) | Out-UDGridData }
					}
					New-UDLayout -Columns 2  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Controllers' -Endpoint { $Cache:CheckXML.CitrixRemoteFarmDetails.Controllers.Summary | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix DB Connection' -Endpoint { $Cache:CheckXML.CitrixRemoteFarmDetails.DBConnection | Out-UDGridData }
					}
					New-UDLayout -Columns 2  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Licenses' -Endpoint { $Cache:CheckXML.CitrixLicenseInformation | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'RDS Licenses' -Endpoint { $Cache:CheckXML.RDSLicenseInformation.'Per Device' | Out-UDGridData }
					}
					New-UDLayout -Columns 2  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Error Counts' -Endpoint { ($Cache:CheckXML.CitrixServerEventLogs.SingleServer | Select-Object ServerName, Errors, Warning) | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Events Top Events' -Endpoint { ($Cache:CheckXML.CitrixServerEventLogs.TotalProvider | Select-Object -First ($Cache:CheckXML.CitrixServerEventLogs.SingleServer).count) | Out-UDGridData }
					}
					New-UDLayout -Columns 2  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'StoreFront Site' -Endpoint { $Cache:CheckXML.StoreFrontDetails.SiteDetails | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'StoreFront Server' -Endpoint { $Cache:CheckXML.StoreFrontDetails.ServerDetails | Out-UDGridData }
					}
					New-UDLayout -Columns 1  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Server Performace' -Endpoint { ($Cache:CheckXML.ServerPerformance) | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Delivery Groups' -Endpoint { $Cache:CheckXML.CitrixRemoteFarmDetails.DeliveryGroups | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -Title 'Citrix UnRegistered Desktops' -Endpoint { $Cache:CheckXML.CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -Title 'Citrix UnRegistered Servers' -Endpoint { $Cache:CheckXML.CitrixRemoteFarmDetails.Machines.UnRegisteredServers | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Tainted Objects' -Endpoint { $Cache:CheckXML.CitrixRemoteFarmDetails.ADObjects.TaintedObjects | Out-UDGridData }
					}
				}
			}
			#endregion
		}
	}
}


$DashLive

<#
		$job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath $XMLParameterFilePath } -ModulesToImport (Join-Path (Get-Item $PSScriptRoot).Parent xdhealthcheck.psm1) -VariablesToImport @('ParametersFolder','XMLParameterFilePath', 'XMLParameter')
		Show-UDToast -Message 'Starting Data Refresh' -MessageSize large -Duration 3
		do {
			Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white' } -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal

		}   until( $job.State -notlike 'Running')
		if ($job.HasErrors) {
			Show-UDModal -Content {
				New-UDCard -Endpoint {
					param($job, $joberror)
					New-UDParagraph -Text ( $joberror = $job | Select-Object -ExpandProperty error)  -Color 'white'
					New-UDButton -OnClick { Hide-UDModal } -Text 'OK' -Flat -BackgroundColor green -FontColor white
			 } -BackgroundColor red -Persistent

		 }
		}
		$Cache:CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)
		Sync-UDElement -Id 'xml2' -Broadcast


New-UDMuButton -Text "Refresh" -Variant contained -Style @{ backgroundColor = "green"; color = "white" } -onClick {
	$job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @(((Get-Item $profile).DirectoryName + "\Parameters.xml")) -ModulesToImport @('XDHealthCheck') -FunctionFilesToImport "..\XDHealthCheck.psm1"
	Show-UDToast -Message 'Starting Data Refresh' -MessageSize large -Duration 5
	do {
		New-UDPreloader -Circular -Size large
	}   until( $job.State -notlike 'Running')
	$Cache:CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)
	Sync-UDElement -Id 'xml2' -Broadcast

}
#>
