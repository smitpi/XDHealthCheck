
<#PSScriptInfo

.VERSION 1.0.3

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
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports

.PRIVATEDATA

#>







<#

.DESCRIPTION
User Access report
Requires -Modules BetterCredentials, PSWriteColor,ImportExcel,PSWriteHTML

#>

Param()



Function Initialize-CitrixUserAccessReport {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".xml") })]
		[string]$XMLParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.xml",
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$Username)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"
	<#

	Write-Colour "Using these Variables"
	[XML]$XMLParameter = Get-Content $XMLParameterFilePath
	if ($null -eq $XMLParameter) { Write-Color -Text "Valid Parameters file not found; break" }
	$XMLParameter.Settings.Variables.Variable | Format-Table

	$XMLParameter.Settings.Variables.Variable | ForEach-Object {
		# Set Variables contained in XML file
		$VarValue = $_.Value
		$CreateVariable = $True # Default value to create XML content as Variable
		switch ($_.Type) {
			# Format data types for each variable
			'[string]' { $VarValue = [string]$VarValue } # Fixed-length string of Unicode characters
			'[char]' { $VarValue = [char]$VarValue } # A Unicode 16-bit character
			'[byte]' { $VarValue = [byte]$VarValue } # An 8-bit unsigned character
			'[bool]' { If ($VarValue.ToLower() -eq 'false') { $VarValue = [bool]$False } ElseIf ($VarValue.ToLower() -eq 'true') { $VarValue = [bool]$True } } # An boolean True/False value
			'[int]' { $VarValue = [int]$VarValue } # 32-bit signed integer
			'[long]' { $VarValue = [long]$VarValue } # 64-bit signed integer
			'[decimal]' { $VarValue = [decimal]$VarValue } # A 128-bit decimal value
			'[single]' { $VarValue = [single]$VarValue } # Single-precision 32-bit floating point number
			'[double]' { $VarValue = [double]$VarValue } # Double-precision 64-bit floating point number
			'[DateTime]' { $VarValue = [DateTime]$VarValue } # Date and Time
			'[Array]' { $VarValue = [Array]$VarValue.Split(',') } # Array
		}
		If ($CreateVariable) { New-Variable -Name $_.Name -Value $VarValue -Scope $_.Scope -Force }
	}
 #>

	##########################################
	#region xml imports
	##########################################
	Write-Colour "Using these Variables"
	$XMLParameter = Import-Clixml $XMLParameterFilePath
	if ($null -eq $XMLParameter) { Write-Error "Valid Parameters file not found"; break }
	$XMLParameter
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
	$XMLParameter.PSObject.Properties | ForEach-Object { New-Variable -Name $_.name -Value $_.value -Force -Scope local }
	#endregion

	##########################################
	#region checking folders and report names
	##########################################
	if ((Test-Path -Path $ReportsFolder\XDUsers) -eq $false) { New-Item -Path "$ReportsFolder\XDUsers" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Reportname = $ReportsFolder + "\XDUsers\XDUserAccess." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"

	if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFolder\logs\XDUserAccess_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();
	#endregion

	########################################
	#region Getting Credentials
	#########################################
	$CTXAdmin = Find-Credential | Where-Object target -Like "*Healthcheck" | Get-Credential -Store
	if ($null -eq $CTXAdmin) {
		$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
		Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
	}
	#endregion

	########################################
	#region Connect and get info
	########################################
	$UserDetail = Get-CitrixUserAccessDetail -Username $Username -AdminServer $CTXDDC
	$userDetailList = $UserDetail.UserDetail.psobject.Properties | Select-Object -Property Name, Value
	$DesktopsCombined = $UserDetail.DirectPublishedDesktops + $UserDetail.PublishedDesktops | Sort-Object -Property DesktopGroupName -Unique
	#endregion

	########################################
	#region Setting some table color and settings
	########################################
	$TableSettings = @{
		Style          = 'stripe'
		HideFooter     = $true
		OrderMulti     = $true
		TextWhenNoData = 'No Data to display here'
	}

	$SectionSettings = @{
		HeaderBackGroundColor = 'white'
		HeaderTextAlignment   = 'center'
		HeaderTextColor       = 'red'
		BackgroundColor       = 'white'
		CanCollapse           = $true
	}

	$TableSectionSettings = @{
		HeaderTextColor       = 'white'
		HeaderTextAlignment   = 'center'
		HeaderBackGroundColor = 'red'
		BackgroundColor       = 'white'
	}
	#endregion

	#######################
	#region Building HTML the report
	#######################
	$HeddingText = $DashboardTitle + " | Access Report for User: " + $UserDetail.UserDetail.Name + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
	New-HTML -TitleText "Access Report" -FilePath $Reportname -ShowHTML {
		New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
		New-HTMLSection  @SectionSettings  -Content {
			New-HTMLSection -HeaderText 'User details' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $userDetailList }
			New-HTMLSection -HeaderText 'Current Applications' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $UserDetail.AccessPublishedApps }
			New-HTMLSection -HeaderText  'Current Desktops' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $DesktopsCombined }
		}
		New-HTMLSection  @SectionSettings  -Content {
			New-HTMLSection -HeaderText 'Requires Access to these Apps' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $UserDetail.NoAccessPublishedApps }
			New-HTMLSection -HeaderText 'AD Group Membership' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $UserDetail.AllUserGroups }
		}
	}
	#endregion
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending]Healthcheck Complete"

	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript

} #end Function

