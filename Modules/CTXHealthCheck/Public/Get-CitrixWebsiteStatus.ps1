
<#PSScriptInfo

.VERSION 1.0.2

.GUID eeec293e-564f-4b3e-a252-74b1e96493df

.AUTHOR Pierre Smit

.COMPANYNAME Absa Corp:EUV Team

.COPYRIGHT

.TAGS EUV Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Date Created - 05/05/2019_09:00
Date Updated - 13/05/2019_04:40
Date Updated - 22/05/2019_20:13

.PRIVATEDATA

#> 





<# 

.DESCRIPTION 
Xendesktop Farm Details

#> 

Param()



Function Get-CitrixWebsiteStatus {
    PARAM(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [array]$Websitelist)

$websites = @()
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Website Details"  

foreach ($web in $Websitelist) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $WebResponse = Invoke-WebRequest -UseBasicParsing $web | Select-Object -Property StatusCode, StatusDescription

    $CTXObject = New-Object PSObject -Property @{
    "WebSite Name"           = $web
    StatusCode               = $WebResponse.StatusCode
    StatusDescription        = $WebResponse.StatusDescription
    }
    $websites += $CTXObject
}
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending] Website Details"  

$websites |select  "WebSite Name" ,StatusCode,StatusDescription



} #end Function

