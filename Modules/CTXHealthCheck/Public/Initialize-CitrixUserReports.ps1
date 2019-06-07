
<#PSScriptInfo

.VERSION 1.0.0

.GUID 310be7d5-f671-4eaa-8011-8552cdcfc75c

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
Date Created - 07/06/2019_04:05

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Reports on user details 

#> 

Param()



Function Initialize-CitrixUserReports {
    PARAM(
        [Parameter(Mandatory = $true, Position = 0)]
		[ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".xml")})]
        [string]$XMLParameterFilePath,
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Username1,
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Username2)


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
Import-Module ..\CTXHealthCheck.psm1 -Force -Verbose
if ((Test-Path -Path $ReportsFolder\XDUsers) -eq $false) { New-Item -Path "$ReportsFolder\XDUsers" -ItemType Directory -Force -ErrorAction SilentlyContinue }

[string]$Reportname = $ReportsFolder + "\XDUsers\XD_Users." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"

if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
[string]$Transcriptlog ="$ReportsFolder\logs\XDUsers_TransmissionLogs." + (get-date -Format yyyy.MM.dd-HH.mm) + ".log"
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
Function Compare-TwoADUsers {
    PARAM($Username1,$Username2)

$ValidUser1 = Get-ADUser $Username1  -Properties * | select Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
$ValidUser2 = Get-ADUser $Username2  -Properties * | select Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
$userDetailList1 = $ValidUser1.psobject.Properties | Select-Object -Property Name, Value
$userDetailList2 = $ValidUser2.psobject.Properties | Select-Object -Property Name, Value

$user1Headding = $ValidUser1.Name
$user2Headding = $ValidUser2.Name
$user1HeaddingMissing = $ValidUser1.Name + " Missing"
$user2HeaddingMissing = $ValidUser2.Name + " Missing"

$allusergroups1 = Get-ADUser $Username1 -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object {Get-ADGroup $_} | select samaccountname
$allusergroups2 = Get-ADUser $Username2 -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object {Get-ADGroup $_} | select samaccountname

$Compare = Compare-Object -ReferenceObject $allusergroups1 -DifferenceObject $allusergroups2 -Property samaccountname -IncludeEqual

$SameGroups = $Compare | where {$_.SideIndicator -eq '=='} | select samaccountname
$User1Missing = $Compare | where {$_.SideIndicator -eq '=>'} | select samaccountname
$User2Missing = $Compare | where {$_.SideIndicator -eq '<='} | select samaccountname


$User1Details = New-Object PSObject  -Property @{
        ValidUser1               = $ValidUser1
        userDetailList1          = $userDetailList1
        user1Headding            = $user1Headding
        user1HeaddingMissing     = $user1HeaddingMissing
        allusergroups1           = $allusergroups1
        User1Missing             = $User1Missing
        }
$User2Details = New-Object PSObject  -Property @{
        ValidUser2               = $ValidUser2
        userDetailList2          = $userDetailList2
        user2Headding            = $user2Headding
        user2HeaddingMissing     = $user2HeaddingMissing
        allusergroups2           = $allusergroups2
        User2Missing             = $User2Missing
        }

$Details = New-Object PSObject  -Property @{
User1Details = $User1Details
User2Details = $User2Details
SameGroups = $SameGroups
}
$Details

} #end Function

########################################
## Connect and get info
#########################################
$compareusers = Compare-TwoADUsers -Username1 $Username1 -Username2 $Username2 -Verbose


########################################
## Setting some table color and settings
########################################

$TableSettings = @{
    Style                  = 'cell-border'
    DisablePaging          = $true
    DisableOrdering        = $true
    DisableInfo            = $true
    DisableProcessing      = $true
    DisableResponsiveTable = $true
    DisableNewLine         = $true
    DisableSelect          = $true
    DisableSearch          = $true
    DisableColumnReorder   = $true
    OrderMulti             = $true
    DisableStateSave       = $true
    TextWhenNoData         = 'No Data to display here'
}
$SectionSettings = @{
    HeaderBackGroundColor = 'DarkGray'
    HeaderTextAlignment   = 'center'
    HeaderTextColor       = 'White'
    BackgroundColor       = 'LightGrey'
    CanCollapse           = $false
}

$TableSectionSettings = @{
    HeaderTextColor       = 'Black'
    HeaderTextAlignment   = 'center'
    HeaderBackGroundColor = 'LightSteelBlue'
    BackgroundColor       = 'WhiteSmoke'
}

#######################
## Building the report
#######################

$HeddingText = "Compared Users on: " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
New-HTML -TitleText "XenDesktop Report"  -FilePath $Reportname {
    New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
    New-HTMLSection -HeaderText 'User Details' @SectionSettings  -Content {
        New-HTMLSection -HeaderText $compareusers.User1Details.user1Headding @TableSectionSettings {New-HTMLTable @TableSettings -DataTable $compareusers.User1Details.userDetailList1 -HideFooter}
        New-HTMLSection -HeaderText $compareusers.User2Details.user2Headding @TableSectionSettings {New-HTMLTable @TableSettings -DataTable $compareusers.User2Details.userDetailList2 -HideFooter}
    }
    New-HTMLSection @SectionSettings -HeaderText 'Comparison of the User Groups'   -Content {
        New-HTMLSection -HeaderText $compareusers.User1Details.user1HeaddingMissing @TableSectionSettings {New-HTMLTable @TableSettings -DataTable $compareusers.User1Details.User1Missing -HideFooter}
        New-HTMLSection -HeaderText $compareusers.User1Details.user2HeaddingMissing @TableSectionSettings {New-HTMLTable @TableSettings -DataTable $compareusers.User2Details.User2Missing -HideFooter}
        New-HTMLSection -HeaderText 'Same Groups' @TableSectionSettings {New-HTMLTable @TableSettings -DataTable $compareusers.SameGroups -HideFooter}
    }
    New-HTMLSection @SectionSettings -HeaderText 'All User Groups'   -Content {
        New-HTMLSection -HeaderText $compareusers.User1Details.user1Headding @TableSectionSettings {New-HTMLTable @TableSettings -DataTable $compareusers.User1Details.allusergroups1  -HideFooter}
        New-HTMLSection -HeaderText  $compareusers.User2Details.user2Headding @TableSectionSettings {New-HTMLTable @TableSettings -DataTable $compareusers.User2Details.allusergroups2 -HideFooter}
    }
}

$timer.Stop()
$timer.Elapsed | select Days,Hours,Minutes,Seconds | fl
Stop-Transcript

} #end Function

