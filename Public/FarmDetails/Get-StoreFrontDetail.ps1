
<#PSScriptInfo

.VERSION 1.0.10

.GUID 541ded25-9c56-4f57-bd42-8cb0799f331b

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
Created [17/05/2019_04:24]
Updated [22/05/2019_20:14]
Updated [24/05/2019_19:25]
Updated [06/06/2019_19:26]
Updated [09/06/2019_09:18]
Updated [15/06/2019_01:11]
Updated [15/06/2019_13:59] Updated Reports
Updated [01/07/2020_14:43] Script Fle Info was updated
Updated [01/07/2020_15:42] Script Fle Info was updated
Updated [01/07/2020_16:07] Script Fle Info was updated
Updated [01/07/2020_16:13] Script Fle Info was updated

.PRIVATEDATA

#> 





















<#

.DESCRIPTION 
Function for Citrix XenDesktop HTML Health Check Report

#>

Param()



Function Get-StoreFrontDetail {
	[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$StoreFrontServer,
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$RemoteCredentials,
        [Parameter(Mandatory = $false, Position = 2)]
        [switch]$RunAsPSRemote = $false)

    function AllConfig {
        param($StoreFrontServer, $VerbosePreference)

        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Storefront Details"
        $SiteArray = @()
        Add-PSSnapin citrix*

        # Set Proxy
        $wc = New-Object System.Net.WebClient
        $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Store Details"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $WebObject = New-Object PSObject -Property @{
            InternalStore                  = (Get-STFServerGroup | Select-Object -ExpandProperty HostBaseUrl).AbsoluteUri
            InternalStoreStatus            = (Invoke-WebRequest -Uri ((Get-STFServerGroup | Select-Object -ExpandProperty HostBaseUrl).AbsoluteUri) -UseBasicParsing) | ForEach-Object { $_.StatusDescription }
            ReplicationSource              = (Get-ItemProperty  HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication -Name LastSourceServer).LastSourceServer
            SyncState                      = (Get-ItemProperty  HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication -Name LastUpdateStatus).LastUpdateStatus
            EndSyncDate                    = (((Get-ItemProperty  HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication -Name LastEndTime).LastEndTime).split(".")[0]).replace("T"," ")

        } | Select-Object InternalStore, InternalStoreStatus,ReplicationSource,SyncState,EndSyncDate
        $SiteArray =  $WebObject.psobject.Properties | Select-Object -Property Name, Value


        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Server Details"
        $SFGroup = Get-STFServerGroup | Select-Object -ExpandProperty ClusterMembers
        $SFServers = @()
        foreach ($SFG in $SFGroup) {
            $CusObject = New-Object PSObject -Property @{
                ComputerName = ([System.Net.Dns]::GetHostByName(($SFG.Hostname))).Hostname
                IsLive       = $SFG.IsLive
            } | Select-Object ComputerName, IsLive
            $SFServers += $CusObject
        }
        #####
        $Details = New-Object PSObject -Property @{
            DateCollected         = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
            SiteDetails           = $SiteArray
            ServerDetails         = $SFServers

        } | Select-Object DateCollected,SiteDetails, ServerDetails
        $Details
        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending] StoreFront Details"

    }
        $FarmDetails = @()
        if ($RunAsPSRemote -eq $true) { $FarmDetails = Invoke-Command -ComputerName $StoreFrontServer -ScriptBlock ${Function:AllConfig} -ArgumentList  @($StoreFrontServer, $VerbosePreference) -Credential $RemoteCredentials }
        else { $FarmDetails = AllConfig -StoreFrontServer $StoreFrontServer }
        Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [End] All Details"
        $FarmDetails | select-object DateCollected,SiteDetails,ServerDetails

    } #end Function

