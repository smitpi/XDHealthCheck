$homepage = New-UDPage -Name "Home" -Icon home -DefaultHomePage -Content {
	New-UDMuPaper -Content { New-UDHeading -Text 'Welcome to Citrix Dashboard' -Size 3 } -Elevation 4
	New-UDLayout -Columns 2 -Content {
		New-UDMuPaper -Content {
			New-UDTable -Title "Site Information" -Headers @(" ", " ") -Endpoint {
				$CheckXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\*.xml)
				$CheckXML.CitrixRemoteFarmDetails.SiteDetails.Summary.psobject.Properties | Select-Object -Property Name, Value | Out-UDTableData -Property @("Name", "Value")
			}

		} -Elevation 4
		New-UDMuPaper -Content {
			New-UDTable -Title "Logged in User Information" -Headers @(" ", " ") -Endpoint {
				$user = Get-ADUser $env:USERNAME -Properties * | Select-Object Name, GivenName, Surname, UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate, samaccountname
				$user.psobject.Properties | Select-Object -Property Name, Value | Out-UDTableData -Property @("Name", "Value")
			}
		} -Elevation 4
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
