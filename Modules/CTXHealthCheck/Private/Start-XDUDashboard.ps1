
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
[XML]$XMLParameter = Get-Content $env:PSParameters
$XMLParameter.Settings.Variables.Variable | ft
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Variable Details"

$XMLParameter.Settings.Variables.Variable | foreach {
		# Set Variables contained in XML file
		$VarValue = $_.Value
		$CreateVariable = $True # Default value to create XML content as Variable
		switch ($_.Type) {
			# Format data types for each variable
			'[string]' { $VarValue = [string]$VarValue } # Fixed-length string of Unicode characters
			'[char]' { $VarValue = [char]$VarValue } # A Unicode 16-bit character
			'[byte]' { $VarValue = [byte]$VarValue } # An 8-bit unsigned character
            '[bool]' { If ($VarValue.ToLower() -eq 'false'){$VarValue = [bool]$False} ElseIf ($VarValue.ToLower() -eq 'true'){$VarValue = [bool]$True} } # An boolean True/False value
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





$CTXFunctions = New-UDEndpointInitialization -Module @('CTXHealthCheck','PoshRSJob') -Variable @('ReportsFolder','ParametersFolder')
$Theme = Get-UDTheme -Name red


$CTXHomePage = New-UDPage -Name 'CTXHealthCheck' -Title 'Citrix Health Check' -DefaultHomePage -Icon home -Content{

	New-UDButton -Floating -Icon refresh  -BackgroundColor green -FontColor black -OnClick{
	#$job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath $env:PSParameters -Verbose }
	do {
	 	Show-UDModal -Content { New-UDHeading -Text "Refreshing your data" } -Persistent
	 	Start-Sleep -Seconds 4
	 	Hide-UDModal
	} until ($job.State -notlike 'Running')
	}

    $TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    $YesterdayReport = Get-Item ((Get-ChildItem $ReportsFolder\*.html | Sort-Object -Property LastWriteTime -Descending)[1]) | select *
    $2daysReport = Get-Item ((Get-ChildItem $ReportsFolder\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *

    New-UDCollapsible -Items {
    New-UDCollapsibleItem -Icon arrow_circle_right -Content {New-UDHtml ([string](Get-Content $TodayReport.FullName))} -Active -BackgroundColor lightgrey -FontColor black -Title '  Today''s Report'
    New-UDCollapsibleItem -Icon arrow_circle_right -Content {New-UDHtml ([string](Get-Content $YesterdayReport.FullName))} -BackgroundColor lightgrey -FontColor black -Title '  Yesterday''s Report'
    New-UDCollapsibleItem -Icon arrow_circle_right -Content {New-UDHtml ([string](Get-Content $2daysReport.FullName))} -BackgroundColor lightgrey -FontColor black -Title '  2 Days Ago''s Report'
    }
}

$Audit = New-UDPage -Name "CTXAudit" -Title 'Citrix Audit' -Icon bitcoin  -Content {
    $TodayAudit = Get-Item ((Get-ChildItem $ReportsFolder\audit\XD_*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    
    New-UDCollapsible -Items {
    New-UDCollapsibleItem -Icon arrow_circle_right -Content {New-UDHtml ([string](Get-Content $TodayAudit.FullName))} -Active -BackgroundColor lightgrey -FontColor black -Title '  Today''s Audit'
    } 
}

$CompareUsers = New-UDPage -Name 'ADUser' -Icon user -Title 'Compare users' -Content {
	New-UDInput -Title "User Details" -Endpoint {
	param @($user1,$user2)
		New-UDInputField -Type 'textbox' -Name 'user1' -Placeholder 'Username1'
		New-UDInputField -Type 'textbox' -Name 'user2' -Placeholder 'Username2'
	$CitrixUserReports = Initialize-CitrixUserReports -XMLParameterFilePath $ParametersFolder\parameter.xml -Username1 $user1 -Username2 $user2
    New-UDInputAction -Content @($lastusercompare = Get-Item ((Get-ChildItem $ReportsFolder\audit\User_*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
		New-UDCollapsible -Items {
		New-UDCollapsibleItem -Icon arrow_circle_right -Content { New-UDHtml ([string](Get-Content $lastusercompare.FullName)) } -Active -BackgroundColor lightgrey -FontColor black -Title '  Compare User AD Groups' 
		})
	}


}
Get-UDDashboard | Stop-UDDashboard

$Dashboard  = New-UDDashboard -Title "XenDektop Universal Dashboard" -Pages @($CTXHomePage,$Audit,$CompareUsers) -EndpointInitialization $CTXFunctions -Theme $Theme

Start-UDDashboard -Dashboard $Dashboard -Port 10002
Start-Process http://localhost:10002




<#
 # 


#New-UDGridLayout -Content {
#    New-UDCard -Title "Card 1" -Id 'Card1' 
#    New-UDCard -Title "Card 2" -Id 'Card2'
#    New-UDCard -Title "Card 3" -Id 'Card3'



#>
