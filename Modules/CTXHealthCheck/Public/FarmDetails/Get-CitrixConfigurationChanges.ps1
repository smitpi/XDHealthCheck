
<#PSScriptInfo

.VERSION 1.0.3

.GUID 71b2bc51-85ce-407b-ace5-96df009782d3

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
Function Get-CitrixConfigurationChanges {
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
    param($AdminServer, $Indays,$VerbosePreference)
    Add-PSSnapin citrix* -ErrorAction SilentlyContinue
    Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Config Changes Details"

    $startdate = (Get-Date).AddDays(-$Indays)
    $exportpath = (Get-Item (Get-Item Env:\TEMP).value).FullName + "\ctxreportlog.csv"

    if (Test-Path $exportpath) { Remove-Item $exportpath -Force -ErrorAction SilentlyContinue }
    Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Procesess] Exporting Changes"

    Export-LogReportCsv -OutputFile $exportpath -StartDateRange $startdate -EndDateRange (Get-Date)
    Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Procesess] Importing Changes"

    $LogExportAll = Import-Csv -Path $exportpath -Delimiter ","
    $LogExport = $LogExportAll |Where-Object {$_.'High Level Operation Text' -notlike ""} | Select-Object -Property High*
    $LogSum =  $LogExportAll | Group-Object -Property 'High Level Operation Text' -NoElement

Remove-Item $exportpath -Force -ErrorAction SilentlyContinue
$CTXObject = New-Object PSObject -Property @{
    DateCollected = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
    AllDetails    = $LogExportAll
    Filtered      = $LogExport
    Summary       = $LogSum
}
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending] Config Changes Details"

$CTXObject

} -ArgumentList @($AdminServer, $Indays,$VerbosePreference) -Credential $RemoteCredentials

} #end Function

