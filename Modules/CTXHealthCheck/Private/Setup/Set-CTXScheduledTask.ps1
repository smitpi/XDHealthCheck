
<#PSScriptInfo

.VERSION 1.0.0

.GUID fbf577f6-e517-4887-ae68-816c0372e7f9

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
Date Created - 05/06/2019_22:39

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Create Scheduled Task for healthcheck 

#> 

Param()



Function Set-CTXScheduledTask {
	
[string]$ScriptPath = $PSScriptRoot
Set-Location $ScriptPath
$script = Get-Item .\Start-HealthCheck.ps1 | select *
[string] $arg = "-NonInteractive -NoLogo -NoProfile -ExecutionPolicy Bypass -File " + '"' + ($script.FullName).ToString() + '"'
$Action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShellv1.0\powershell.exe' -Argument $arg  -WorkingDirectory $script.Directory.ToString()
$Trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 1 -At 05:00:00  

$Settings = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 10 -StartWhenAvailable
$Settings.ExecutionTimeLimit = "PT0S"

$CTXAdmin = Find-Credential | where target -Like "*Healthcheck" | Get-Credential -Store
	if ($CTXAdmin -eq $null) {
		$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
		Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
	}

$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $CTXAdmin.UserName,$CTXAdmin.Password
$Password = $Credentials.GetNetworkCredential().Password 

$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
$Task | Register-ScheduledTask -TaskName 'Citrix_HealthCheck' -User $CTXAdmin.UserName -Password $Password	


} #end Function

