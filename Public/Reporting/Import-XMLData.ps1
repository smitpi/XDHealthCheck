
<#PSScriptInfo

.VERSION 1.0.0

.GUID 1c1fdc9b-eb42-4051-8ebe-6826ff7b7cc8

.AUTHOR Pierre Smit

.COMPANYNAME

.COPYRIGHT

.TAGS Other

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [15/08/2019_11:54] Initital Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Import XML Data

#>

Param()



Function Import-XMLData {
	[PSCustomObject]@{
		CORPCheckXML        = Import-Clixml (Get-ChildItem $ReportsFolder\XDHealth\XD_Healthcheck*.xml | Sort-Object LastWriteTime -Descending)[0]
		HealthCheckXMLFarm1 = Import-Clixml (Get-ChildItem $ReportsFolder\IntranetF1\Reports\XDHealth\XD_Healthcheck*.xml | Sort-Object LastWriteTime -Descending)[0]
		HealthCheckXMLFarm2 = Import-Clixml (Get-ChildItem $ReportsFolder\IntranetF2\Reports\XDHealth\XD_Healthcheck*.xml | Sort-Object LastWriteTime -Descending)[0]
	}

} #end Function

