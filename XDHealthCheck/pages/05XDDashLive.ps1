$DashLive = New-UDPage -Name "Live Health Check" -Icon address_book -Content {
	New-UDMuPaper -Content { New-UDHeading -Text 'XenDesktop Health Check' -Size 3 } -Elevation 4
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {
		#$job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @(((Get-Item $profile).DirectoryName + "\Parameters.xml")) -ModulesToImport @("..\XDHealthCheck.psm1") -FunctionFilesToImport "..\XDHealthCheck.psm1"
		$job = Start-Job -Name refresh -InitializationScript { Import-Module ((Get-Item $PSScriptRoot).parent + "\XDHealthCheck.psm1") } -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath  $args[0] } -ArgumentList @(((Get-Item $profile).DirectoryName + "\Parameters.xml"))
		Show-UDToast -Message 'Starting Data Refresh' -MessageSize large -Duration 3
		do {
			Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white' } -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal

		}   until( $job.State -notlike 'Running')
		$CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)
		Sync-UDElement -Id 'xml2' -Broadcast





	}
New-UDLayout -Columns 1  -Content {
		New-UDCard -BackgroundColor "#e5e5e5" -Id 'xml2' -Endpoint {
						param($CheckXML)

			$CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)

			$LastRunXML = $CheckXML.DateCollected.split("_")
			$Dayxml = $LastRunXML[0].Split("-")[0]
			$Monthxml = $LastRunXML[0].Split("-")[1]
			$yearxml = $LastRunXML[0].Split("-")[2]

			$LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1]

			$HeddingText = " Data Refreshed on: " + ($LastRun).ToLongDateString() + ", " + ($LastRun).ToLongTimeString()
			New-UDMuPaper -Content { New-UDHeading -Text $HeddingText -Size 6 } -Elevation 4

			New-UDRow {
				New-UDColumn -Size 12 {
					New-UDLayout -Columns 2  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Sessions' -Endpoint { ($CheckXML.CitrixRemoteFarmDetails.SessionCounts.psobject.Properties | Select-Object -Property Name, Value) | Out-UDTableData -Property @("Name", "Value") }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Config Changes in the last 7 days' -Endpoint { ($CheckXML.CitrixConfigurationChanges.Summary | Where-Object { $_.name -ne "" } | Sort-Object count -Descending | Select-Object -First 5 -Property count, name) | Out-UDGridData }
					}
					New-UDLayout -Columns 2  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Controllers' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.Controllers.Summary | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix DB Connection' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.DBConnection | Out-UDGridData }
					}
					New-UDLayout -Columns 2  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Licenses' -Endpoint { $CheckXML.CitrixLicenseInformation | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'RDS Licenses' -Endpoint { $CheckXML.RDSLicenseInformation.'Per Device' | Out-UDGridData }
					}
					New-UDLayout -Columns 2  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Error Counts' -Endpoint { ($CheckXML.CitrixServerEventLogs.SingleServer | Select-Object ServerName, Errors, Warning) | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Events Top Events' -Endpoint { ($CheckXML.CitrixServerEventLogs.TotalProvider | Select-Object -First ($CheckXML.CitrixServerEventLogs.SingleServer).count) | Out-UDGridData }
					}
					New-UDLayout -Columns 2  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'StoreFront Site' -Endpoint { $CheckXML.StoreFrontDetails.SiteDetails | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'StoreFront Server' -Endpoint { $CheckXML.StoreFrontDetails.ServerDetails | Out-UDGridData }
					}
					New-UDLayout -Columns 1  -Content {
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Server Performace' -Endpoint { ($CheckXML.ServerPerformance) | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Delivery Groups' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.DeliveryGroups | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -Title 'Citrix UnRegistered Desktops' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -Title 'Citrix UnRegistered Servers' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.Machines.UnRegisteredServers | Out-UDGridData }
						New-UDGrid -NoFilter -NoPaging -PageSize 25 -Title 'Citrix Tainted Objects' -Endpoint { $CheckXML.CitrixRemoteFarmDetails.ADObjects.TaintedObjects | Out-UDGridData }
					}
				}
			}
			#endregion
		}
}
}


$DashLive

<#


New-UDMuButton -Text "Refresh" -Variant contained -Style @{ backgroundColor = "green"; color = "white" } -onClick {
	$job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @(((Get-Item $profile).DirectoryName + "\Parameters.xml")) -ModulesToImport @('XDHealthCheck') -FunctionFilesToImport "..\XDHealthCheck.psm1"
	Show-UDToast -Message 'Starting Data Refresh' -MessageSize large -Duration 5
	do {
		New-UDPreloader -Circular -Size large
	}   until( $job.State -notlike 'Running')
	$CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)
	Sync-UDElement -Id 'xml2' -Broadcast

}
#>
