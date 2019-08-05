
<#PSScriptInfo

.VERSION 1.0.0

.GUID 764f7c68-a312-4f57-9ef6-ccfac63eb2a4

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
Created [28/06/2019_20:38] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Use Carl Webster's Script to create Site documentation

#>

Param()



Function Start-CitrixDocumentation  {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".json") })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.json"
		)


	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"
	##########################################
	#region xml imports
	##########################################
	Import-Module XDHealthCheck -Force
	Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath
	#endregion

	##########################################
	#region checking folders and report names
	##########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
	if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFolder\logs\XDDocs_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();

	if ((Test-Path -Path $ReportsFolder\XDDocs) -eq $false) { New-Item -Path "$ReportsFolder\XDDocs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	if ([bool]$RemoveOldReports) {
		$oldReports = (Get-Date).AddDays(-$RemoveOldReports)
		Get-ChildItem $ReportsFolder\XDDocs * | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\logs\XDUserAccess_TransmissionLogs* | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
	}

	[string]$WordReportname = $ReportsFolder + "\XDDocs\XD_Farm." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".docx"
	[string]$HTMLReportname = $ReportsFolder + "\XDDocs\XD_Farm." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".HTML"
	#endregion
	##########################################
	#region checking folders and report names
	##########################################
	 #Get-CitrixFarmDocumentation -DeliveryController $CTXDDC -Path $WordReportname -Protocol HTTP -Credential $CTXAdmin -Verbose
	 #Get-CitrixFarmDocumentation -DeliveryController $CTXDDC -Path $HTMLReportname -Protocol HTTP -Credential $CTXAdmin -Verbose
	#Get-CitrixDocumentationV2 -MSWord -AddDateTime -AdminAddress $CTXDDC  -CSV -Folder "$ReportsFolder\XDDocs" -Verbose

	Get-CitrixFarmDocumentationV2 -MSWord -AddDateTime -AdminAddress $CTXDDC -CSV -Folder "$ReportsFolder\XDDocs" -ScriptInfo
	Get-CitrixNetscalerDocumentation -MSWord -AddDateTime -NSIP $CTXNS[0].NSIP -Credential $NSAdmin -Folder "$ReportsFolder\XDDocs" -ScriptInfo


	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript

} #end Function

