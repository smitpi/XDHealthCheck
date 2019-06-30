
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
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".json") })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.json"
	)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"

	Import-Module XDHealthCheck -Force
	Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath
	##########################################
	#region xml imports
	##########################################

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

