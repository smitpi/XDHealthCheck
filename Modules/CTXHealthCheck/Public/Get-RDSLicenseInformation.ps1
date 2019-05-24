
<#PSScriptInfo

.VERSION 1.0.5

.GUID 284fb68d-acc2-4b5f-aa04-3d0fb6fbcdc0

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
Date Created - 05/05/2019_09:01
Date Updated - 13/05/2019_04:37
Date Updated - 13/05/2019_04:38
Date Updated - 13/05/2019_04:40
Date Updated - 22/05/2019_20:13
Date Updated - 24/05/2019_19:25

.PRIVATEDATA

#> 











<# 

.DESCRIPTION 
Xendesktop Farm Details

#> 

Param()



Function Get-RDSLicenseInformation {
                    PARAM(
                        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
                        [ValidateNotNull()]
                        [ValidateNotNullOrEmpty()]
                        [string]$LicenseServer,
                        [Parameter(Mandatory = $true, Position = 1)]
                        [ValidateNotNull()]
                        [ValidateNotNullOrEmpty()]
                        [PSCredential]$RemoteCredentials)

Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] RDS Details"  
$RDSLicense = Get-WmiObject Win32_TSLicenseKeyPack -ComputerName $LicenseServer -Credential $RemoteCredentials -ErrorAction SilentlyContinue | where { $_.ProductVersion -eq "Windows Server 2016"} | Select-Object -Property TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses
$CTXObject = New-Object PSObject -Property @{
    "Per Device"             = $RDSLicense | where {$_.TypeAndModel -eq "RDS Per Device CAL"}
    "Per User"               = $RDSLicense | where {$_.TypeAndModel -eq "RDS Per User CAL"}
    }
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending] RDS Details"  
$CTXObject



} #end Function

