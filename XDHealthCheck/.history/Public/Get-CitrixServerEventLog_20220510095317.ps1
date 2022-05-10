
<#PSScriptInfo

.VERSION 1.0.13

.GUID 092feba0-b391-4f5a-a3db-41b191cc52fc

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT 

.TAGS Citrix

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [05/05/2019_08:59]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:25]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports
Updated [01/07/2020_14:43] Script Fle Info was updated
Updated [01/07/2020_15:42] Script Fle Info was updated
Updated [01/07/2020_16:07] Script Fle Info was updated
Updated [01/07/2020_16:13] Script Fle Info was updated
Updated [06/03/2021_20:58] Script Fle Info was updated
Updated [15/03/2021_23:28] Script Fle Info was updated

#> 




<#
.SYNOPSIS
Get windows event log details

.DESCRIPTION
Get windows event log details

.PARAMETER Serverlist
List of servers to query.

.PARAMETER Days
Limit the report to this time frame. 

.PARAMETER Export
Export the result to a report file. (Excel, html or Screen)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixServerEventLog -Serverlist $CTXCore -Days 1 

#>
Function Get-CitrixServerEventLog {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixServerEventLog')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string[]]$Serverlist,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int32]$Days,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	[System.Collections.ArrayList]$ServerEvents = @()
	foreach ($server in $Serverlist) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Eventlog Details"

		$eventtime = (Get-Date).AddDays(-$days)
		$ctxevent = Get-WinEvent -ComputerName $server -FilterHashtable @{LogName = 'Application', 'System'; Level = 2, 3; StartTime = $eventtime } -ErrorAction SilentlyContinue | Select-Object MachineName, TimeCreated, LogName, ProviderName, Id, LevelDisplayName, Message
		$servererrors = $ctxevent | Where-Object -Property LevelDisplayName -EQ 'Error'
		$serverWarning = $ctxevent | Where-Object -Property LevelDisplayName -EQ 'Warning'
		$TopProfider = $ctxevent | Where-Object { $_.LevelDisplayName -EQ 'Warning' -or $_.LevelDisplayName -eq 'Error' } | Group-Object -Property ProviderName | Sort-Object -Property count -Descending | Select-Object Name, Count

		[void]$ServerEvents.Add([pscustomobject]@{
				ServerName  = ([System.Net.Dns]::GetHostByName(($server))).hostname
				Errors      = $servererrors.Count
				Warning     = $serverWarning.Count
				TopProfider = $TopProfider
				All         = $ctxevent
			})
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Eventlog Details"
	}

	if ($Export -eq 'Excel') { 
		$ServerEvents.TopProfider | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixServerEventLog-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName TopProfider -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
		$ServerEvents.All | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixServerEventLog-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName All -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
	}
	if ($Export -eq 'HTML') { 
		New-HTML -TitleText "CitrixServerEventLog-$(Get-Date -Format yyyy.MM.dd-HH.mm)" -FilePath $HTMLPath {
                   $ServerEvents | ForEach-Object {
                   New-HTMLTab -name "$($_.ServerName)" -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {
                    New-HTMLText -FontSize 28 -FontStyle normal -Color '#00203F' -Alignment center -Text "$(($_.host).ToUpper())"
                    New-HTMLText -FontSize 28 -FontStyle normal -Color '#00203F' -Alignment center -Text "Events [$($_.events.count)]"
                    New-HTMLPanel -Content { New-HTMLTable -DataTable ($($_.events) | Sort-Object -Property TimeCreated -Descending) @TableSettings {
                            New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                            New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange } }

                }
                    }
                } -Online -Encoding UTF8 -ShowHTML



		$CTXObject | Out-HtmlView -DisablePaging -Title 'Mashine Failures' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixConfigurationChange-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
        
	}
	if ($Export -eq 'Host') { 
		$CTXObject
	}

} #end Function

