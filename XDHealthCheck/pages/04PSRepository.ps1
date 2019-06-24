$PSRepository = New-UDPage -Name "PowerShell Repository" -Icon columns -Content {
New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {
    $repository = Get-PSRepository | Where-Object {$_.Name -notlike 'PSGallery'}
    $Cache:psrep = New-Object PSObject -Property @{
        DateCollected = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
        ResultScript  = Find-script -Repository $repository.Name | Select-Object -Property Name, Version, Author,tags, Description
        ResultModule  = Find-Module -Repository $repository.Name  | Select-Object -Property Name, Version, Author,tags, Description
      } | Select-Object DateCollected,ResultScript,ResultModule

       $PSXML = "$ReportsFolder\PSRepository.xml"
        if (Test-Path -Path $PSXML) { Remove-Item $PSXML -Force -Verbose }
	   $Cache:psrep| Export-Clixml -Path $PSXML -Depth 25 -NoClobber -Force

		do {
            Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white'} -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal
}   until( $PSUpdate.State -notlike 'Running')

}
New-UDMuPaper -Content { New-UDHeading -Text 'Powershell Repository' -Size 3 } -Elevation 4

New-UDCollapsible -Items {
New-UDCollapsibleItem -Id 'PSScript'-Content {
    New-UDLayout -Columns 1  -Content {
		    New-UDMuPaper -Content {
			    New-UDTable -Title "Script Details" -Headers @("Name", "Type", "Author", "Description") -Endpoint {
				    $PSXML = Import-Clixml (Get-ChildItem $reportsfolder\PSRepository.xml)
                    $PSXML.ResultScript	| Out-UDTableData -Property  @("Name", "Type", "Author", "Description")
                    }

                }
    }
} -Title '    PowerShell Scripts'

New-UDCollapsibleItem -Id 'PSModule'-Content {
    New-UDLayout -Columns 1 -Content {
		    New-UDMuPaper -Content {
			    New-UDTable -Title "Module Details" -Headers @("Name", "Type", "Author","Description") -Endpoint {
				    $PSXML = Import-Clixml (Get-ChildItem $reportsfolder\PSRepository.xml)
                    $PSXML.ResultModule	| Out-UDTableData -Property  @("Name", "Type", "Author", "Description")
                    }

                }
    }
} -Title '    PowerShell Modules'

New-UDCollapsibleItem -Id 'process' -Content {
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
}
}

$PSRepository
