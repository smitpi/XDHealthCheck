
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
    ##########################################
	#region xml imports
	##########################################

	$XMLParameter = Import-Clixml $XMLParameterFilePath
	if ($null -eq $XMLParameter) { Write-Error "Valid Parameters file not found"; break }

 $ReportsFoldertmp = $XMLParameter.ReportsFolder.ToString()
	if ((Test-Path -Path $ReportsFoldertmp\logs) -eq $false) { New-Item -Path "$ReportsFoldertmp\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFoldertmp\logs\XDUserAccess_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();

	Write-Colour "Using Variables from Parameters.xml: ",$XMLParameterFilePath.ToString() -ShowTime -Color DarkCyan,DarkYellow -LinesAfter 1
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
	$XMLParameter.PSObject.Properties | Where-Object {$_.name -notlike 'TrustedDomains'} | ForEach-Object {Write-Color $_.name,":",$_.value  -Color Yellow,DarkCyan,Green -ShowTime;  New-Variable -Name $_.name -Value $_.value -Force -Scope local }

    Write-Colour "Creating credentials for Trusted domains:" -ShowTime -Color DarkCyan -LinesBefore 2
    $Trusteddomains = @()
    foreach ($domain in $XMLParameter.TrustedDomains) {
                 $serviceaccount = Find-Credential | Where-Object target -Like ("*" + $domain.Discription.tostring())  | Get-Credential -Store
	            if ($null -eq $serviceaccount) {
		            $serviceaccount = BetterCredentials\Get-Credential -Message ("Service Account for domain: " + $_.NetBiosName.ToString())
		            Set-Credential -Credential $serviceaccount -Target $_.Discription.ToString() -Persistence LocalComputer -Description ("Service Account for domain: " + $_.NetBiosName.ToString())}

                write-Color -Text $domain.FQDN,":",$serviceaccount.username  -Color Yellow,DarkCyan,Green -ShowTime
                $CusObject = New-Object PSObject -Property @{
			                            FQDN        = $domain.FQDN
                                        Credentials = $serviceaccount
		        }
	            $Trusteddomains += $CusObject
                }
    $CTXAdmin = Find-Credential | Where-Object target -Like "*Healthcheck" | Get-Credential -Store
	if ($null -eq $CTXAdmin) {
		$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
		Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
	}
    Write-Colour "Citrix Admin Credentials: ",$CTXAdmin.UserName -ShowTime -Color yellow,Green -LinesBefore 2

    #endregion

    ##########################################
	#region checking folders and report names
	##########################################
	if ((Test-Path -Path $ReportsFolder\XDUsers) -eq $false) { New-Item -Path "$ReportsFolder\XDUsers" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Reportname = $ReportsFolder + "\XDUsers\XDUserAccessReport_" + $Username + "_" + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"

	#endregion



	########################################
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"

	$UserDetail = Get-CitrixUserAccessDetail -Username $Username -AdminServer $CTXDDC
	$userDetailList = $UserDetail.UserDetail.psobject.Properties | Select-Object -Property Name, Value
	$DesktopsCombined = $UserDetail.DirectPublishedDesktops + $UserDetail.PublishedDesktops | Sort-Object -Property DesktopGroupName -Unique
	#endregion

	########################################
	#region Setting some table color and settings
	########################################
	$TableSettings = @{
		#Style          = 'stripe'
		Style          = 'cell-border'
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

