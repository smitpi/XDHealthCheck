#region Setup
Set-Location C:\Utils\LabScripts\Private\XDHealthCheck\Private
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
	csvPath               = '.\FunctionsMenu.csv'
	windowTitle           = 'XD HealthCheck'
	buttonForegroundColor = 'Azure'
	buttonBackgroundColor = '#eb4034'
	hideConsole           = $true
	noExit                = $true
	Verbose               = $false
}
Show-ScriptMenuGui @params