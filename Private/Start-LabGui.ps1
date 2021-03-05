#region Setup
Set-Location C:\Utils\LabScripts\Private
Remove-Module PSScriptMenuGui -ErrorAction SilentlyContinue
try {
	Import-Module PSScriptMenuGui -ErrorAction Stop
} catch {
	Write-Warning $_
	Write-Verbose 'Attempting to import from parent directory...' -Verbose
	Import-Module '..\'
}
#endregion

$params = @{
	csvPath               = '.\LabMenu.csv'
	windowTitle           = 'IT Shared Scripts v1.1'
	buttonForegroundColor = 'Azure'
	buttonBackgroundColor = '#eb4034'
	hideConsole           = $true
	noExit                = $true
	Verbose               = $true
}
Show-ScriptMenuGui @params