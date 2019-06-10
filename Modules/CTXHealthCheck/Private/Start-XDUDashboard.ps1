
<#PSScriptInfo

.VERSION 1.0.2

.GUID 144e3fd9-5999-4364-bdd6-99e1a6451adf

.AUTHOR Pierre Smit

.COMPANYNAME  

.COPYRIGHT

.TAGS Powershell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [06/06/2019_04:01]
Updated [06/06/2019_19:25]
Updated [09/06/2019_09:18] 

.PRIVATEDATA

#> 





<# 

.DESCRIPTION 
Universal Dashboard

#> 

Param()
Set-Location $PSScriptRoot

[XML]$XMLParameter = Get-Content $CTXParameters
$XMLParameter.Settings.Variables.Variable | ft
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"

$XMLParameter.Settings.Variables.Variable | foreach {
	# Set Variables contained in XML file
	$VarValue = $_.Value
	$CreateVariable = $True # Default value to create XML content as Variable
	switch ($_.Type) {
		# Format data types for each variable
		'[string]' { $VarValue = [string]$VarValue } # Fixed-length string of Unicode characters
		'[char]' { $VarValue = [char]$VarValue } # A Unicode 16-bit character
		'[byte]' { $VarValue = [byte]$VarValue } # An 8-bit unsigned character
		'[bool]' { If ($VarValue.ToLower() -eq 'false') { $VarValue = [bool]$False } ElseIf ($VarValue.ToLower() -eq 'true') { $VarValue = [bool]$True } } # An boolean True/False value
		'[int]' { $VarValue = [int]$VarValue } # 32-bit signed integer
		'[long]' { $VarValue = [long]$VarValue } # 64-bit signed integer
		'[decimal]' { $VarValue = [decimal]$VarValue } # A 128-bit decimal value
		'[single]' { $VarValue = [single]$VarValue } # Single-precision 32-bit floating point number
		'[double]' { $VarValue = [double]$VarValue } # Double-precision 64-bit floating point number
		'[DateTime]' { $VarValue = [DateTime]$VarValue } # Date and Time
		'[Array]' { $VarValue = [Array]$VarValue.Split(',') } # Array
		'[Command]' { $VarValue = Invoke-Expression $VarValue; $CreateVariable = $False } # Command
	}
	If ($CreateVariable) { New-Variable -Name $_.Name -Value $VarValue -Scope $_.Scope -Force }
}

$CTXAdmin = Find-Credential | where target -Like "*Healthcheck" | Get-Credential -Store
if ($CTXAdmin -eq $null) {
	$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
	Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}

########################################
## build pages
#########################################

$CTXFunctions = New-UDEndpointInitialization -Module @("CTXHealthCheck", "PoshRSJob") -Variable @("ReportsFolder", "ParametersFolder", "CTXAdmin", "PSParameters") -Function @("Get-FullUserDetail", "Initialize-CitrixAudit", "Initialize-CitrixHealthCheck")
$Theme = Get-UDTheme -Name Default 

#region Page1
$CTXHomePage = New-UDPage -Name "Health Check" -Icon home -DefaultHomePage -Content {
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {         		
        $job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($CTXParameters)
		do {
            Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white'} -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal		   
}   until( $job.State -notlike 'Running')
    $TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    $2DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[1]) | select *
    $3DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *

    Sync-UDElement -Id 'Healcheck1'
    Sync-UDElement -Id 'Healcheck2'
    Sync-UDElement -Id 'Healcheck3'

} # onclick
New-UDCollapsible -Items {
    New-UDCollapsibleItem -Title 'Latest Health Check Report'-Content {
    New-UDCard -Id 'Healcheck1' -BackgroundColor grey -Endpoint {
	param ($TodayReport)
    $TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	New-UDHtml ([string](Get-Content $TodayReport.FullName))}
} -Active -BackgroundColor grey
} -BackgroundColor grey

New-UDCollapsible -Items {
    New-UDCollapsibleItem -Title 'Second Last Health Check Report'-Content {
    New-UDCard -Id 'Healcheck2' -BackgroundColor grey -Endpoint {
	param ($2DAYSReport)
    $2DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[1]) | select *
	New-UDHtml ([string](Get-Content $2DAYSReport.FullName))}
} -Active -BackgroundColor grey
} -BackgroundColor grey

New-UDCollapsible -Items {
    New-UDCollapsibleItem -Title 'Latest Health Check Report'-Content {
    New-UDCard -Id 'Healcheck3' -BackgroundColor grey -Endpoint {
	param ($3DAYSReport)
    $3DAYSReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *
	New-UDHtml ([string](Get-Content $3DAYSReport.FullName))}
} -Active -BackgroundColor grey
} -BackgroundColor grey
}
#endregion

#region Page2
$CTXAuditPage = New-UDPage -Name "Audit Results" -Icon bomb -Content {
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {         		
        $job = Start-RSJob -ScriptBlock { Initialize-CitrixAudit -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($CTXParameters)
		do {
            Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white'} -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal		   
}   until( $job.State -notlike 'Running')
    $AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    Sync-UDElement -Id 'Audit1'
} # onclick
New-UDCollapsible -Items {
    New-UDCollapsibleItem -Title 'Latest Health Check Report'-Content {
    New-UDCard -Id 'Audit1' -Endpoint {
	param ($AuditReport)
    $AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	New-UDHtml ([string](Get-Content $AuditReport.FullName))
}
}
}
}
#endregion

#region Page 3
$UserPage1 = New-UDPage -Name "User Details" -Icon user -Content {
	New-UDCollapsible -Items {
		New-UDCollapsibleItem  -Endpoint {
			New-UDInput -Title "Username" -Endpoint {
				param(
					[Parameter(Mandatory)]
					[UniversalDashboard.ValidationErrorMessage("Invalid user")]
					[ValidateScript( { Get-ADUser -Identity $_ })]
					[string]$Username)

				New-UDInputAction -Content @(
	    $validuser = Get-FullUserDetail -UserToQuery $username  -DomainCredentials $CTXAdmin
	    $UserDetail = ConvertTo-FormatListView -Data $validuser.UserSummery

	    New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
	    New-UDLayout -Columns 2 -Content {
		    New-UDGrid -Id 'UserGrid1'  -Headers @("Name", "Value") -Properties @("Name", "Value") -NoPaging -Endpoint { $UserDetail | Out-UDGridData }
					New-UDGrid -Id 'UserGrid2' -Headers @("SamAccountName", "GroupScope") -Properties @("SamAccountName", "GroupScope") -NoPaging -Endpoint { $validuser.AllUserGroups | select SamAccountName, GroupScope | Out-UDGridData }
			}

		)
	}
} -Title "Single user Details" -FontColor black

New-UDCollapsibleItem -Endpoint {
	New-UDInput -Title "Compare Users" -Content {
		New-UDInputField -Name 'Username1' -Type textbox -Placeholder 'Username1'
		New-UDInputField -Name 'Username2' -Type textbox -Placeholder 'Username2'
	} -Endpoint {
		param(
			[Parameter(Mandatory)]
			[UniversalDashboard.ValidationErrorMessage("Invalid user")]
			[ValidateScript( { Get-ADUser -Identity $_ })]
			[string]$Username1,
			[Parameter(Mandatory)]
			[UniversalDashboard.ValidationErrorMessage("Invalid user")]
			[ValidateScript( { Get-ADUser -Identity $_ })]
			[string]$Username2)


            
		New-UDInputAction -Toast $Username1
		New-UDInputAction -Toast $Username2

		$compareUsers = Compare-TwoADUsers -Username1 $Username1 -Username2 $Username2 -Verbose

		New-UDInputAction -Content  @(
			New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
			New-UDLayout -Columns 2 -Content {
				New-UDGrid -Title $compareusers.User1Details.user1Headding -Endpoint { $compareusers.User1Details.userDetailList1 | Out-UDGridData }
			New-UDGrid -Title $compareusers.User2Details.user2Headding -Endpoint { $compareusers.User2Details.userDetailList2 | Out-UDGridData }
	}
	New-UDLayout -Columns 3 -Content {
		New-UDGrid -Title $compareusers.User1Details.user1HeaddingMissing -Endpoint { $compareusers.User1Details.User1Missing | Out-UDGridData }
	    New-UDGrid -Title $compareusers.User2Details.user2HeaddingMissing -Endpoint { $compareusers.User2Details.User2Missing | Out-UDGridData }
        New-UDGrid -Title 'Same Groups' -Endpoint { $compareusers.SameGroups | Out-UDGridData }
    }
    New-UDLayout -Columns 2 -Content {
	    New-UDGrid -Title $compareusers.User1Details.user1Headding -Endpoint { $compareusers.User1Details.allusergroups1 | Out-UDGridData }
    New-UDGrid -Title $compareusers.User2Details.user2Headding -Endpoint { $compareusers.User2Details.allusergroups2 | Out-UDGridData }
}
)


}
        
} -Title "Compare Two Users" -FontColor black

New-UDCollapsibleItem  -Endpoint {
	New-UDInput -Title "Username" -Endpoint {
		param(
			[Parameter(Mandatory)]
			[UniversalDashboard.ValidationErrorMessage("Invalid user")]
			[ValidateScript( { Get-ADUser -Identity $_ })]
			[string]$Username)

		New-UDInputAction -Content @(
			$UserDetail = Get-CitrixUserAccessDetails -Username $Username -AdminServer $CTXDDC -Verbose
			$userDetailList = $UserDetail.UserDetail.psobject.Properties | Select-Object -Property Name, Value
		$DesktopsCombined = $UserDetail.DirectPublishedDesktops + $UserDetail.PublishedDesktops | sort -Property DesktopGroupName -Unique
	New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
	New-UDLayout -Columns 4 -Content {
		New-UDGrid -Title 'User details' -Endpoint { $userDetailList | Out-UDGridData }
	New-UDGrid -Title 'Current Applications' -Endpoint { ($UserDetail.AccessPublishedApps | select PublishedName, Description, enabled) | Out-UDGridData }
New-UDGrid -Title 'Current Desktops' -Endpoint { $DesktopsCombined | Out-UDGridData }
New-UDGrid -Title 'Available Applications' -Endpoint { ($UserDetail.NoAccessPublishedApps | select PublishedName, Description, enabled) | Out-UDGridData }
}
)




}
} 	 -Title "Check User Access In Citrix" -FontColor black
}
}
#endregion

########################################
## Build dashboard
#########################################

Get-UDDashboard | Stop-UDDashboard

$Dashboard = New-UDDashboard -Title "XenDektop Universal Dashboard" -Pages @($CTXHomePage,$CTXAuditPage, $UserPage1) -EndpointInitialization $CTXFunctions -Theme $Theme

Start-UDDashboard -Dashboard $Dashboard -Port 10007
Start-Process http://localhost:10007

