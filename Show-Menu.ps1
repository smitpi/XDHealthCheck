
<#PSScriptInfo

.VERSION 1.0.0

.GUID e1106401-8281-45d1-a9ae-5c6b98bffd45

.AUTHOR Pierre Smit

.COMPANYNAME EUV Team

.COPYRIGHT

.TAGS Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Date Created - 05/06/2019_19:16

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 a menu of options 

#> 
function CreateTask {
}
[string]$ScriptP = $PSScriptRoot
Set-Location -Path $ScriptP

#region 
Clear-Host
Write-Color -Text 'Make a selection from below' -Color DarkGray
Write-Color -Text '___________________________' -Color DarkGray -LinesAfter 1
do {
	Write-Color "1: ", "Set Healthcheck Script Parameters"  -Color Yellow, Green
	Write-Color "2: ", "Test HealthCheck Script Parameters"  -Color Yellow, Green
	Write-Color "3: ", "Run the first HealthCheck"  -Color Yellow, Green
	Write-Color "4: ", "Create a scheduled task"  -Color Yellow, Green
	Write-Color "Q: ", "Press 'Q' to quit."  -Color Yellow, DarkGray -LinesAfter 1

	$selection = Read-Host "Please make a selection"
	switch ($selection) {
		'1' {
			.\Modules\CTXHealthCheck\Private\Setup\Set-Parameters.ps1
			Start-Sleep 5
			Clear-Host
			Set-Location -Path $ScriptP 
  }
		'2' {
			.\Modules\CTXHealthCheck\Private\Setup\Test-Parameters.ps1; 
			Start-Sleep 5
			Clear-Host
			Set-Location -Path $ScriptP 
  }
		'3' {
			.\Modules\CTXHealthCheck\Private\Setup\Start-HealthCheck.ps1
			Start-Sleep 5
			Clear-Host
			Set-Location -Path $ScriptP 
  }
		'4' { }
		'5' { }
	}
}
until ($selection.ToLower() -eq 'q')

#endregion

<#
	#region 
	$anypromt = @(New-AnyBoxPrompt -Message "Choose Function" -Name Funtion -InputType Text -ValidateNotEmpty -ValidateSet 'Report On User Access', 'Report on All Apps', 'Compare two users', 'List Hosted Desktop Servers')
	$anybutton = @(New-AnyBoxButton -Text Okay -Name Okay -IsCancel -IsDefault -OnClick {
			if ($_.Funtion -eq 'Report On User Access') {
				$promt = @(New-AnyBoxPrompt -Message "Username" -Name Username -InputType Text)
				$UserAccess = Show-AnyBox @childWinParams -Title 'Compare Access Details' -Buttons 'Okay', 'Cancel' -CancelButton 'Cancel' -DefaultButton 'Okay' -Prompt $promt
				UserAccessReport -username $UserAccess.Username
			}
			if ($_.Funtion -eq 'Report on All Apps') { AllPublishedApps }

			if ($_.Funtion -eq 'Compare two users') {
				$promt = @(New-AnyBoxPrompt -Message "Username 1" -Name Username1 -InputType Text)
				$promt += @(New-AnyBoxPrompt -Message "Username 2" -Name Username2 -InputType Text)
				$CompareUsers = Show-AnyBox @childWinParams -Title 'Compare Access Details' -Buttons 'Okay', 'Cancel' -CancelButton 'Cancel' -DefaultButton 'Okay' -Prompt $promt
				CompareUsers -Username1 $CompareUsers.Username1 -Username2 $CompareUsers.Username2

			}
			if ($_.Funtion -eq 'List Hosted Desktop Servers') { GEtHostedDesktops }
		})
	$anybutton += @(New-AnyBoxButton -Text Close -Name Close -IsCancel)
	$userinput = Show-AnyBox -Icon 'Question' -Title "Choose Function" -WindowStyle ThreeDBorderWindow -Message "Please supply your credentials" -Buttons $anybutton -Prompt $anypromt
	#endregion
#>

