
<#PSScriptInfo

.VERSION 1.0.1

.GUID 541ded25-9c56-4f57-bd42-8cb0799f331b

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
Date Created - 17/05/2019_04:24
Date Updated - 22/05/2019_20:14

.PRIVATEDATA

#> 



<#

.DESCRIPTION 
Xendesktop Farm Details

#>

Param()



Function Get-StoreFrontDetails {
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
        param($StoreFrontServer, $RemoteCredentials,$VerbosePreference)

        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Storefront Details"
        $SiteArray = @()
        Add-PSSnapin citrix*
        $STFDeployment = Get-STFDeployment
        $DeploymentSiteId = $STFDeployment.SiteId


        # Set Proxy
        $wc = New-Object System.Net.WebClient
        $wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Store Details"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $WebObject = New-Object PSObject -Property @{
            InternalStore                  = (Get-STFServerGroup | select -ExpandProperty HostBaseUrl).AbsoluteUri
            InternalStoreStatus            = (Invoke-WebRequest -Uri ((Get-STFServerGroup | select -ExpandProperty HostBaseUrl).AbsoluteUri) -UseBasicParsing) | foreach { $_.StatusDescription }
            ReplicationSource              = (Get-ItemProperty  HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication -Name LastSourceServer).LastSourceServer
            SyncState                      = (Get-ItemProperty  HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication -Name LastUpdateStatus).LastUpdateStatus
            EndSyncDate                    = (((Get-ItemProperty  HKLM:\SOFTWARE\Citrix\DeliveryServices\ConfigurationReplication -Name LastEndTime).LastEndTime).split(".")[0]).replace("T"," ")

        } | select InternalStore, InternalStoreStatus,ReplicationSource,SyncState,EndSyncDate
        $SiteArray =  $WebObject.psobject.Properties | Select-Object -Property Name, Value


        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Processing] Server Details"
        $SFGroup = Get-STFServerGroup | select -ExpandProperty ClusterMembers
        $SFServers = @()
        foreach ($SFG in $SFGroup) {
            $CusObject = New-Object PSObject -Property @{
                ComputerName = ([System.Net.Dns]::GetHostByName(($SFG.Hostname))).Hostname
                IsLive       = $SFG.IsLive
            } | select ComputerName, IsLive
            $SFServers += $CusObject
        }
        #####
        $Details = New-Object PSObject -Property @{
            DateCollected         = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
            SiteDetails           = $SiteArray
            ServerDetails         = $SFServers

        } | select DateCollected,SiteDetails, ServerDetails
        $Details
        Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Ending] StoreFront Details"

    }
        $FarmDetails = @()
        if ($RunAsPSRemote -eq $true) { $FarmDetails = Invoke-Command -ComputerName $StoreFrontServer -ScriptBlock ${Function:AllConfig} -ArgumentList  @($StoreFrontServer, $RemoteCredentials,$VerbosePreference) -Credential $RemoteCredentials }
        else { $FarmDetails = AllConfig -StoreFrontServer $StoreFrontServer -RemoteCredentials $RemoteCredentials }
        Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [End] All Details"
        $FarmDetails | select DateCollected,SiteDetails,ServerDetails

    } #end Function

