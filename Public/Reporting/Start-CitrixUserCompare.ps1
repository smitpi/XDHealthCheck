
<#PSScriptInfo

.VERSION 1.0.1

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

.PRIVATEDATA

#> 



<# 

.DESCRIPTION 
Reports on user details

#> 

Param()
Function Compare-TwoADUsers {
	PARAM($Username1,$Username2)

	$ValidUser1 = Get-ADUser $Username1 -Properties * | Select-Object Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
	$ValidUser2 = Get-ADUser $Username2 -Properties * | Select-Object Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
	$userDetailList1 = $ValidUser1.psobject.Properties | Select-Object -Property Name, Value
	$userDetailList2 = $ValidUser2.psobject.Properties | Select-Object -Property Name, Value

	$user1Headding = $ValidUser1.Name
	$user2Headding = $ValidUser2.Name
	$user1HeaddingMissing = $ValidUser1.Name + ' Missing'
	$user2HeaddingMissing = $ValidUser2.Name + ' Missing'

	$allusergroups1 = Get-ADUser $Username1 -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object { Get-ADGroup $_ } | Select-Object samaccountname
	$allusergroups2 = Get-ADUser $Username2 -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object { Get-ADGroup $_ } | Select-Object samaccountname

	$Compare = Compare-Object -ReferenceObject $allusergroups1 -DifferenceObject $allusergroups2 -Property samaccountname -IncludeEqual

	$SameGroups = $Compare | Where-Object { $_.SideIndicator -eq '==' } | Select-Object samaccountname
	$User1Missing = $Compare | Where-Object { $_.SideIndicator -eq '=>' } | Select-Object samaccountname
	$User2Missing = $Compare | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object samaccountname


	$User1Details = New-Object PSObject -Property @{
		ValidUser1           = $ValidUser1
		userDetailList1      = $userDetailList1
		user1Headding        = $user1Headding
		user1HeaddingMissing = $user1HeaddingMissing
		allusergroups1       = $allusergroups1
		User1Missing         = $User1Missing
	}
	$User2Details = New-Object PSObject -Property @{
		ValidUser2           = $ValidUser2
		userDetailList2      = $userDetailList2
		user2Headding        = $user2Headding
		user2HeaddingMissing = $user2HeaddingMissing
		allusergroups2       = $allusergroups2
		User2Missing         = $User2Missing
	}

	$Details = New-Object PSObject -Property @{
		User1Details = $User1Details
		User2Details = $User2Details
		SameGroups   = $SameGroups
	}
	$Details

} #end Function

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
	New-HTML -TitleText 'User Report' -ShowHTML -FilePath $Reportname {
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

	$timer.Stop()
	$timer.Elapsed | Select-Object Days,Hours,Minutes,Seconds | Format-List
	Stop-Transcript

} #end Function

