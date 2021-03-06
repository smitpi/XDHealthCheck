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
}


Join-Path -Path ((Get-Module XDHealthCheck).ModuleBase).ToString() -ChildPath 'Public\Reporting\Start-XDMenu.ps1'

C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\full\path\PSScriptMenuGui_example\PSScriptMenuGui.ps1"
	
$detail = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File " + (Join-Path -Path ((Get-Module XDHealthCheck).ModuleBase).ToString() -ChildPath "Public\Reporting\Start-XDMenu.ps1") + '"'


New-Item -Path C:\Users\Public\Desktop -Name 'Run XDHealthCheck.bat' -ItemType File -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -Command "& {Import-Module XDHealthCheck -force;Start-XDMenu}"'


 -Command "& {Get-EventLog -LogName security}"