$homepage = New-UDPage -Name "Home" -Icon home -DefaultHomePage -Content {
	New-UDMuPaper -Content { New-UDHeading -Text 'Welcome to Citrix Dashboard' -Size 3 } -Elevation 4
	
		New-UDCard -BackgroundColor "#e5e5e5" -Endpoint {
        $CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)

	        $LastRunXML = $CheckXML.DateCollected.split("_")
	        $Dayxml = $LastRunXML[0].Split("-")[0]
	        $Monthxml = $LastRunXML[0].Split("-")[1]
	        $yearxml = $LastRunXML[0].Split("-")[2]

	        $LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1]

	        $HeddingText = "Data Refreshed on: " + $LastRunXML

	        New-UDMuPaper -Content { New-UDHeading -Text $HeddingText -Size 6 } -Elevation 2
            New-UDLayout -Columns 2 -Content {

			New-UDTable -Title "Site Information" -Headers @(" ", " ") -Endpoint {
				$CheckXML.CitrixRemoteFarmDetails.SiteDetails.Summary.psobject.Properties | Select-Object -Property Name, Value | Out-UDTableData -Property @("Name", "Value")
			}
			New-UDTable -Title "Logged in User Information" -Headers @(" ", " ") -Endpoint {
				$user = Get-ADUser $env:USERNAME -Properties * | Select-Object Name, GivenName, Surname, UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate, samaccountname
				$user.psobject.Properties | Select-Object -Property Name, Value | Out-UDTableData -Property @("Name", "Value")
			}
		
        } 
	}

}
$homepage
#-Text ("Data Collected at: " + $CheckXML.DateCollected.ToString())
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
