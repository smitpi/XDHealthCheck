
<#PSScriptInfo

.VERSION 1.0.4

.GUID ce76995e-894d-40ee-ac4a-f700cd9abd01

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
Created [20/04/2021_12:17] Initital Script Creating
Updated [22/04/2021_11:42] Script Fle Info was updated
Updated [23/04/2021_19:03] Reports on progress
Updated [24/04/2021_07:21] added more api calls
Updated [05/05/2021_14:33] 'Update Manifest'

.PRIVATEDATA

#> 

#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
Get monitoring data

#> 

Param()


Function Get-CTXONP_MonitorData {
	PARAM(
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory = $true, Position = 0)]
		[string]$DDC, 
		[ValidateNotNullOrEmpty()]
		[Parameter(Mandatory = $true, Position = 1)]
		[int]$hours
	)

	$now = Get-Date -Format yyyy-MM-ddTHH:mm:ss.ffffZ
	$past = ((Get-Date).AddHours(-$hours)).ToString('yyyy-MM-ddTHH:mm:ss.ffffZ')


	[pscustomobject]@{
		ApplicationActivitySummaries = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/ApplicationActivitySummaries?$filter=(Granularity eq 60 and ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		ApplicationInstances         = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/ApplicationInstances?$filter=(ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		Applications                 = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/Applications')			).value
		Catalogs                     = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/Catalogs')).value
		ConnectionFailureLogs        = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/ConnectionFailureLogs?$filter=(ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		Connections                  = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/Connections?$apply=filter(ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		DesktopGroups                = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/DesktopGroups')).value
		DesktopOSDesktopSummaries    = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/DesktopOSDesktopSummaries?$filter=(Granularity eq 60 and ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		FailureLogSummaries          = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/FailureLogSummaries?$filter=(ModifiedDate ge ' + $past + ' )')).value
		Hypervisors                  = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/Hypervisors')).value
		LogOnSummaries               = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/LogOnSummaries?$filter=(ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		MachineFailureLogs           = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/MachineFailureLogs?$filter=(ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		MachineMetric                = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/MachineMetric?$filter=(CollectedDate ge ' + $past + ' and CollectedDate le ' + $now + ' )')).value
		Machines                     = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/Machines')).value
		ServerOSDesktopSummaries     = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/ServerOSDesktopSummaries?$filter=(Granularity eq 60 and ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		SessionActivitySummaries     = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/SessionActivitySummaries?$filter=(Granularity eq 60 and ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		SessionAutoReconnects        = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/SessionAutoReconnects?$filter=(CreatedDate ge ' + $past + ' and CreatedDate le ' + $now + ' )')).value
		Session                      = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/Sessions?$apply=filter(ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		Users                        = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/Users')).value
		#LoadIndexes                  = (Invoke-RestMethod   -UseDefaultCredentials -URI ('http://'+$ddc+'/Citrix/Monitor/OData/v4/Data/LoadIndexes?$filter=(ModifiedDate ge ' + $past + ' )')).value
		#LoadIndexSummaries           = (Invoke-RestMethod   -UseDefaultCredentials -URI ('http://'+$ddc+'/Citrix/Monitor/OData/v4/Data/LoadIndexSummaries?$filter=(ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		LogOnMetrics                 = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/LogOnMetrics?$filter=(UserInitStartDate ge ' + $past + ' and UserInitStartDate le ' + $now + ' )')).value
		#Processes                    = (Invoke-RestMethod   -UseDefaultCredentials -URI ('http://'+$ddc+'/Citrix/Monitor/OData/v4/Data/Processes?$filter=(ProcessCreationDate ge ' + $past + ' and ProcessCreationDate le ' + $now + ' )')).value
		#ProcessUtilization           = (Invoke-RestMethod   -UseDefaultCredentials -URI ('http://'+$ddc+'/Citrix/Monitor/OData/v4/Data/ProcessUtilization?$filter=(CollectedDate ge ' + $past + ' and CollectedDate le ' + $now + ' )')).value
		ResourceUtilizationSummary   = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/ResourceUtilizationSummary?$filter=(ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		ResourceUtilization          = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/ResourceUtilization?$filter=(ModifiedDate ge ' + $past + ' and ModifiedDate le ' + $now + ' )')).value
		SessionMetrics               = (Invoke-RestMethod -UseDefaultCredentials -Uri ('http://' + $ddc + '/Citrix/Monitor/OData/v4/Data/SessionMetrics?$apply=filter(CollectedDate ge ' + $past + ' and CollectedDate le ' + $now + ' )')).value
	}

} #end Function
