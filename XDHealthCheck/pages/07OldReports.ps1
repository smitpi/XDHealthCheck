$XDAuditPagelive = New-UDPage -Name "Historical Reports" -Icon history -Content {
New-UDCollapsible -Items {
#region Health Checks
	New-UDCollapsibleItem -BackgroundColor '#E5E5E5'  -Endpoint {
		Show-UDModal -Content { New-UDHeading -Text "Loading"  -Color 'white' } -Persistent -BackgroundColor green
		[System.Collections.ArrayList]$reports = @()
		Get-ChildItem $ReportsFolder\XDHealth\*.html | Select-Object * | Sort-Object -Property LastWriteTime -Descending | ForEach-Object {
			$ReportDate = Get-Date -Day $_.name.Split("-")[0].split(".")[3] -Month $_.name.Split("-")[0].split(".")[2] -Year $_.name.Split("-")[0].split(".")[1] -Hour $_.name.Split("-")[1].split(".")[0] -Minute $_.name.Split("-")[1].split(".")[1]
			$reports += [PSCustomObject]@{
				Date     = ($ReportDate).ToLongDateString() + " " + ($ReportDate).ToLongTimeString()
				Filename = $_.fullname
			}
		}

		$Reports.Insert(0,[PSCustomObject]@{
				Date     = "Select a Date"
				Filename = "Select a File"
			})
		Hide-UDModal
		New-UDInput -Content {
			New-UDInputField -Name 'HealthReports' -Values @($reports.Date) -Type select -Placeholder 'Report Date'
		} -Endpoint { param($HealthReports)
			$showreport = $reports | Where-Object { $_.date -like $HealthReports }
			New-UDInputAction -Toast $showreport.date.tostring()
			New-UDInputAction -Content @(
				New-UDCard -Content { New-UDHtml ([string](Get-Content $showreport.FileName)) }
			) }


	} -Title 'XenDesktop Health Check'
#endregion
#region Audit Results
	New-UDCollapsibleItem -BackgroundColor '#E5E5E5'  -Endpoint {
		Show-UDModal -Content { New-UDHeading -Text "Loading"  -Color 'white' } -Persistent -BackgroundColor green
		[System.Collections.ArrayList]$reports = @()
		Get-ChildItem $ReportsFolder\XDAudit\*.html | Select-Object * | Sort-Object -Property LastWriteTime -Descending | ForEach-Object {
			$ReportDate = Get-Date -Day $_.name.Split("-")[0].split(".")[3] -Month $_.name.Split("-")[0].split(".")[2] -Year $_.name.Split("-")[0].split(".")[1] -Hour $_.name.Split("-")[1].split(".")[0] -Minute $_.name.Split("-")[1].split(".")[1]
			$reports += [PSCustomObject]@{
				Date     = ($ReportDate).ToLongDateString() + " " + ($ReportDate).ToLongTimeString()
				Filename = $_.fullname
			}
		}
		$Reports.Insert(0,[PSCustomObject]@{
				Date     = "Select a Date"
				Filename = "Select a File"
			})
		Hide-UDModal
		New-UDInput -Content {
			New-UDInputField -Name 'HealthReports' -Values @($reports.Date) -Type select -Placeholder 'Report Date'
		} -Endpoint { param($HealthReports)
			$showreport = $reports | Where-Object { $_.date -like $HealthReports }
			New-UDInputAction -Toast $showreport.date.tostring()
			New-UDInputAction -Content @(
				New-UDCard -Content { New-UDHtml ([string](Get-Content $showreport.FileName)) }
			) }
	} -Title 'XenDesktop Audit Results'
}
#endregion
}
$XDAuditPagelive
