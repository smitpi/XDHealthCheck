
<#PSScriptInfo

.VERSION 1.0.0

.GUID 4f9acc8a-efce-42ba-866f-4bac75727a3e

.AUTHOR Pierre Smit

.COMPANYNAME  

.COPYRIGHT

.TAGS Other

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [06/06/2019_19:24] Initital Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Menu to install ctxhealthcheck 

#> 

Param()



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
	#Write-Color "4: ", "Create a scheduled task"  -Color Yellow, Green
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
			.\Modules\CTXHealthCheck\Private\Setup\Test-Parameters.ps1
			Start-Sleep 5
			Clear-Host
			Set-Location -Path $ScriptP 
            }
		'3' {Initialize-CitrixHealthCheck -XMLParameterFilePath $ParametersFolder\Parameters.xml -Verbose}
		
	}
}
until ($selection.ToLower() -eq 'q')

#endregion


