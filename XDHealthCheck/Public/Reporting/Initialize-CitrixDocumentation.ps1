
<#PSScriptInfo

.VERSION 1.0.0

.GUID 47d68ff9-c844-434a-b14f-a26ef10abe57

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
Created [24/06/2019_10:19] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Create farm documentation

#>

Param()



Function Initialize-CitrixDocumentation {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".xml") })]
		[string]$XMLParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.xml"
	)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"

	##########################################
	#region xml imports
	##########################################

	$XMLParameter = Import-Clixml $XMLParameterFilePath
	if ($null -eq $XMLParameter) { Write-Error "Valid Parameters file not found"; break }

	$ReportsFoldertmp = $XMLParameter.ReportsFolder.ToString()
	if ((Test-Path -Path $ReportsFoldertmp\logs) -eq $false) { New-Item -Path "$ReportsFoldertmp\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFoldertmp\logs\XDDocumentation_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();

	Write-Colour "Using Variables from Parameters.xml: ", $XMLParameterFilePath.ToString() -ShowTime -Color DarkCyan, DarkYellow -LinesAfter 1
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
	$XMLParameter.PSObject.Properties | Where-Object { $_.name -notlike 'TrustedDomains' } | ForEach-Object { Write-Color $_.name, ":", $_.value  -Color Yellow, DarkCyan, Green -ShowTime; New-Variable -Name $_.name -Value $_.value -Force -Scope local }

	Write-Colour "Creating credentials for Trusted domains:" -ShowTime -Color DarkCyan -LinesBefore 2
	$Trusteddomains = @()
	foreach ($domain in $XMLParameter.TrustedDomains) {
		$serviceaccount = Find-Credential | Where-Object target -Like ("*" + $domain.Discription.tostring()) | Get-Credential -Store
		if ($null -eq $serviceaccount) {
			$serviceaccount = BetterCredentials\Get-Credential -Message ("Service Account for domain: " + $domain.NetBiosName.ToString())
			Set-Credential -Credential $serviceaccount -Target $domain.Discription.ToString() -Persistence LocalComputer -Description ("Service Account for domain: " + $domain.NetBiosName.ToString())
		}
		Write-Color -Text $domain.FQDN, ":", $serviceaccount.username  -Color Yellow, DarkCyan, Green -ShowTime
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
	Write-Colour "Citrix Admin Credentials: ", $CTXAdmin.UserName -ShowTime -Color yellow, Green -LinesBefore 2

	#endregion
	##########################################
	#region checking folders and report names
	##########################################
	$CTXSite = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerSite -AdminAddress $AdminServer } | ForEach-Object { ("Citrix_Farm_" + $_.Name + "_" + $_.DefaultMinimumFunctionalLevel + "_") }
	[string]$WordReportname = $ReportsFolder + "\" + $CTXSite + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".docx"
	#endregion

	##########################################
	#region Do the report
	##########################################
    try {
		$progressbar = New-ProgressBar -MaterialDesign -Type Circle -IsIndeterminate $true -PrimaryColor BlueGrey -Size Medium -Theme Light
		$docjob = Start-RSJob -ScriptBlock { Get-CitrixFarmDocumentation -DeliveryController $CTXDDC -Path $WordReportname -Protocol HTTP -Credential $CTXAdmin -Verbose } -FunctionFilesToImport (Join-Path ((Get-Item .).Parent).Parent 'XDHealthCheck.psm1') -ModulesToImport 'XDHealthCheck' -FunctionsToImport 'Get-CitrixFarmDocumentation' -VariablesToImport @('CTXAdmin', 'WordReportname', 'CTXDDC')
		while ($docjob.State -eq 'Running') {
			Write-ProgressBar -ProgressBar $progressbar -Activity $docjob.Progress[-1].Activity.ToString()  -Status $docjob.Progress[-1].StatusDescription.ToString() -CurrentOperation $docjob.Progress[-1].CurrentOperation -PercentComplete $docjob.Progress[-1].PercentComplete -SecondsRemaining $docjob.Progress[-1].SecondsRemaining

		}
		Close-ProgressBar $progressbar
	}
    catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        write-error "Failed -- $FailedItem -- $ErrorMessage"
    }
    #endregion

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending]Healthcheck Complete"

	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript

} #end Function

