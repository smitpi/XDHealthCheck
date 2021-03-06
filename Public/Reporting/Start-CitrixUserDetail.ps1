
<#PSScriptInfo

.VERSION 1.0.2

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

#> 





<# 

.DESCRIPTION 
Reports on user details

#> 

Param()
Function Start-CitrixUserDetail {
	PARAM(
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username)


	[string]$Reportname = $env:TEMP + '\XD_User.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html'

	########################################
	## Connect and get info
	#########################################
	$UserDetail = Get-FullADUserDetail -UserToQuery $Username


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

	$HeddingText = 'Reported on: ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)
	New-HTML -TitleText 'User Detail' -FilePath $Reportname {
		New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText $UserDetail.UserSummery.UserPrincipalName @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($UserDetail.UserSummery.psobject.Properties | Select-Object -Property Name, Value) -HideFooter }
			New-HTMLSection -HeaderText 'Group Membership' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($UserDetail.AllUserGroups | Select-Object SamAccountName) -HideFooter }
		}
		New-HTMLSection @SectionSettings -HeaderText 'All User Detail' -Content {
			New-HTMLSection -HeaderText $UserDetail.UserSummery.UserPrincipalName -CanCollapse -Collapsed @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($UserDetail.AllUserDetails.psobject.Properties | Select-Object -Property Name, Value) -HideFooter }
		}
	}
		Start-Process -FilePath 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' -ArgumentList "--app=$Reportname"


} #end Function

