$homepage = New-UDPage -Name "Home" -Icon home -DefaultHomePage -Content {
	New-UDMuPaper -Content {New-UDHeading -Text 'Welcome to Citrix Dashboard' -Size 3} -Elevation 4
	New-UDMuCard -Body (
		New-UDMuCardBody -Content {
	        $CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)
            New-UDCard -id 'Checkxml1' -Endpoint {
                    param ($HealthXML,$XMLParameter)
	        $CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)
	        $site = $CheckXML.CitrixRemoteFarmDetails.SiteDetails.Summary.psobject.Properties | Select-Object -Property Name, Value
            $counts = $CheckXML.CitrixRemoteFarmDetails.SessionCounts.psobject.Properties | Select-Object -Property Name, Value
            New-UDHeading -Text ("Collected at: " + $CheckXML.DateCollected.ToString()) -Size 5
            New-UDLayout -Columns 2 -Content {
				New-UDGrid -Title 'Site Details' -NoFilter -Endpoint { $site | Out-UDGridData }
                New-UDGrid -Title 'Session Counts'   -NoFilter -Endpoint { $counts | Out-UDGridData }            
            }
			}
			})
}
$homepage
 #-Text ("Data Collected at: " + $CheckXML.DateCollected.ToString())