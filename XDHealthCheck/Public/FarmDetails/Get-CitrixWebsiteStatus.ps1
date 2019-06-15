
<#PSScriptInfo

.VERSION 1.0.6

.GUID eeec293e-564f-4b3e-a252-74b1e96493df

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
Created [05/05/2019_09:00]
Updated [13/05/2019_04:40]
Updated [22/05/2019_20:13]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:25]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11] 

.PRIVATEDATA

#> 













<#

.DESCRIPTION 
Xendesktop Farm Details

#>

Param()



Function Get-CitrixWebsiteStatus {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[array]$Websitelist)

	$websites = @()
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Website Details"

	foreach ($web in $Websitelist) {
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		$WebResponse = Invoke-WebRequest -Uri $web -UseBasicParsing | Select-Object -Property StatusCode, StatusDescription

		$CTXObject = New-Object PSObject -Property @{
			"WebSite Name"    = $web
			StatusCode        = $WebResponse.StatusCode
			StatusDescription = $WebResponse.StatusDescription
		}
		$websites += $CTXObject
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Website Details"

	$websites | Select-Object  "WebSite Name" , StatusCode, StatusDescription



} #end Function

