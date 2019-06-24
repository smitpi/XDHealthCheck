$homepage = New-UDPage -Name "Home" -Icon home -DefaultHomePage -Content {
	New-UDMuPaper -Content { New-UDHeading -Text 'Welcome to XenDesktop Dashboard' -Size 3 } -Elevation 4
	Show-UDModal -Content { New-UDHeading -Text "Loading"  -Color 'white' } -Persistent -BackgroundColor green

	New-UDCard -BackgroundColor "#e5e5e5" -Endpoint {
	$Cache:CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)
			$LastRunXML = $Cache:CheckXML.DateCollected.split("_")
			$LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1]
			$HeddingText = "Data Refreshed on: " + ($LastRun).ToLongDateString() + ", " + ($LastRun).ToLongTimeString()

			New-UDMuPaper -Content { New-UDHeading -Text $HeddingText -Size 6 } -Elevation 2
			New-UDLayout -Columns 2 -Content {
				New-UDTable -Title "Site Information" -Headers @(" ", " ") -Endpoint {
					$Cache:CheckXML.CitrixRemoteFarmDetails.SiteDetails.Summary.psobject.Properties | Select-Object -Property Name, Value | Out-UDTableData -Property @("Name", "Value")
				}
			New-UDTable -Title 'Red Flags' -Headers @("#", "Discription") -Endpoint { $Cache:CheckXML.Redflags | Out-UDTableData -Property  @("#", "Discription")
			Hide-UDModal
				}
			}

	}

}
$homepage
#-Text ("Data Collected at: " + $Cache:CheckXML.DateCollected.ToString())
<#
 #
 New-UDGrid -Title "Processes" -Headers @("Process Name", "Id", "View Modules") -Properties @("Name", "Id", "ViewModules") -Endpoint {
             Get-Process | ForEach-Object {
                  [PSCustomObject]@{
                       Name = $_.Name
                       Id = $_.Id
                       ViewModules = New-UDButton -Text "View Modules" -OnClick (New-UDEndpoint -Endpoint {
                           Show-UDModal -Content {
                              New-UDTable -Title "Modules" -Headers @("Name", "Path") -Content {
                                    $ArgumentList[0] | Out-UDTableData -Property @("ModuleName", "FileName")
                              }
                           }
                       } -ArgumentList $_.Modules)
                  }
              } | Out-UDGridData
     }
}

Start-UDDashboard -Dashboard $Dashboard -Port 10000
 #>
