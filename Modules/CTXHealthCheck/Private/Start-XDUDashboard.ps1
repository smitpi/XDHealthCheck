
<#PSScriptInfo

.VERSION 1.0.1

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

.PRIVATEDATA

#> 



<# 

.DESCRIPTION 
Universal Dashboard

#> 

Param()
Set-Location $PSScriptRoot
Import-Module CTXHealthCheck -Force -Verbose
[XML]$XMLParameter = Get-Content $env:PSParameters
#[XML]$XMLParameter = Get-Content \\corp.dsarena.com\za\group\120000_Euv\Personal\ABPS835-ADMIN\Powershell\Parameters.xml
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




$CTXFunctions = New-UDEndpointInitialization -Module @('CTXHealthCheck', 'PoshRSJob') -Variable @('ReportsFolder', 'ParametersFolder', 'CTXAdmin') -Function @('Get-FullUserDetail')
$Theme = Get-UDTheme -Name red

#region Page1
$CTXHomePage = New-UDPage -Name 'Health Check' -Icon home -DefaultHomePage -Content {
	New-UDFabButton -Id 'homerefresh' -ButtonColor green -Icon arrow_circle_o_up -Size Small -onClick {

		$job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath $env:PSParameters -Verbose }
		do {
			Show-UDModal -Content { New-UDHeading -Text "Refreshing your data" } -Persistent
			Start-Sleep -Seconds 10
			Hide-UDModal
		} until ($job.State -notlike 'Running')
	    $TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
        $YesterdayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html| Sort-Object -Property LastWriteTime -Descending)[1]) | select *
        $2daysReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *
    }
    	$TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
        $YesterdayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html| Sort-Object -Property LastWriteTime -Descending)[1]) | select *
        $2daysReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *

New-UDCollapsible -Items {
	New-UDCollapsibleItem -Icon arrow_circle_right -Content { New-UDHtml ([string](Get-Content $TodayReport.FullName)) } -Active -BackgroundColor lightgrey -FontColor black -Title '  Today''s Report'
	New-UDCollapsibleItem -Icon arrow_circle_right -Content { New-UDHtml ([string](Get-Content $YesterdayReport.FullName)) } -BackgroundColor lightgrey -FontColor black -Title '  Yesterday''s Report'
	New-UDCollapsibleItem -Icon arrow_circle_right -Content { New-UDHtml ([string](Get-Content $2daysReport.FullName)) } -BackgroundColor lightgrey -FontColor black -Title '  2 Days Ago''s Report'
}
}
#endregion

#region Page2
$Audit = New-UDPage -Name "Citrix Audit" -AutoRefresh -RefreshInterval 30 -Icon database -Content {
	New-UDFabButton -Id 'auditrefresh' -ButtonColor green -Icon arrow_circle_o_up -Size Small -onClick {
		$job = Start-RSJob -ScriptBlock { Initialize-CitrixAudit -XMLParameterFilePath $env:PSParameters -verbose}
		do {
			Show-UDModal -Content { New-UDHeading -Text "Refreshing your data" } -Persistent
			Start-Sleep -Seconds 10
			Hide-UDModal
		} until ($job.State -notlike 'Running')
	$TodayAudit = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *

	}

	$TodayAudit = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    
    New-UDCollapsible -Items {
	New-UDCollapsibleItem -Icon arrow_circle_right -Content { New-UDHtml ([string](Get-Content $TodayAudit.FullName)) } -Active -BackgroundColor lightgrey -FontColor black -Title '  Today''s Audit'
} 
}
#endregion

#region Page 3
$UserPage1 = New-UDPage -Name "User Details" -Icon user -Content {
New-UDCollapsible -Items {
	New-UDCollapsibleItem -Icon arrow_circle_right -Endpoint {
        New-UDInput -Title "AD Details" -Endpoint {
	    param(
		    [Parameter(Mandatory)]
		    [UniversalDashboard.ValidationErrorMessage("Invalid user")]
		    [ValidateScript( { Get-ADUser -Identity $_ })]
		    [string]$Username)

	    New-UDInputAction -Content @(
	    $validuser = Get-FullUserDetail -UserToQuery $username -DomainFQDN htpcza.com -DomainCredentials $CTXAdmin
	    $UserDetail = ConvertTo-FormatListView -Data $validuser.UserSummery

	    New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
	    New-UDLayout -Columns 2 -Content {
		    New-UDGrid -Id 'UserGrid1'  -Headers @("Name", "Value") -Properties @("Name", "Value") -NoPaging -Endpoint { $UserDetail | Out-UDGridData }
	        New-UDGrid -Id 'UserGrid2' -Headers @("SamAccountName", "GroupScope") -Properties @("SamAccountName", "GroupScope") -NoPaging -Endpoint { $validuser.AllUserGroups | select SamAccountName, GroupScope | Out-UDGridData }
}

)
	    }
	} -Title "Single user Details"

    New-UDCollapsibleItem -Icon arrow_circle_right -Endpoint {
	New-UDInput -Title "Compare Users" -Content {
		New-UDInputField -Name 'Username1' -Type textbox -Placeholder 'Username1'
		New-UDInputField -Name 'Username2' -Type textbox -Placeholder 'Username2'
	    } -Endpoint {
		    param([string]$Username1, $Username2)
            
            $job = Start-RSJob -ScriptBlock { Initialize-CitrixUserReports -XMLParameterFilePath "$ParametersFolder\Parameters.xml" -Username1 $Username1 -Username2 $Username2 }
            $UserCompare = Get-Item ((Get-ChildItem $ReportsFolder\XDUsers\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *    
		    do {
			    Show-UDModal -Content { New-UDHeading -Text "Calculating" } -Persistent
			    Start-Sleep -Seconds 10
			    Hide-UDModal
		    } until ($job.State -notlike 'Running')


            New-UDInputAction -Content  @(New-UDHtml ([string](Get-Content $UserCompare.FullName)))
            }
        
        
     } -Title "Compare Two Users"
}
}
#endregion

#region Page 4
$DynamicUserPage = New-UDPage -Url "/dynamic/:Username" -Icon user_o -Endpoint {
	param($Username)


}
#endregion
#region Page 5
$DynamicUserPage2 = New-UDPage -Url "/compare/:Username1/:$username2" -Icon user_o -Endpoint {
param($Username1,$Username2)

		$job = Start-RSJob -ScriptBlock { Initialize-CitrixUserReports -XMLParameterFilePath "$ParametersFolder\Parameters.xml" -Username1 $Username1 -Username2 $Username2 }
		do {
			Show-UDModal -Content { New-UDHeading -Text "Calculating" } -Persistent
			Start-Sleep -Seconds 10
			Hide-UDModal
		} until ($job.State -notlike 'Running')

		$UserCompare = Get-Item ((Get-ChildItem $ReportsFolder\XDUsers\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *    
		New-UDCollapsible -Items {
		New-UDCollapsibleItem -Icon arrow_circle_right -Content { New-UDHtml ([string](Get-Content $UserCompare.FullName)) } -Active -BackgroundColor lightgrey -FontColor black
        }
}
#endregion



Get-UDDashboard | Stop-UDDashboard

$Dashboard = New-UDDashboard -Title "XenDektop Universal Dashboard" -Pages @($CTXHomePage, $Audit, $UserPage1, $DynamicUserPage,$DynamicUserPage2) -EndpointInitialization $CTXFunctions -Theme $Theme

Start-UDDashboard -Dashboard $Dashboard -Port 10005
Start-Process http://localhost:10005

<#
 #



New-UDInput -Title "Module Info Locator" -Endpoint {
    param($ModuleName) 

    # Get a module from the gallery
    $Module = Find-Module $ModuleName

    # Output a new card based on that info
    New-UDInputAction -Content @(
        New-UDCard -Title "$ModuleName - $($Module.Version)" -Text $Module.Description
    )
}



 New-UDInput -Title "Simple Form" -Id "Form" -Content {
    New-UDInputField -Type 'textbox' -Name 'Email' -Placeholder 'Email Address'
    New-UDInputField -Type 'checkbox' -Name 'Newsletter' -Placeholder 'Sign up for newsletter'
    New-UDInputField -Type 'select' -Name 'FavoriteLanguage' -Placeholder 'Favorite Programming Language' -Values @("PowerShell", "Python", "C#")
    New-UDInputField -Type 'radioButtons' -Name 'FavoriteEditor' -Placeholder @("Visual Studio", "Visual Studio Code", "Notepad") -Values @("VS", "VSC", "NP")
    New-UDInputField -Type 'password' -Name 'password' -Placeholder 'Password'
    New-UDInputField -Type 'textarea' -Name 'notes' -Placeholder 'Additional Notes'
} -Endpoint {
    param($Email, $Newsletter, $FavoriteLanguage, $FavoriteEditor, $password, $notes)
}


 


#New-UDGridLayout -Content {
#    New-UDCard -Title "Card 1" -Id 'Card1' 
#    New-UDCard -Title "Card 2" -Id 'Card2'
#    New-UDCard -Title "Card 3" -Id 'Card3'





$CompareUsers = New-UDPage -Name 'ADUser' -Icon user -Title 'Compare users' -Content {
	New-UDInput -Title "User Details" -Endpoint {
		param @($user1, $user2)
		New-UDInputField -Type 'textbox' -Name 'user1' -Placeholder 'Username1'
		New-UDInputField -Type 'textbox' -Name 'user2' -Placeholder 'Username2'
		New-UDInputAction -RedirectUrl 	"/dynamic/$User1" }
}

$DynamicUserPage = New-UDPage -Url "/dynamic/:User1" -Icon address_book -Endpoint {
		param @($user1, $user2)
}
#>