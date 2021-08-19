
<#PSScriptInfo

.VERSION 1.0.0

.GUID 1e30c885-bb07-4cb5-b380-55f5c1a92fee

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT

.TAGS Windows

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [14/02/2021_07:51] Initital Script Creating

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Lab scripts 

#> 

Param()


Function Install-BasePSModules {
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$ModuleList = (Join-Path -Path ((Get-Module XDHealthCheck).ModuleBase).ToString() -ChildPath Private\modulelist.json),
		[switch]$ForceInstall = $false,
        [switch]$UpdateModules = $false,
        [switch]$RemoveAll = $false
	)

	$mods = Get-Content $ModuleList | ConvertFrom-Json
    if ($RemoveAll) {
			try {
			$mods | ForEach-Object {Write-Host 'Uninstalling Module:' -ForegroundColor Cyan -NoNewline;Write-Host $_.Name -ForegroundColor red
                                    Get-Module -Name $_.Name -ListAvailable | Uninstall-Module -AllVersions -Force
                                   }
			} catch {write-error "Error Uninstalling $($mod.Name)"}
		}
    if ($UpdateModules) {
			try {
			$mods | ForEach-Object {Write-Host 'Updating Module:' -ForegroundColor Cyan -NoNewline;Write-Host $_.Name -ForegroundColor yello
                                    Get-Module -Name $_.Name -ListAvailable  | Select-Object -First 1 | update-Module -Force
                                   }
			} catch {write-error "Error Updating $($mod.Name)"}
		}

	foreach ($mod in $mods) {
		if ($ForceInstall -eq $false) { $PSModule = Get-Module -Name $mod.Name -ListAvailable | Select-Object -First 1 }
		if ($PSModule.Name -like '') { 
			Write-Host 'Installing Module:' -ForegroundColor Cyan -NoNewline
			Write-Host $mod.Name -ForegroundColor Yellow
			Install-Module -Name $mod.Name -Scope AllUsers -AllowClobber -Force 
		} else {
			Write-Host 'Using Installed Module:' -ForegroundColor Cyan -NoNewline
			Write-Host $PSModule.Name - $PSModule.Path -ForegroundColor Yellow
		}
	}
}