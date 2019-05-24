
<#PSScriptInfo

.VERSION 1.0.3

.GUID 7a62533c-d105-4718-9440-00957643908f

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA

.COPYRIGHT

.TAGS Citrix

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
Date Updated - 24/05/2019_19:24

.PRIVATEDATA

#> 







<# 

.DESCRIPTION 
Xendesktop Farm Details

#> 

Param()



Function Get-CitrixLicenseInformation {
                    PARAM(
                    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
                    [ValidateNotNull()]
                    [ValidateNotNullOrEmpty()]
                    [string]$AdminServer,
                    [Parameter(Mandatory = $true, Position = 1)]
                    [ValidateNotNull()]
                    [ValidateNotNullOrEmpty()]
                    [PSCredential]$RemoteCredentials,
                    [Parameter(Mandatory = $false, Position = 2)]
                    [switch]$RunAsPSRemote = $false)


function get-license {
    param($AdminServer,$VerbosePreference)
    Add-PSSnapin Citrix*
    Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] License Details"  

    $LicenseServer = Get-BrokerSite -AdminAddress $AdminServer | select LicenseServerName
    [string]$licurl = "https://" + $LicenseServer.LicenseServerName + ":8083"
    $cert = Get-LicCertificate -AdminAddress $licurl
    Get-LicInventory -AdminAddress $licurl -CertHash $cert.CertHash | where { $_.LicensesInUse -ne 0 } | Select-Object LocalizedLicenseProductName, LicensesInUse, LicensesAvailable
    Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [End] License Details"  

}

$LicDetails = @()
if ($RunAsPSRemote -eq $true) {$LicDetails = Invoke-Command -ComputerName $AdminServer -ScriptBlock ${Function:get-license} -ArgumentList @($AdminServer,$VerbosePreference) -Credential $RemoteCredentials | select LocalizedLicenseProductName,LicensesInUse,LicensesAvailable }
else { $LicDetails = get-license -AdminAddress $AdminServer }
$LicDetails


} #end Function

