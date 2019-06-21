$DashLive = New-UDPage -Name "Live Health Check" -Icon address_book -Content {
New-UDMuPaper -Content { New-UDHeading -Text 'Citrix Health Check' -Size 3 } -Elevation 4
New-UDLayout -Columns 1  -Content {
New-UDCard -Id 'xml2' -Endpoint {
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
					New-UDLayout -Columns 1  -Content {
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
}
}


$DashLive
