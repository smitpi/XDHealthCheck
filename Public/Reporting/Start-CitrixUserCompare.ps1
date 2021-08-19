
<#PSScriptInfo

.VERSION 1.0.3

.GUID 310be7d5-f671-4eaa-8011-8552cdcfc75c

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

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
Updated [06/03/2021_20:58] Script Fle Info was updated
Updated [15/03/2021_23:28] Script Fle Info was updated

#> 







<# 

.DESCRIPTION 
Reports on user details

#> 

Param()
Function Start-CitrixUserCompare {
	PARAM(
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username1,
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username2)


	[string]$Reportname = $env:TEMP + '\XD_Users.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html'

	########################################
	## Connect and get info
	#########################################
	$compareusers = Compare-TwoADUsers -Username1 $Username1 -Username2 $Username2 -Verbose


	########################################
	## Setting some table color and settings
	########################################

	$TableSettings = @{
		Style                  = 'cell-border'
		DisablePaging          = $true
		DisableOrdering        = $true
		DisableInfo            = $true
		DisableProcessing      = $true
		DisableResponsiveTable = $true
		DisableNewLine         = $true
		DisableSelect          = $true
		DisableSearch          = $true
		OrderMulti             = $true
		DisableStateSave       = $true
		TextWhenNoData         = 'No Data to display here'
	}
	$SectionSettings = @{
		HeaderBackGroundColor = 'DarkGray'
		HeaderTextAlignment   = 'center'
		HeaderTextColor       = 'White'
		BackgroundColor       = 'LightGrey'
		CanCollapse           = $false
	}

	$TableSectionSettings = @{
		HeaderTextColor       = 'Black'
		HeaderTextAlignment   = 'center'
		HeaderBackGroundColor = 'LightSteelBlue'
		BackgroundColor       = 'WhiteSmoke'
	}

	#######################
	## Building the report
	#######################

	$HeddingText = 'Compared Users on: ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)
	New-HTML -TitleText 'User Report' -FilePath $Reportname {
		New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
		New-HTMLSection -HeaderText 'User Details' @SectionSettings -Content {
			New-HTMLSection -HeaderText $compareusers.User1Details.user1Headding @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User1Details.userDetailList1 -HideFooter }
			New-HTMLSection -HeaderText $compareusers.User2Details.user2Headding @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User2Details.userDetailList2 -HideFooter }
		}
		New-HTMLSection @SectionSettings -HeaderText 'Comparison of the User Groups' -Content {
			New-HTMLSection -HeaderText $compareusers.User1Details.user1HeaddingMissing @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User1Details.User1Missing -HideFooter }
			New-HTMLSection -HeaderText $compareusers.User1Details.user2HeaddingMissing @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User2Details.User2Missing -HideFooter }
			New-HTMLSection -HeaderText 'Same Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.SameGroups -HideFooter }
		}
		New-HTMLSection @SectionSettings -HeaderText 'All User Groups' -Content {
			New-HTMLSection -HeaderText $compareusers.User1Details.user1Headding @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User1Details.allusergroups1 -HideFooter }
			New-HTMLSection -HeaderText $compareusers.User2Details.user2Headding @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $compareusers.User2Details.allusergroups2 -HideFooter }
		}
	}
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

    $browser = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice' -name 'Progid'
    $browserexec = ((Get-ItemPropertyValue -Path "HKCR:\$browser\shell\open\command" -Name "(Default)").split("-")[0]).replace('"','')
    Start-Process -FilePath "$browserexec" -ArgumentList "--app=$Reportname"
} #end Function

