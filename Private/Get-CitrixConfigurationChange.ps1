
<#PSScriptInfo

.VERSION 1.0.13

.GUID 71b2bc51-85ce-407b-ace5-96df009782d3

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT 

.TAGS Citrix

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [05/05/2019_09:00]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:24]
Updated [06/06/2019_19:25]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports
Updated [01/07/2020_14:43] Script Fle Info was updated
Updated [01/07/2020_15:42] Script Fle Info was updated
Updated [01/07/2020_16:07] Script Fle Info was updated
Updated [01/07/2020_16:13] Script Fle Info was updated
Updated [06/03/2021_20:58] Script Fle Info was updated
Updated [15/03/2021_23:28] Script Fle Info was updated

#> 














<#

.DESCRIPTION 
Function for Citrix XenDesktop HTML Health Check Report

#>

Param()
Function Get-CitrixConfigurationChange {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int32]$Indays,
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[PSCredential]$RemoteCredentials)

	Invoke-Command -ComputerName $AdminServer -ScriptBlock {
		param($AdminServer, $Indays, $VerbosePreference)
		Add-PSSnapin citrix* -ErrorAction SilentlyContinue
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Config Changes Details"

		$startdate = (Get-Date).AddDays(-$Indays)
		$exportpath = (Get-Item (Get-Item Env:\TEMP).value).FullName + "\ctxreportlog.csv"

		if (Test-Path $exportpath) { Remove-Item $exportpath -Force -ErrorAction SilentlyContinue }
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Progress] Exporting Changes"

		Export-LogReportCsv -OutputFile $exportpath -StartDateRange $startdate -EndDateRange (Get-Date)
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Progress] Importing Changes"

		$LogExportAll = Import-Csv -Path $exportpath -Delimiter ","
		$LogExport = $LogExportAll | Where-Object { $_.'High Level Operation Text' -notlike "" } | Select-Object -Property High*
		$LogSum = $LogExportAll | Group-Object -Property 'High Level Operation Text' -NoElement

		Remove-Item $exportpath -Force -ErrorAction SilentlyContinue
		$CTXObject = New-Object PSObject -Property @{
			DateCollected = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			AllDetails    = $LogExportAll
			Filtered      = $LogExport
			Summary       = $LogSum
		}
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Config Changes Details"

		$CTXObject

	} -ArgumentList @($AdminServer, $Indays, $VerbosePreference) -Credential $RemoteCredentials

} #end Function

