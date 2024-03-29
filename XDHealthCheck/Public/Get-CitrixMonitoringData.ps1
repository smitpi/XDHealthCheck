
<#PSScriptInfo

.VERSION 0.1.0

.GUID 3b2c53b1-a6b7-4de5-9f07-1d0a35df166e

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT 

.TAGS ctx

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [03/05/2022_18:50] Initial Script Creating

#>


<# 

.DESCRIPTION 
 Connects and collects data from the monitoring OData feed. 

#> 


<#
.SYNOPSIS
Connects and collects data from the monitoring OData feed.

.DESCRIPTION
Connects and collects data from the monitoring OData feed.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER SessionCount
Will collect data for the last x amount of sessions.

.PARAMETER  AllowUnencryptedAuthentication
To use a Unencrypted Authentication

.EXAMPLE
Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount 50

#>
Function Get-CitrixMonitoringData {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixMonitoringData')]
    [OutputType([System.Object[]])]
    PARAM(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$AdminServer,
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [int32]$SessionCount,
        [switch]$AllowUnencryptedAuthentication
				)

    Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Monitoring data connect"

    $headers = @{'Accept' = 'application/json;odata=verbose'}

    $urisettings = @{
        UseDefaultCredentials = $true
        Headers               = $headers
        Method                = 'Get'
    }

    if ($AllowUnencryptedAuthentication) {$urisettings.Add('AllowUnencryptedAuthentication', $true)}
    
    try {
        [pscustomobject]@{
            PSTypeName  = 'CTXMonitorData'
            Sessions    = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/Sessions?`$top=$($SessionCount)&`$expand=User,SessionMetrics,Machine,Failure,CurrentConnection&`$orderby=CreatedDate desc" @urisettings ).d
            Connections = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/Connections?`$top=$($SessionCount)&`$orderby=CreatedDate desc&`$expand=ConnectionFailureLog,Session" @urisettings ).d
        }
    } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
    
} #end Function
