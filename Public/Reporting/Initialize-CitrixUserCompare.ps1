
<#PSScriptInfo

.VERSION 1.0.3

.GUID 310be7d5-f671-4eaa-8011-8552cdcfc75c

.AUTHOR Pierre Smit

.COMPANYNAME

.COPYRIGHT

.TAGS Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [07/06/2019_04:05]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports

.PRIVATEDATA

#>







<#

.DESCRIPTION
Reports on user details

#>

Param()
Function Initialize-CitrixUserCompare {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".json") })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.json",
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username1,
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username2)


	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"
	##########################################
	#region xml imports
	##########################################
	Import-Module XDHealthCheck -Force
	Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath
	#endregion

	##########################################
	#region checking folders and report names
	##########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
	if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFolder\logs\XDUser_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();

	if ((Test-Path -Path $ReportsFolder\XDUsers) -eq $false) { New-Item -Path "$ReportsFolder\XDUsers" -ItemType Directory -Force -ErrorAction SilentlyContinue }

	if ([bool]$RemoveOldReports) {
		$oldReports = (Get-Date).AddDays(-$RemoveOldReports)
		Get-ChildItem $ReportsFolder\XDUsers *.html | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDUsers *.xlsx | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\logs\XDCompareUsers_TransmissionLogs* | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
	}
	[string]$Reportname = $ReportsFolder + "\XDUsers\XDCompare_" + $Username1 + "_" + $Username2 + "_" + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"

	#endregion


	########################################
	#region Connect and get info
	########################################
	$compareusers = Compare-ADUser -Username1 $Username1 -Username2 $Username2
	#endregion

	########################################
	#region Setting some table color and settings
	########################################

	$TableSettings = @{
		#Style          = 'stripe'
		Style          = 'cell-border'
		HideFooter     = $true
		OrderMulti     = $true
		TextWhenNoData = 'No Data to display here'
	}

	$SectionSettings = @{
		BackgroundColor       = 'white'
		CanCollapse           = $true
		HeaderBackGroundColor = 'white'
		HeaderTextAlignment   = 'center'
		HeaderTextColor       = $HeaderColor
	}

	$TableSectionSettings = @{
		BackgroundColor       = 'white'
		HeaderBackGroundColor = $HeaderColor
		HeaderTextAlignment   = 'center'
		HeaderTextColor       = 'white'
	}
	#endregion

	#######################
	#region Building HTML the report
	#######################
	$HeddingText = $DashboardTitle + " | XenDesktop Report | " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
	New-HTML -TitleText "Compared Users Report"  -FilePath $Reportname -ShowHTML {
		New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
		New-HTMLSection -HeaderText 'User Details' @SectionSettings  -Content {
			New-HTMLSection -HeaderText $compareusers.User1Details.user1Headding @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User1Details.userDetailList1 }
			New-HTMLSection -HeaderText $compareusers.User2Details.user2Headding @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User2Details.userDetailList2 }
		}
		New-HTMLSection @SectionSettings -HeaderText 'Comparison of the User Groups'   -Content {
			New-HTMLSection -HeaderText $compareusers.User1Details.user1HeaddingMissing @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User1Details.User1Missing }
			New-HTMLSection -HeaderText $compareusers.User1Details.user2HeaddingMissing @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User2Details.User2Missing }
			New-HTMLSection -HeaderText 'Same Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.SameGroups }
		}
		New-HTMLSection @SectionSettings -HeaderText 'All User Groups'   -Content {
			New-HTMLSection -HeaderText $compareusers.User1Details.user1Headding @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User1Details.allusergroups1 }
			New-HTMLSection -HeaderText  $compareusers.User2Details.user2Headding @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User2Details.allusergroups2 }
		}
	}
	#endregion
	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript

} #end Function

