
<#PSScriptInfo

.VERSION 1.0.1

.GUID 4ea395a2-cac4-4d05-b184-4d9bf20c80bf

.AUTHOR Pierre Smit

.COMPANYNAME  

.COPYRIGHT

.TAGS Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [08/06/2019_11:18]
Updated [09/06/2019_09:18] 

.PRIVATEDATA

#> 



<# 

.DESCRIPTION 
User Access report
Requires -Modules BetterCredentials, PSWriteColor,ImportExcel,PSWriteHTML
#> 

Param()



Function Initialize-CitrixUserAccessReport {
    PARAM(
        [Parameter(Mandatory = $true, Position = 0)]
		[ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".xml")})]
        [string]$XMLParameterFilePath,
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Username)


Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"

Write-Colour "Using these Variables"
[XML]$XMLParameter = Get-Content $XMLParameterFilePath
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

Set-Location $PSScriptRoot
if ((Test-Path -Path $ReportsFolder\XDUsers) -eq $false) { New-Item -Path "$ReportsFolder\XDUsers" -ItemType Directory -Force -ErrorAction SilentlyContinue }

[string]$Reportname = $ReportsFolder + "\XDUsers\XD_UsersAccess." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"

if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
[string]$Transcriptlog ="$ReportsFolder\logs\XDUserAccess_TransmissionLogs." + (get-date -Format yyyy.MM.dd-HH.mm) + ".log"
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
$timer = [Diagnostics.Stopwatch]::StartNew();


########################################
## Getting Credentials
#########################################


$CTXAdmin = Find-Credential | where target -Like "*Healthcheck" | Get-Credential -Store
if ($CTXAdmin -eq $null) {
    $AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
    Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}
########################################
## Functions
#########################################

########################################
## Connect and get info
#########################################


$UserDetail = Get-CitrixUserAccessDetails -Username $Username -AdminServer $CTXDDC -Verbose
$userDetailList = $UserDetail.UserDetail.psobject.Properties | Select-Object -Property Name, Value
$DesktopsCombined = $UserDetail.DirectPublishedDesktops + $UserDetail.PublishedDesktops | sort -Property DesktopGroupName -Unique

$HeddingText = "Access Report for User:" + $UserDetail.UserDetail.Name + " on " + (get-date -Format dd) + " " + (get-date -Format MMMM) + "," + (get-date -Format yyyy) + " " + (Get-Date -Format HH:mm)
$HTMLReport = New-HTML -TitleText "Access Report" -FilePath  $PSScriptRoot\Dashboard01.html -ShowHTML {
New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
New-HTMLSection -HeaderBackGroundColor DarkGray -Content {
    New-HTMLSection -HeaderText 'User details' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $userDetailList -HideFooter}
    New-HTMLSection -HeaderText 'Current Applications' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable ($UserDetail.AccessPublishedApps | Select PublishedName,Description,enabled) -HideFooter}
    New-HTMLSection -HeaderText 'Current Desktops' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable ($DesktopsCombined) -HideFooter}
}
New-HTMLSection -HeaderBackGroundColor DarkGray -Content {
    New-HTMLSection -HeaderText 'No Access Apps' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable ($UserDetail.NoAccessPublishedApps  | Select PublishedName,Description,enabled)  -HideFooter}
    New-HTMLSection -HeaderText 'All User Groups' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $UserDetail.AllUserGroups -HideFooter}
    }
}

} #end Function

