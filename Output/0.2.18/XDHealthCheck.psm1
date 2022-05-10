#region Private Functions
########### Private Function ###############
# source: DirectorCodes.ps1
# Module: XDHealthCheck
############################################

$script:RegistrationState = @{
    0 = 'Unknown'
    1 = 'Registered'
    2 = 'Unregistered'
}
$script:ConnectionState = @{
    0 = 'Unknown'
    1 = 'Connected'
    2 = 'Disconnected'
    3 = 'Terminated'
    4 = 'PreparingSession'
    5 = 'Active'
    6 = 'Reconnecting'
    7 = 'NonBrokeredSession'
    8 = 'Other'
    9 = 'Pending'
}
$script:ConnectionFailureType = @{
    0 = 'None'
    1 = 'ClientConnectionFailure'
    2 = 'MachineFailure'
    3 = 'NoCapacityAvailable'
    4 = 'NoLicensesAvailable'
    5 = 'Configuration'
}
$script:SessionFailureCode = @{
    0   = 'Unknown'
    1   = 'None'
    2   = 'SessionPreparation'
    3   = 'RegistrationTimeout'
    4   = 'ConnectionTimeout'
    5   = 'Licensing'
    6   = 'Ticketing'
    7   = 'Other'
    8   = 'GeneralFail'
    9   = 'MaintenanceMode'
    10  = 'ApplicationDisabled'
    11  = 'LicenseFeatureRefused'
    12  = 'NoDesktopAvailable'
    13  = 'SessionLimitReached'
    14  = 'DisallowedProtocol'
    15  = 'ResourceUnavailable'
    16  = 'ActiveSessionReconnectDisabled'
    17  = 'NoSessionToReconnect'
    18  = 'SpinUpFailed'
    19  = 'Refused'
    20  = 'ConfigurationSetFailure'
    21  = 'MaxTotalInstancesExceeded'
    22  = 'MaxPerUserInstancesExceeded'
    23  = 'CommunicationError'
    24  = 'MaxPerMachineInstancesExceeded'
    25  = 'MaxPerEntitlementInstancesExceeded'
    100 = 'NoMachineAvailable'
    101 = 'MachineNotFunctional'
}
$script:MachineDeregistration = @{
    0	='AgentShutdown'
    1	='AgentSuspended'
    100	='IncompatibleVersion'
    101	='AgentAddressResolutionFailed'
    102	='AgentNotContactable'
    103	='AgentWrongActiveDirectoryOU'
    104	='EmptyRegistrationRequest'
    105	='MissingRegistrationCapabilities'
    106	='MissingAgentVersion'
    107	='InconsistentRegistrationCapabilities'
    108	='NotLicensedForFeature'
    109	='UnsupportedCredentialSecurityversion'
    110	='InvalidRegistrationRequest'
    111	='SingleMultiSessionMismatch'
    112	='FunctionalLevelTooLowForCatalog'
    113	='FunctionalLevelTooLowForDesktopGroup'
    200	='PowerOff'
    203	='AgentRejectedSettingsUpdate'
    206	='SessionPrepareFailure'
    207	='ContactLost'
    301	='BrokerRegistrationLimitReached'
    208	='SettingsCreationFailure'
    204	='SendSettingsFailure'
    2	='AgentRequested'
    201	='DesktopRestart'
    202	='DesktopRemoved'
    205	='SessionAuditFailure'
    300	='UnknownError'
    302	='RegistrationStateMismatch'
}
$script:MachineFailureType = @{
    4 = 'MaxCapacity'
    2 = 'StuckOnBoot'	
    1 = 'FailedToStart'
}
$script:ConnectionState = @{
        0   =	'Unknown'
        1	=	'Connected'
        2	=	'Disconnected'
        3	=	'Terminated'
        4	=	'PreparingSession'
        5	=	'Active'
        6	=	'Reconnecting'
        7	=	'NonBrokeredSession'
        8	=	'Other'
        9	=	'Pending'
}
########### Private Function ###############
# source: Reports-Colors.ps1
# Module: XDHealthCheck
############################################

if (Test-Path HKCU:\Software\XDHealth) {

    $global:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
    $global:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
    $global:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL

}
else {
        New-Item -Path HKCU:\Software\XDHealth
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color1 -Value '#061820'
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color2 -Value '#FFD400'
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name LogoURL -Value 'https://c.na65.content.force.com/servlet/servlet.ImageServer?id=0150h000003yYnkAAE&oid=00DE0000000c48tMAA'

    $global:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
    $global:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
    $global:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL
}


#region Html Settings
$global:TableSettings = @{
	Style           = 'cell-border'
	TextWhenNoData  = 'No Data to display here'
	Buttons         = 'searchBuilder', 'pdfHtml5', 'excelHtml5'
	#AutoSize        = $true
	#DisableSearch   = $true
	FixedHeader     = $true
	HideFooter      = $true
	#ScrollCollapse  = $true
	#ScrollX         = $true
	#ScrollY         = $true
	SearchHighlight = $true
    PagingStyle     = "full"
    PagingLength    = 10
    #EnableScroller  = $true
}
$global:SectionSettings = @{
	BackgroundColor       = 'grey'
	CanCollapse           = $true
	HeaderBackGroundColor = $XDHealth_Color1
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = $XDHealth_Color2
	HeaderTextSize        = '15'
	BorderRadius          = '20px'
}
$global:TableSectionSettings = @{
	BackgroundColor       = 'white'
	CanCollapse           = $true
	HeaderBackGroundColor = $XDHealth_Color2
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = $XDHealth_Color1
	HeaderTextSize        = '15'
}
#endregion


########### Private Function ###############
# source: Reports-Variables.ps1
# Module: XDHealthCheck
############################################


$global:RegistrationState = [PSCustomObject]@{
    0 = 'Unknown'
    1 = 'Registered'
    2 = 'Unregistered'
}
$global:ConnectionState = [PSCustomObject]@{
    0 = 'Unknown'
    1 = 'Connected'
    2 = 'Disconnected'
    3 = 'Terminated'
    4 = 'PreparingSession'
    5 = 'Active'
    6 = 'Reconnecting'
    7 = 'NonBrokeredSession'
    8 = 'Other'
    9 = 'Pending'
}
$global:ConnectionFailureType = [PSCustomObject]@{
    0 = 'None'
    1 = 'ClientConnectionFailure'
    2 = 'MachineFailure'
    3 = 'NoCapacityAvailable'
    4 = 'NoLicensesAvailable'
    5 = 'Configuration'
}
$global:SessionFailureCode = [PSCustomObject]@{
    0   = 'Unknown'
    1   = 'None'
    2   = 'SessionPreparation'
    3   = 'RegistrationTimeout'
    4   = 'ConnectionTimeout'
    5   = 'Licensing'
    6   = 'Ticketing'
    7   = 'Other'
    8   = 'GeneralFail'
    9   = 'MaintenanceMode'
    10  = 'ApplicationDisabled'
    11  = 'LicenseFeatureRefused'
    12  = 'NoDesktopAvailable'
    13  = 'SessionLimitReached'
    14  = 'DisallowedProtocol'
    15  = 'ResourceUnavailable'
    16  = 'ActiveSessionReconnectDisabled'
    17  = 'NoSessionToReconnect'
    18  = 'SpinUpFailed'
    19  = 'Refused'
    20  = 'ConfigurationSetFailure'
    21  = 'MaxTotalInstancesExceeded'
    22  = 'MaxPerUserInstancesExceeded'
    23  = 'CommunicationError'
    24  = 'MaxPerMachineInstancesExceeded'
    25  = 'MaxPerEntitlementInstancesExceeded'
    100 = 'NoMachineAvailable'
    101 = 'MachineNotFunctional'
}



#endregion
#region Public Functions
#region Get-CitrixConfigurationChange.ps1
############################################
# source: Get-CitrixConfigurationChange.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Show the changes that was made to the farm


.DESCRIPTION
Show the changes that was made to the farm

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER Indays
Use this time frame for the report.

.PARAMETER Export
Export the result to a report file. (Excel, html or Screen)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixConfigurationChange -AdminServer $CTXDDC -Indays 7

#>
Function Get-CitrixConfigurationChange {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixConfigurationChange')]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int32]$Indays,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	if (-not(Get-PSSnapin -Registered | Where-Object {$_.name -like 'Citrix*'})) {Add-PSSnapin citrix* -ErrorAction SilentlyContinue}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Config Changes Details"

	$startdate = (Get-Date).AddDays(-$Indays)
	$exportpath = (Get-Item (Get-Item Env:\TEMP).value).FullName + '\ctxreportlog.csv'

	if (Test-Path $exportpath) { Remove-Item $exportpath -Force -ErrorAction SilentlyContinue }
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Progress] Exporting Changes"

	Export-LogReportCsv -AdminAddress $AdminServer -OutputFile $exportpath -StartDateRange $startdate -EndDateRange (Get-Date)
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Progress] Importing Changes"

	$LogExportAll = Import-Csv -Path $exportpath -Delimiter ','
	$LogExport = $LogExportAll | Where-Object { $_.'High Level Operation Text' -notlike '' } | Select-Object -Property High*
	$LogSum = $LogExportAll | Group-Object -Property 'High Level Operation Text' -NoElement

	Remove-Item $exportpath -Force -ErrorAction SilentlyContinue
	$CTXObject = New-Object PSObject -Property @{
		DateCollected = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		AllDetails    = $LogExportAll
		Filtered      = $LogExport
		Summary       = $LogSum
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Config Changes Details"
	
	if ($Export -eq 'Excel') { 
		$CTXObject.AllDetails | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixConfigurationChange-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName CitrixConfigurationChange -AutoSize -AutoFilter -Title 'Citrix Configuration Change' -TitleBold -TitleSize 28
	}
	if ($Export -eq 'HTML') { 
		$CTXObject.AllDetails | Out-HtmlView -DisablePaging -Title 'Citrix Configuration Change' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixConfigurationChange-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
	}
	if ($Export -eq 'Host') { 
		$CTXObject
	}
}
 
Export-ModuleMember -Function Get-CitrixConfigurationChange
#endregion
 
#region Get-CitrixEnvTestResults.ps1
############################################
# source: Get-CitrixEnvTestResults.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Perform and report on tests on catalogs, delivery groups, hypervisor and Infrastructure

.DESCRIPTION
Perform and report on tests on catalogs, delivery groups, hypervisor and Infrastructure

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER Catalogs
Report on Catalogs

.PARAMETER DesktopGroups
Report on Desktop Groups

.PARAMETER Hypervisor
Report on  hypervisor

.PARAMETER Infrastructure
Report Infrastructure

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixEnvTestResults -AdminServer vulcan.internal.lab -Catalogs -DesktopGroups -Hypervisor -Infrastructure -Export HTML -ReportPath C:\temp -Verbose

#>
Function Get-CitrixEnvTestResults {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixEnvTestResults')]
    [OutputType([System.Object[]])]
    PARAM(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$AdminServer,
        [switch]$Catalogs = $false,
        [switch]$DesktopGroups = $false,
        [switch]$Hypervisor = $false,
        [switch]$Infrastructure = $false,
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )


    if ($Catalogs) {
        try {
            [System.Collections.ArrayList]$catalogResults = @()
            foreach ($catalog in Get-BrokerCatalog -AdminAddress $AdminServer) {
                Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Catalog: $($catalog.Name)"
                $testResult = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminServer -TargetIdType 'Catalog' -TestSuiteId 'Catalog' -TargetId $catalog.UUID | Start-EnvTestTask -AdminAddress $AdminServer -ExcludeNotRunTests 
                $testResult.TestResults | ForEach-Object {
                    [void]$catalogResults.Add([pscustomobject]@{
                            Name                = $catalog.Name
                            TestComponentStatus = $_.TestComponentStatus
                            TestId              = $_.TestId
                            TestServiceTarget   = $_.TestServiceTarget
                            TestEndTime         = $_.TestEndTime
                        })
                }
            }
        } catch {Write-Warning "Error: `nException:$($_.Exception.Message)"}
    } 

    if ($DesktopGroups) {
        try {
            [System.Collections.ArrayList]$DesktopGroupResults = @()
            foreach ($DesktopGroup in Get-BrokerDesktopGroup -AdminAddress $AdminServer) {
                Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Catalog: $($DesktopGroup.Name)"
                $testResult = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminServer -TargetIdType 'DesktopGroup' -TestSuiteId 'DesktopGroup' -TargetId $DesktopGroup.UUID | Start-EnvTestTask -AdminAddress $AdminServer -ExcludeNotRunTests 
                $testResult.TestResults | ForEach-Object {
                    [void]$DesktopGroupResults.Add([pscustomobject]@{
                            Name                = $DesktopGroup.Name
                            TestComponentStatus = $_.TestComponentStatus
                            TestId              = $_.TestId
                            TestServiceTarget   = $_.TestServiceTarget
                            TestEndTime         = $_.TestEndTime
                        })
                }
            }
        } catch {Write-Warning "Error: `nException:$($_.Exception.Message)"}
    }

    if ($Hypervisor) {
        try {
            [System.Collections.ArrayList]$HypervisorConnectionResults = @()
            foreach ($Hypervisor in Get-BrokerHypervisorConnection -AdminAddress $AdminServer) {
                Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Catalog: $($Hypervisor.Name)"
                $testResult = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminServer -TargetIdType 'HypervisorConnection' -TestSuiteId 'HypervisorConnection' -TargetId $Hypervisor.Uid | Start-EnvTestTask -AdminAddress $AdminServer -ExcludeNotRunTests 
                $testResult.TestResults | ForEach-Object {
                    [void]$HypervisorConnectionResults.Add([pscustomobject]@{
                            Name                = $Hypervisor.Name
                            TestComponentStatus = $_.TestComponentStatus
                            TestId              = $_.TestId
                            TestServiceTarget   = $_.TestServiceTarget
                            TestEndTime         = $_.TestEndTime
                        })
                }
            }
        } catch {Write-Warning "Error: `nException:$($_.Exception.Message)"}
    }

    if ($Infrastructure) {
        try {
            [System.Collections.ArrayList]$InfrastructureResults = @()
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Catalog: Infrastructure"
            $Infra = New-EnvTestDiscoveryTargetDefinition -TestSuiteId Infrastructure | Start-EnvTestTask -AdminAddress $AdminServer -ExcludeNotRunTests
            $Infra.TestResults | ForEach-Object {
                [void]$InfrastructureResults.Add([pscustomobject]@{
                        TestComponentStatus = $_.TestComponentStatus
                        TestId              = $_.TestId
                        TestServiceTarget   = $_.TestServiceTarget
                        TestEndTime         = $_.TestEndTime
                    })
            }
        } catch {Write-Warning "Error: `nException:$($_.Exception.Message)"}
    }

    if ($Export -eq 'Excel') { 
        $catalogResults | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixEnvTestResults-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Title 'Catalog Results' -WorksheetName Catalog -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
        $DesktopGroupResults | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixEnvTestResults-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Title 'DesktopGroup Results' -WorksheetName DesktopGroup -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
        $HypervisorConnectionResults | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixEnvTestResults-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Title 'Hypervisor Connection Results' -WorksheetName Hypervisor -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
        $InfrastructureResults | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixEnvTestResults-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Title 'Infrastructure Results' -WorksheetName Infrastructure -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
    }
    if ($Export -eq 'HTML') { 
    	New-HTML -TitleText "CitrixFarmDetail-$(Get-Date -Format yyyy.MM.dd-HH.mm)" -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixEnvTestResults-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLTab -Name 'Catalog Results' -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {New-HTMLPanel -Content { New-HTMLTable -DataTable $($catalogResults) @TableSettings}}
			New-HTMLTab -Name 'DesktopGroup Results' -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {New-HTMLPanel -Content { New-HTMLTable -DataTable $($DesktopGroupResults) @TableSettings}}
			New-HTMLTab -Name 'Hypervisor Connection Results' -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {New-HTMLPanel -Content { New-HTMLTable -DataTable $($HypervisorConnectionResults) @TableSettings}}
			New-HTMLTab -Name 'Infrastructure Results' -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {New-HTMLPanel -Content { New-HTMLTable -DataTable $($InfrastructureResults) @TableSettings}}
		} -Online -Encoding UTF8 -ShowHTML
    }
    if ($Export -eq 'Host') {
        [pscustomobject]@{
            catalogResults              = $catalogResults
            DesktopGroupResults         = $DesktopGroupResults
            HypervisorConnectionResults = $HypervisorConnectionResults
            InfrastructureResults       = $InfrastructureResults
        }
    }
} #end Function
 
Export-ModuleMember -Function Get-CitrixEnvTestResults
#endregion
 
#region Get-CitrixFailures.ps1
############################################
# source: Get-CitrixFailures.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Creates a report from monitoring data about machine and connection failures

.DESCRIPTION
Creates a report from monitoring data about machine and connection failures

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER hours
Limit the report to this time fame

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixFailures -AdminServer $CTXDDC

#>
Function Get-CitrixFailures {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixFailures')]
    [OutputType([System.Object[]])]
    PARAM(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$AdminServer,
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [int32]$hours,
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',
        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )					

    $mon = Get-CitrixMonitoringData -AdminServer $AdminServer -hours $hours

    [System.Collections.ArrayList]$mashineFails = @()
    foreach ($MFail in $mon.MachineFailureLogs) {
        $device = $mon.Machines | Where-Object {$_.id -like $MFail.MachineId}
        [void]$mashineFails.Add([pscustomobject]@{
                Name                     = $device.Name
                IP                       = $device.IPAddress
                OSType                   = $device.OSType
                FailureDate              = [datetime]$MFail.FailureStartDate
                FaultState               = $MFail.FaultState 
                LastDeregisteredCode     = $MachineDeregistration[$MFail.LastDeregisteredCode]
                CurrentRegistrationState = $RegistrationState[$device.CurrentRegistrationState]
                CurrentFaultState        = $device.FaultState
            })
    }

    [System.Collections.ArrayList]$ConnectionFails = @()
    foreach ($CFail in $mon.ConnectionFailureLogs) {
        $user = $mon.Users | Where-Object {$_.id -like $CFail.UserId}
        $device = $mon.Machines | Where-Object {$_.id -like $CFail.MachineId}
        [void]$ConnectionFails.Add([pscustomobject]@{
                UserName       = $user.UserName
                Upn            = $user.Upn
                Name           = $device.Name
                IP             = $device.IPAddress
                FailureDate    = [datetime]$CFail.FailureDate
                FailureDetails = $SessionFailureCode[$CFail.ConnectionFailureEnumValue]
            })
    }


    if ($Export -eq 'Excel') { 
        $mashineFails | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixFailures-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName MachineFailures -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
        $ConnectionFails | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixFailures-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName ConnectionFailures -AutoSize -AutoFilter -Title 'Connection Failures' -TitleBold -TitleSize 28 -Show
    }
    if ($Export -eq 'HTML') { 
        $mashineFails | Out-HtmlView -DisablePaging -Title 'Mashine Failures' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\Citrix-Machine-Failures-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
        $ConnectionFails | Out-HtmlView -DisablePaging -Title 'Connection Failures' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\Citrix-Connection-Failures-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
        
    }
    if ($Export -eq 'Host') { 
        [pscustomobject]@{
            mashineFails    = $mashineFails
            ConnectionFails = $ConnectionFails
        }
    }


} #end Function
 
Export-ModuleMember -Function Get-CitrixFailures
#endregion
 
#region Get-CitrixFarmDetail.ps1
############################################
# source: Get-CitrixFarmDetail.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Get needed Farm details.

.DESCRIPTION
Get needed Farm details.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.EXAMPLE
Get-CitrixFarmDetail -AdminServer $CTXDDC 

#>
Function Get-CitrixFarmDetail {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixFarmDetail')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer
	)

	if (-not(Get-PSSnapin -Registered | Where-Object {$_.name -like 'Citrix*'})) {Add-PSSnapin citrix* -ErrorAction SilentlyContinue}

	#region Site details
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Site Details"
	$site = Get-BrokerSite -AdminAddress $AdminServer
	$SiteDetails = New-Object PSObject -Property @{
		Summary    = $site | Select-Object Name, ConfigLastChangeTime, LicenseEdition, LicenseModel, LicenseServerName
		AllDetails = $site
	}
	#endregion

	#region Controllers
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Controllers Details"
	[System.Collections.ArrayList]$Controllers = @()
	Get-BrokerController -AdminAddress $AdminServer | ForEach-Object {
		[void]$Controllers.Add([pscustomobject]@{
				AllDetails = $_
				Summary    = New-Object PSObject -Property @{
					Name                  = $_.dnsname
					'Desktops Registered' = $_.DesktopsRegistered
					'Last Activity Time'  = $_.LastActivityTime
					'Last Start Time'     = $_.LastStartTime
					State                 = $_.State
					ControllerVersion     = $_.ControllerVersion
				}
			})
	}
	#endregion

	#region Machines
	try {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Machines Details"
		$NonRemotepc = Get-BrokerMachine -MaxRecordCount 1000000 -AdminAddress $AdminServer
		$UnRegServer = $NonRemotepc | Where-Object { $_.RegistrationState -like 'unreg*' -and $_.DeliveryType -notlike 'DesktopsOnly' } | Select-Object DNSName, CatalogName, DesktopGroupName, FaultState
		$UnRegDesktop = $NonRemotepc | Where-Object { $_.RegistrationState -like 'unreg*' -and $_.DeliveryType -like 'DesktopsOnly' } | Select-Object DNSName, CatalogName, DesktopGroupName, AssociatedUserNames, FaultState
		$Machines = New-Object PSObject -Property @{
			AllMachines          = $NonRemotepc
			UnRegisteredServers  = $UnRegServer
			UnRegisteredDesktops = $UnRegDesktop
		} | Select-Object AllMachines, UnRegisteredServers, UnRegisteredDesktops
	} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	#endregion

	#region sessions
	try {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Sessions Details"
		$sessions = Get-BrokerSession -MaxRecordCount 1000000 -AdminAddress $AdminServer
	} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	#endregion

	#region del groups
	try {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] DeliveryGroups Details"
		$DeliveryGroups = Get-BrokerDesktopGroup -AdminAddress $AdminServer | Select-Object Name, DeliveryType, DesktopKind, IsRemotePC, Enabled, TotalDesktops, DesktopsAvailable, DesktopsInUse, DesktopsUnregistered, InMaintenanceMode, Sessions, SessionSupport, TotalApplicationGroups, TotalApplications
	} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}	
	#endregion		

	#region dbconnection	
	try {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] DBConnection Details"
		$dbArray = @()

		$dbconnection = (Test-BrokerDBConnection -DBConnection(Get-BrokerDBConnection -AdminAddress $AdminServer))

		if ([bool]($dbconnection.ExtraInfo.'Database.Status') -eq $False) { [string]$dbstatus = 'Unavalable' }
		else { [string]$dbstatus = $dbconnection.ExtraInfo.'Database.Status' }

		$CCTXObject = New-Object PSObject -Property @{
			'Service Status'       = $dbconnection.ServiceStatus.ToString()
			'DB Connection Status' = $dbstatus
			'Is Mirroring Enabled' = $dbconnection.ExtraInfo.'Database.IsMirroringEnabled'.ToString()
			'DB Last Backup Date'  = $dbconnection.ExtraInfo.'Database.LastBackupDate'.ToString()
		} | Select-Object 'Service Status', 'DB Connection Status', 'Is Mirroring Enabled', 'DB Last Backup Date'

		$DBConnection = $CCTXObject.psobject.Properties | Select-Object -Property Name, Value
	} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	#endregion

	#region reboots
	try {
		[System.Collections.ArrayList]$RebootSchedule = @()
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Reboot Schedule Details"
		Get-BrokerRebootScheduleV2 -AdminAddress $AdminServer -Day $((Get-Date).DayOfWeek.ToString()) | ForEach-Object {
			$sched = $_
			Get-BrokerMachine -DesktopGroupName $sched.DesktopGroupName | ForEach-Object {
				[void]$RebootSchedule.Add([pscustomobject]@{
						ComputerName   = $_.DNSName
						IP             = $_.IPAddress
						DelGroup       = $_.DesktopGroupName
						Day            = $sched.Day
						Frequency      = $sched.Frequency
						Name           = $sched.Name
						RebootDuration = $sched.RebootDuration
						StartTime      = $sched.StartTime
					})
			}
		}
	} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	#endregion

	#region counts
	try {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Session Counts Details"
		$SessionCounts = New-Object PSObject -Property @{
			'Active Sessions'        = ($Sessions | Where-Object -Property Sessionstate -EQ 'Active').count
			'Disconnected Sessions'  = ($Sessions | Where-Object -Property Sessionstate -EQ 'Disconnected').count
			'Unregistered Servers'   = ($Machines.UnRegisteredServers | Measure-Object).count
			'Unregistered Desktops'  = ($Machines.UnRegisteredDesktops | Measure-Object).count
		} | Select-Object 'Active Sessions', 'Disconnected Sessions', 'Connection Failures', 'Unregistered Servers', 'Unregistered Desktops', 'Machine Failures' 
	} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
	#endregion

	[PSCustomObject]@{
		DateCollected  = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		SiteDetails    = $SiteDetails
		Controllers    = $Controllers
		Machines       = $Machines
		Sessions       = $Sessions
		DeliveryGroups = $DeliveryGroups
		DBConnection   = $DBConnection
		SessionCounts  = $SessionCounts
		RebootSchedule = $RebootSchedule
	}
} #end Function

 
Export-ModuleMember -Function Get-CitrixFarmDetail
#endregion
 
#region Get-CitrixLicenseInformation.ps1
############################################
# source: Get-CitrixLicenseInformation.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Show Citrix License details

.DESCRIPTION
Show Citrix License details

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER Export
Export the result to a report file. (Excel, html or Screen)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixLicenseInformation -AdminServer $CTXDDC 

#>
Function Get-CitrixLicenseInformation {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixLicenseInformation')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
		)

	if (-not(Get-PSSnapin -Registered | Where-Object {$_.name -like 'Citrix*'})) {Add-PSSnapin citrix* -ErrorAction SilentlyContinue}
	$licenseServer = (Get-BrokerSite -AdminAddress $AdminServer).LicenseServerName
	$cert = Get-LicCertificate -AdminAddress "https://$($licenseServer):8083"
	$ctxlic = Get-LicInventory -AdminAddress "https://$($licenseServer):8083" -CertHash $cert.CertHash | Where-Object { $_.LicensesInUse -ne 0 }
	[System.Collections.ArrayList]$LicDetails = @()
	foreach ($lic in $ctxlic) {
		[void]$LicDetails.Add([pscustomobject]@{
				LicenseProductName = $lic.LocalizedLicenseProductName
				LicenseModel       = $lic.LocalizedLicenseModel
				LicensesInstalled  = $lic.LicensesAvailable
				LicensesInUse      = $lic.LicensesInUse
				LicensesAvailable  = ([int]$lic.LicensesAvailable - [int]$lic.LicensesInUse)
			})
	}
	if ($Export -eq 'Excel') { 
		$LicDetails | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixLicenseInformation-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName LicDetails -AutoSize -AutoFilter -Title 'Lic Details' -TitleBold -TitleSize 28
	}
	if ($Export -eq 'HTML') { 
		$LicDetails | Out-HtmlView -DisablePaging -Title 'Lic Details' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixLicenseInformation-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
	}
	if ($Export -eq 'Host') { 
		$LicDetails
	}
} #end Function
 
Export-ModuleMember -Function Get-CitrixLicenseInformation
#endregion
 
#region Get-CitrixMonitoringData.ps1
############################################
# source: Get-CitrixMonitoringData.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Connects and collects data from the monitoring OData feed.

.DESCRIPTION
Connects and collects data from the monitoring OData feed.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER hours
Limit the report to this time frame

.EXAMPLE
Get-CitrixMonitoringData -AdminServer $AdminServer -hours $hours

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
        [int32]$hours
				)

    Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Monitoring data connect"


    $now = Get-Date -Format yyyy-MM-ddTHH:mm:ss
    $past = ((Get-Date).AddHours(-$hours)).ToString('yyyy-MM-ddTHH:mm:ss')

    $urisettings = @{
        AllowUnencryptedAuthentication = $true
        UseDefaultCredentials = $true
    }
    try {
        $ChechOdataVer = (Invoke-WebRequest -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data" @urisettings).headers['OData-Version']
    } catch {$ChechOdataVer = '3'}

    if ($ChechOdataVer -like '4*') {
        try {
        [pscustomobject]@{
            Sessions                   = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/Sessions?$filter = StartDate ge datetime`'$($past)`' and StartDate le datetime`'$($now)`'" @urisettings ).value
            Connections                = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/Connections?$filter = StartDate ge datetime`'$($past)`' and StartDate le datetime`'$($now)`'" @urisettings ).value
            ConnectionFailureLogs      = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/ConnectionFailureLogs?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'" @urisettings ).value
            MachineFailureLogs         = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/MachineFailureLogs?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'" @urisettings ).value
            Users                      = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/Users" @urisettings ).value
            Machines                   = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/Machines" @urisettings ).value
            Catalogs                   = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/Catalogs" @urisettings ).value
            Applications               = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/Applications" @urisettings ).value
            DesktopGroups              = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/DesktopGroups" @urisettings ).value
            ResourceUtilization        = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/ResourceUtilization?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'" @urisettings ).value
            ResourceUtilizationSummary = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/ResourceUtilizationSummary?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'" @urisettings ).value
            SessionMetrics             = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v4/Data/SessionMetrics?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'" @urisettings ).value
        }
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
    } else {         
        try {
        [pscustomobject]@{
            Sessions                   = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/Sessions?`$filter = StartDate ge datetime`'$($past)`' and StartDate le datetime`'$($now)`'&`$format=json" @urisettings ).value
            Connections                = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/Connections?$filter = StartDate ge datetime`'$($past)`' and StartDate le datetime`'$($now)`'&`$format=json" @urisettings ).value
            ConnectionFailureLogs      = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/ConnectionFailureLogs?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'&`$format=json" @urisettings ).value
            MachineFailureLogs         = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/MachineFailureLogs?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'&`$format=json" @urisettings ).value
            Users                      = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/Users?`$format=json" @urisettings ).value
            Machines                   = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/Machines?`$format=json" @urisettings ).value
            Catalogs                   = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/Catalogs?`$format=json" @urisettings ).value
            Applications               = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/Applications?`$format=json" @urisettings ).value
            DesktopGroups              = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/DesktopGroups?`$format=json" @urisettings ).value
            ResourceUtilization        = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/ResourceUtilization?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'&`$format=json" @urisettings ).value
            ResourceUtilizationSummary = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/ResourceUtilizationSummary?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'&`$format=json" @urisettings ).value
            SessionMetrics             = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/SessionMetrics?$filter = CreatedDate ge datetime`'$($past)`' and CreatedDate le datetime`'$($now)`'&`$format=json" @urisettings ).value
        } 
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
    }
} #end Function
 
Export-ModuleMember -Function Get-CitrixMonitoringData
#endregion
 
#region Get-CitrixObjects.ps1
############################################
# source: Get-CitrixObjects.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Get details of citrix objects

.DESCRIPTION
Get details of citrix objects. (Catalog, Delivery group and published apps)

.PARAMETER AdminServer
FQDN of the Citrix Data Collector


.EXAMPLE
Get-CitrixObjects -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote

#>
Function Get-CitrixObjects {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixObjects')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer)


	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Config"

	if (-not(Get-PSSnapin -Registered | Where-Object {$_.name -like 'Citrix*'})) {Add-PSSnapin citrix* -ErrorAction SilentlyContinue}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Machine Catalogs"
	$CTXMachineCatalog = @()
	$MachineCatalogs = Get-BrokerCatalog -AdminAddress $AdminServer
	foreach ($MachineCatalog in $MachineCatalogs) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Machine Catalog: $($MachineCatalog.name.ToString())"
		$MasterImage = Get-ProvScheme -AdminAddress $AdminServer | Where-Object -Property IdentityPoolName -Like $MachineCatalog.Name
		if ($MasterImage.MasterImageVM -notlike '') {
			$MasterImagesplit = ($MasterImage.MasterImageVM).Split('\')
			$masterSnapshotcount = ($MasterImagesplit | Where-Object { $_ -like '*.snapshot' }).count
			$mastervm = ($MasterImagesplit | Where-Object { $_ -like '*.vm' }).Replace('.vm', '')
			if ($masterSnapshotcount -gt 1) { $masterSnapshot = ($MasterImagesplit | Where-Object { $_ -like '*.snapshot' })[-1].Replace('.snapshot', '') }
			else { $masterSnapshot = ($MasterImagesplit | Where-Object { $_ -like '*.snapshot' }).Replace('.snapshot', '') }
		} else {
			$mastervm = ''
			$masterSnapshot = ''
			$masterSnapshotcount = 0
		}
		$CatObject = New-Object PSObject -Property @{
			MachineCatalogName           = $MachineCatalog.name
			AllocationType               = $MachineCatalog.AllocationType
			Description                  = $MachineCatalog.Description
			IsRemotePC                   = $MachineCatalog.IsRemotePC
			MachinesArePhysical          = $MachineCatalog.MachinesArePhysical
			MinimumFunctionalLevel       = $MachineCatalog.MinimumFunctionalLevel
			PersistUserChanges           = $MachineCatalog.PersistUserChanges
			ProvisioningType             = $MachineCatalog.ProvisioningType
			SessionSupport               = $MachineCatalog.SessionSupport
			Uid                          = $MachineCatalog.Uid
			UnassignedCount              = $MachineCatalog.UnassignedCount
			UsedCount                    = $MachineCatalog.UsedCount
			CleanOnBoot                  = $MasterImage.CleanOnBoot
			MasterImageVM                = $mastervm
			MasterImageSnapshotName      = $masterSnapshot
			MasterImageSnapshotCount     = $masterSnapshotcount
			MasterImageVMDate            = $MasterImage.MasterImageVMDate
			UseFullDiskCloneProvisioning = $MasterImage.UseFullDiskCloneProvisioning
			UseWriteBackCache            = $MasterImage.UseWriteBackCache
		} | Select-Object MachineCatalogName, AllocationType, Description, IsRemotePC, MachinesArePhysical, MinimumFunctionalLevel, PersistUserChanges, ProvisioningType, SessionSupport, Uid, UnassignedCount, UsedCount, CleanOnBoot, MasterImageVM, MasterImageSnapshotName, MasterImageSnapshotCount, MasterImageVMDate, UseFullDiskCloneProvisioning, UseWriteBackCache
		$CTXMachineCatalog += $CatObject
	}

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Delivery Groups"
	$BrokerDesktopGroup = Get-BrokerDesktopGroup -AdminAddress $AdminServer
	$CTXDeliveryGroup = @()
	foreach ($DesktopGroup in $BrokerDesktopGroup) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DesktopGroup.name.ToString())"
		$BrokerAccess = @()
		$BrokerGroups = @()
		$BrokerAccess = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike '' } } | Select-Object UPN
		$BrokerGroups = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like '' } } | Select-Object Name
		$CusObject = New-Object PSObject -Property @{
			DesktopGroupName       = $DesktopGroup.name
			Uid                    = $DesktopGroup.uid
			DeliveryType           = $DesktopGroup.DeliveryType
			DesktopKind            = $DesktopGroup.DesktopKind
			Description            = $DesktopGroup.Description
			DesktopsDisconnected   = $DesktopGroup.DesktopsDisconnected
			DesktopsFaulted        = $DesktopGroup.DesktopsFaulted
			DesktopsInUse          = $DesktopGroup.DesktopsInUse
			DesktopsUnregistered   = $DesktopGroup.DesktopsUnregistered
			Enabled                = $DesktopGroup.Enabled
			IconUid                = $DesktopGroup.IconUid
			InMaintenanceMode      = $DesktopGroup.InMaintenanceMode
			SessionSupport         = $DesktopGroup.SessionSupport
			TotalApplicationGroups = $DesktopGroup.TotalApplicationGroups
			TotalApplications      = $DesktopGroup.TotalApplications
			TotalDesktops          = $DesktopGroup.TotalDesktops
			Tags                   = @(($DesktopGroup.Tags) | Out-String).Trim()
			UserAccess             = @(($BrokerAccess.UPN) | Out-String).Trim()
			GroupAccess            = @(($BrokerGroups.Name) | Out-String).Trim()
		} | Select-Object DesktopGroupName, Uid, DeliveryType, DesktopKind, Description, DesktopsDisconnected, DesktopsFaulted, DesktopsInUse, DesktopsUnregistered, Enabled, IconUid, InMaintenanceMode, SessionSupport, TotalApplicationGroups, TotalApplications, TotalDesktops, Tags, UserAccess, GroupAccess
		$CTXDeliveryGroup += $CusObject
	}

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Application config"
	$HostedApps = @()
	foreach ($DeskG in ($CTXDeliveryGroup | Where-Object { $_.DeliveryType -like 'DesktopsAndApps' })) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DeskG.DesktopGroupName.ToString())"
		$PublishedApps = Get-BrokerApplication -AssociatedDesktopGroupUid $DeskG.Uid -AdminAddress $AdminServer
		#			$PublishedApp = (Get-BrokerApplication -AdminAddress $AdminServer)[27]
		foreach ($PublishedApp in $PublishedApps) {
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Published Application: $($DeskG.DesktopGroupName.ToString()) - $($PublishedApp.PublishedName.ToString())"
			[System.Collections.ArrayList]$PublishedAppGroup = @()
			[System.Collections.ArrayList]$PublishedAppUser = @($PublishedApp.AssociatedUserNames | Where-Object { $_ -notlike $null })
			$index = 0
			foreach ($upn in $PublishedApp.AssociatedUserNames) {
				if ($null -like $upn) { $PublishedAppGroup += @($PublishedApp.AssociatedUserNames)[$index] }
				$index ++
			}
			$CusObject = New-Object PSObject -Property @{
				DesktopGroupName        = $DeskG.DesktopGroupName
				DesktopGroupUid         = $DeskG.Uid
				DesktopGroupUsersAccess = $DeskG.UserAccess
				DesktopGroupGroupAccess = $DeskG.GroupAccess
				ApplicationName         = $PublishedApp.ApplicationName
				ApplicationType         = $PublishedApp.ApplicationType
				AdminFolderName         = $PublishedApp.AdminFolderName
				ClientFolder            = $PublishedApp.ClientFolder
				Description             = $PublishedApp.Description
				Enabled                 = $PublishedApp.Enabled
				CommandLineExecutable   = $PublishedApp.CommandLineExecutable
				CommandLineArguments    = $PublishedApp.CommandLineArguments
				WorkingDirectory        = $PublishedApp.WorkingDirectory
				Tags                    = @(($PublishedApp.Tags) | Out-String).Trim()
				PublishedName           = $PublishedApp.PublishedName
				PublishedAppName        = $PublishedApp.Name
				PublishedAppGroupAccess = @(($PublishedAppGroup) | Out-String).Trim()
				PublishedAppUserAccess  = @(($PublishedAppUser) | Out-String).Trim()
			} | Select-Object DesktopGroupName, DesktopGroupUid, DesktopGroupUsersAccess, DesktopGroupGroupAccess, ApplicationName, ApplicationType, AdminFolderName, ClientFolder, Description, Enabled, CommandLineExecutable, CommandLineArgument, WorkingDirectory, Tags, PublishedName, PublishedAppName, PublishedAppGroupAccess, PublishedAppUserAccess
			$HostedApps += $CusObject
		}
	}

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Server Details"
	$VDAServers = @()
	Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 100000 | Where-Object { $_.OSType -like 'Windows 20*' } | ForEach-Object {
		$VDASCusObject = New-Object PSObject -Property @{
			DNSName           = $_.DNSName
			CatalogName       = $_.CatalogName
			DesktopGroupName  = $_.DesktopGroupName
			IPAddress         = $_.IPAddress
			AgentVersion      = $_.AgentVersion
			OSType            = $_.OSType
			RegistrationState = $_.RegistrationState
			InMaintenanceMode = $_.InMaintenanceMode
		} | Select-Object DNSName, CatalogName, DesktopGroupName, IPAddress, AgentVersion, OSType, RegistrationState, InMaintenanceMode
		$VDAServers += $VDASCusObject
	}

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Workstation Details"
	$VDAWorkstations = @()
	Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 100000 | Where-Object { $_.OSType -notlike 'Windows 20*' } | ForEach-Object {
		$VDAWCusObject = New-Object PSObject -Property @{
			DNSName             = $_.DNSName
			CatalogName         = $_.CatalogName
			DesktopGroupName    = $_.DesktopGroupName
			IPAddress           = $_.IPAddress
			AgentVersion        = $_.AgentVersion
			AssociatedUserNames = @(($_.AssociatedUserNames) | Out-String).Trim()
			OSType              = $_.OSType
			RegistrationState   = $_.RegistrationState
			InMaintenanceMode   = $_.InMaintenanceMode
		} | Select-Object DNSName, CatalogName, DesktopGroupName, IPAddress, AgentVersion, AssociatedUserNames, OSType, RegistrationState, InMaintenanceMode
		$VDAWorkstations += $VDAWCusObject
	}

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Published Applications"

	$CusObject = New-Object PSObject -Property @{
		DateCollected   = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		MachineCatalog  = $CTXMachineCatalog
		DeliveryGroups  = $CTXDeliveryGroup
		PublishedApps   = $HostedApps
		VDAServers      = $VDAServers
		VDAWorkstations = $VDAWorkstations
	}
	$CusObject
} #end Function



 
Export-ModuleMember -Function Get-CitrixObjects
#endregion
 
#region Get-CitrixServerEventLog.ps1
############################################
# source: Get-CitrixServerEventLog.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Get windows event log details

.DESCRIPTION
Get windows event log details

.PARAMETER Serverlist
List of servers to query.

.PARAMETER Days
Limit the report to this time frame. 

.PARAMETER Export
Export the result to a report file. (Excel, html or Screen)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixServerEventLog -Serverlist $CTXCore -Days 1 

#>
Function Get-CitrixServerEventLog {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixServerEventLog')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string[]]$Serverlist,
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int32]$Days,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	[System.Collections.ArrayList]$ServerEvents = @()
	foreach ($server in $Serverlist) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Eventlog Details"

		$eventtime = (Get-Date).AddDays(-$days)
		$ctxevent = Get-WinEvent -ComputerName $server -FilterHashtable @{LogName = 'Application', 'System'; Level = 2, 3; StartTime = $eventtime } -ErrorAction SilentlyContinue | Select-Object MachineName, TimeCreated, LogName, ProviderName, Id, LevelDisplayName, Message
		$servererrors = $ctxevent | Where-Object -Property LevelDisplayName -EQ 'Error'
		$serverWarning = $ctxevent | Where-Object -Property LevelDisplayName -EQ 'Warning'
		$TopProfider = $ctxevent | Where-Object { $_.LevelDisplayName -EQ 'Warning' -or $_.LevelDisplayName -eq 'Error' } | Group-Object -Property ProviderName | Sort-Object -Property count -Descending | Select-Object Name, Count

		[void]$ServerEvents.Add([pscustomobject]@{
				ServerName  = ([System.Net.Dns]::GetHostByName(($server))).hostname
				Errors      = $servererrors.Count
				Warning     = $serverWarning.Count
				TopProfider = $TopProfider
				All         = $ctxevent
			})
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Eventlog Details"
	}

	if ($Export -eq 'Excel') { 
		$ServerEvents.TopProfider | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixServerEventLog-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName TopProfider -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
		$ServerEvents.All | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixServerEventLog-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName All -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
	}
	if ($Export -eq 'HTML') { 
		New-HTML -TitleText "CitrixServerEventLog-$(Get-Date -Format yyyy.MM.dd-HH.mm)" -FilePath $HTMLPath {
                   $ServerEvents | ForEach-Object {
                   New-HTMLTab -name "$($_.ServerName)" -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {
					   New-HTMLPanel -Content { New-HTMLTable -DataTable ($($_.TopProfider) | Sort-Object -Property TimeCreated -Descending) @TableSettings}
					   New-HTMLPanel -Content { New-HTMLTable -DataTable ($($_.All) | Sort-Object -Property TimeCreated -Descending) @TableSettings {
                            New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
                            New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange } }}
                    }
                } -Online -Encoding UTF8 -ShowHTML
	}
	if ($Export -eq 'Host') { 
		$CTXObject
	}
} #end Function

 
Export-ModuleMember -Function Get-CitrixServerEventLog
#endregion
 
#region Get-CitrixServerPerformance.ps1
############################################
# source: Get-CitrixServerPerformance.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Collects perform data for the core servers.

.DESCRIPTION
Collects perform data for the core servers.

.PARAMETER Export
Export the result to a report file. (Excel, html or Screen)

.PARAMETER ReportPath
Where to save the report.

.PARAMETER ComputerName
List of Computers to query.

.EXAMPLE
Get-CitrixServerPerformance -ComputerName $CTXCore

#>
Function Get-CitrixServerPerformance {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixServerPerformance')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string[]]$ComputerName,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)

	[System.Collections.ArrayList]$ServerPerfMon = @()
	foreach ($server in $ComputerName) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Performance Details for $($server.ToString())"
		$CtrList = @(
			'\Processor(_Total)\% Processor Time',
			'\memory\% committed bytes in use',
			'\LogicalDisk(C:)\% Free Space'
		)
		$perf = Get-Counter $CtrList -ComputerName $Server -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Services Details for $($server.ToString())"
		$services = [String]::Join(' ; ', ((Get-Service -ComputerName $Server | Where-Object {$_.starttype -eq 'Automatic' -and $_.status -eq 'Stopped'}).DisplayName))

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Uptime Details for $($server.ToString())"
		$OS = Get-CimInstance Win32_OperatingSystem -ComputerName $Server | Select-Object *
		$Uptime = (Get-Date) - ($OS.LastBootUpTime)
		$updays = [math]::Round($uptime.Days, 0)

		[void]$ServerPerfMon.Add([pscustomobject]@{
				DateCollected      = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
				ServerName         = $Server
				'CPU %'            = [Decimal]::Round(($perf[0].CookedValue), 2).tostring()
				'Memory %'         = [Decimal]::Round(($perf[1].CookedValue), 2).tostring()
				'C Drive % Free'   = [Decimal]::Round(($perf[2].CookedValue), 2).tostring()
				Uptime             = $updays.tostring()
				'Stopped Services' = $Services
			})
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Performance Details for $($server.ToString())"
	}
	$ServerPerfMon

	if ($Export -eq 'Excel') { 
		$ServerPerfMon | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixServerPerformance-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName CitrixServerPerformance -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
	}
	if ($Export -eq 'HTML') { 
		$ServerPerfMon | Out-HtmlView -DisablePaging -Title 'Server Performance' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixServerPerformance-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
	}
	if ($Export -eq 'Host') { 
		$ServerPerfMon
	}
} #end Function
 
Export-ModuleMember -Function Get-CitrixServerPerformance
#endregion
 
#region Get-CitrixSessionIcaRtt.ps1
############################################
# source: Get-CitrixSessionIcaRtt.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Creates a report of users sessions with a AVG IcaRttMS

.DESCRIPTION
Creates a report of users sessions with a AVG IcaRttMS

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER hours
Limit the report to this time fame

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
 Get-CitrixSessionIcaRtt -AdminServer $CTXDDC

#>
Function Get-CitrixSessionIcaRtt {
        [Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixSessionIcaRtt')]
        [OutputType([System.Object[]])]
        PARAM(
                [Parameter(Mandatory = $true)]
                [ValidateNotNull()]
                [ValidateNotNullOrEmpty()]
                [string]$AdminServer,
                [Parameter(Mandatory = $true)]
                [ValidateNotNull()]
                [ValidateNotNullOrEmpty()]
                [int32]$hours,
                [ValidateSet('Excel', 'HTML')]
                [string]$Export = 'Host',
                [ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
        )
        $mon = Get-CitrixMonitoringData -AdminServer $AdminServer -hours $hours

        [System.Collections.ArrayList]$IcaRttObject = @()
        foreach ($sessid in $mon.SessionMetrics.sessionid | Sort-Object -Unique) {
                try {
                        $session = $mon.Sessions | Where-Object {$_.SessionKey -like $sessid}
                        $user = $mon.Users | Where-Object {$_.id -like $session.userid}
                        $Measure = $mon.SessionMetrics | Where-Object {$_.SessionId -like $sessid} | Measure-Object -Property IcaRttMS -Average   
                        [void]$IcaRttObject.Add([pscustomobject]@{
                                        StartDate    = [datetime]$session.StartDate
                                        EndDate      = [datetime]$session.EndDate
                                        'AVG IcaRtt' = [math]::Round($Measure.Average)
                                        UserName     = $user.UserName
                                        UPN          = $user.Upn
                                })

                } catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
        }

        if ($Export -eq 'Excel') { $IcaRttObject | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixSessionIcaRtt-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Show }
        if ($Export -eq 'HTML') { $IcaRttObject | Out-HtmlView -DisablePaging -Title 'CitrixSessionIcaRtt' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixSessionIcaRtt-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
        if ($Export -eq 'Host') { $IcaRttObject }


} #end Function
 
Export-ModuleMember -Function Get-CitrixSessionIcaRtt
#endregion
 
#region Get-CitrixVDAUptime.ps1
############################################
# source: Get-CitrixVDAUptime.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Calculate the uptime of VDA Servers.

.DESCRIPTION
Calculate the uptime of VDA Servers. The script will filter out desktop machines and only report on severs. 
If the script cant remotely connect to the vda server, then the last registration date will be used.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixVDAUptime -AdminServer $CTXDDC

#>
Function Get-CitrixVDAUptime {
		[Cmdletbinding(HelpURI = "https://smitpi.github.io/XDHealthCheck/Get-CitrixVDAUptime")]
        [OutputType([System.Object[]])]
        PARAM(
            [Parameter(Mandatory = $true, Position = 0)]
            [ValidateNotNull()]
            [ValidateNotNullOrEmpty()]
            [string]$AdminServer,
            [ValidateSet('Excel', 'HTML')]
            [string]$Export = 'Host',
            [ValidateScript( { if (Test-Path $_) { $true }
                    else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                })]
            [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
        )
      try {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] VDA Uptime"	
		[System.Collections.ArrayList]$VDAUptime = @() 
		Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 1000000 | Where-Object {$_.DesktopGroupName -notlike $null -and $_.OSType -notlike "*10" -and $_.OSType -notlike "*11" } | ForEach-Object {
			try {	
				$OS = Get-CimInstance Win32_OperatingSystem -ComputerName $_.DNSName -ErrorAction Stop | Select-Object *
				$Uptime = New-TimeSpan -Start $OS.LastBootUpTime -End (Get-Date)
				$updays = [math]::Round($uptime.Days, 0)
			} catch {
				try {
					Write-Warning "`t`tUnable to remote to $($_.DNSName), defaulting uptime to LastRegistrationTime"
					$Uptime = New-TimeSpan -Start $_.LastRegistrationTime -End (Get-Date)
					$updays = [math]::Round($uptime.Days, 0)
				} catch {$updays = 'Unknown'}
			}


			[void]$VDAUptime.Add([pscustomobject]@{
					ComputerName         = $_.dnsname
					DesktopGroupName     = $_.DesktopGroupName
					SessionCount         = $_.SessionCount
					InMaintenanceMode    = $_.InMaintenanceMode
					MachineInternalState = $_.MachineInternalState
					Uptime               = $updays
					LastRegistrationTime = $_.LastRegistrationTime
				})
		}
	} catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}

	if ($Export -eq 'Excel') { $VDAUptime | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixVDAUptime-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Title 'CitrixVDAUptime' -WorksheetName CitrixVDAUptime -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3 }
	if ($Export -eq 'HTML') { $VDAUptime | Out-GridHtml -DisablePaging -Title "CitrixVDAUptime" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixVDAUptime-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $VDAUptime }


} #end Function
 
Export-ModuleMember -Function Get-CitrixVDAUptime
#endregion
 
#region Get-CitrixWorkspaceAppVersions.ps1
############################################
# source: Get-CitrixWorkspaceAppVersions.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Reports on the versions of workspace app your users are using to connect

.DESCRIPTION
Reports on the versions of workspace app your users are using to connect

.EXAMPLE
Get-CitrixWorkspaceAppVersions

#>
<#
.SYNOPSIS
Reports on the versions of workspace app your users are using to connect

.DESCRIPTION
Reports on the versions of workspace app your users are using to connect

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER hours
Limit the report to this time fame

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixWorkspaceAppVersions -AdminServer $CTXDDC

#>
Function Get-CitrixWorkspaceAppVersions {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixWorkspaceAppVersions')]
	[OutputType([System.Object[]])]
	PARAM(
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$AdminServer,
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[int32]$hours,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
	)
	$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -hours $hours


	$index = 1
	[string]$AllCount = $Connections.Count
	[System.Collections.ArrayList]$ClientObject = @()

	foreach ($connect in $mon.Connections) {
		$Userid = ($mon.Sessions | Where-Object { $_.SessionKey -like $connect.SessionKey}).UserId
		$userdetails = $mon.Users | Where-Object { $_.id -like $Userid }
		Write-Output "Collecting data $index of $AllCount"
		$index++
		[void]$ClientObject.Add([pscustomobject]@{
				Domain         = $userdetails.Domain
				UserName       = $userdetails.UserName
				Upn            = $userdetails.Upn
				FullName       = $userdetails.FullName
				ClientName     = $connect.ClientName
				ClientAddress  = $connect.ClientAddress
				ClientVersion  = $connect.ClientVersion
				ClientPlatform = $connect.ClientPlatform
				Protocol       = $connect.Protocol
			})
	}

	if ($Export -eq 'Excel') { $ClientObject | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\CitrixWorkspaceAppVersions-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -AutoSize -AutoFilter -Show }
	if ($Export -eq 'HTML') { $ClientObject | Out-HtmlView -DisablePaging -Title 'CitrixWorkspaceAppVersions' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixWorkspaceAppVersions-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $ClientObject }


} #end Function
 
Export-ModuleMember -Function Get-CitrixWorkspaceAppVersions
#endregion
 
#region Get-RDSLicenseInformation.ps1
############################################
# source: Get-RDSLicenseInformation.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Report on RDS License Usage

.DESCRIPTION
Report on RDS License Usage

.PARAMETER LicenseServer
RDS License server name.

.PARAMETER Export
Export the result to a report file. (Excel, html or Screen)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-RDSLicenseInformation -LicenseServer $RDSLicenseServer

#>
Function Get-RDSLicenseInformation {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-RDSLicenseInformation')]
	PARAM(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[string]$LicenseServer,
		[ValidateSet('Excel', 'HTML')]
		[string]$Export = 'Host',
		[ValidateScript( { if (Test-Path $_) { $true }
				else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
			})]
		[System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
		)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] RDS Details"
	try {
		$RDSLicense = Get-CimInstance Win32_TSLicenseKeyPack -ComputerName $LicenseServer -ErrorAction stop | Select-Object -Property TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses
	} catch {Write-Warning "Unable to connect to RDS License server: $($LicenseServer)"}
	$CTXObject = New-Object PSObject -Property @{
		'Per Device' = $RDSLicense | Where-Object { $_.TypeAndModel -eq 'RDS Per Device CAL' }
		'Per User'   = $RDSLicense | Where-Object { $_.TypeAndModel -eq 'RDS Per User CAL' }
	}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] RDS Details"

	if ($Export -eq 'Excel') { 
		$CTXObject.'Per Device' | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\RDSLicenseInformation-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName 'Per Device' -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
		$CTXObject.'Per User' | Export-Excel -Path $(Join-Path -Path $ReportPath -ChildPath "\RDSLicenseInformation-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx") -WorksheetName 'Per User' -AutoSize -AutoFilter -Title 'Machine Failures' -TitleBold -TitleSize 28
	}
	if ($Export -eq 'HTML') { 
		New-HTML -TitleText "RDSLicenseInformation-$(Get-Date -Format yyyy.MM.dd-HH.mm)" -FilePath $(Join-Path -Path $ReportPath -ChildPath "\RDSLicenseInformation-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
				New-HTMLTab -Name "Per Device" -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {
					New-HTMLPanel -Content { New-HTMLTable -DataTable $($CTXObject.'Per Device') @TableSettings}
				}
				New-HTMLTab -Name "Per User" -TextTransform uppercase -IconSolid cloud-sun-rain -TextSize 16 -TextColor '#00203F' -IconSize 16 -IconColor '#ADEFD1' -HtmlData {
					New-HTMLPanel -Content { New-HTMLTable -DataTable $($CTXObject.'Per User') @TableSettings}
				}
		} -Online -Encoding UTF8 -ShowHTML        
	}
	if ($Export -eq 'Host') { 
		$CTXObject
	}


} #end Function

 
Export-ModuleMember -Function Get-RDSLicenseInformation
#endregion
 
#region Import-ParametersFile.ps1
############################################
# source: Import-ParametersFile.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Import the config file and creates the needed variables

.DESCRIPTION
Import the config file and creates the needed variables

.PARAMETER JSONParameterFilePath
Path to the json config file, created by Install-ParametersFile

.PARAMETER RedoCredentials
Deletes the saved credentials, and allow you to recreate them.

.EXAMPLE
Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath

#>
Function Import-ParametersFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Import-ParametersFile')]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + '\Parameters.json',
		[Parameter(Mandatory = $false, Position = 1)]
		[switch]$RedoCredentials = $false
	)

	$JSONParameter = Get-Content ($JSONParameterFilePath) | ConvertFrom-Json
	if ($null -eq $JSONParameter) { Write-Error 'Valid Parameters file not found'; break }

	Write-Color 'Using Variables from Parameters.json: ', $JSONParameterFilePath.ToString() -ShowTime -Color DarkCyan, DarkYellow -LinesAfter 1
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"
	$JSONParameter.PSObject.Properties | Where-Object { $_.name -notlike 'TrustedDomains' } | ForEach-Object { Write-Color $_.name, ':', $_.value -Color Yellow, DarkCyan, Green -ShowTime; New-Variable -Name $_.name -Value $_.value -Force -Scope global }
	New-Variable -Name 'JSONParameterFilePath' -Value $JSONParameterFilePath -Scope global -Force

	$global:CTXAdmin = Find-Credential | Where-Object target -Like '*CTXAdmin' | Get-Credential -Store
	if ($null -eq $CTXAdmin) {
		$AdminAccount = BetterCredentials\Get-Credential -Message 'Admin Account: DOMAIN\Username for CTX Admin'
		Set-Credential -Credential $AdminAccount -Target 'CTXAdmin' -Persistence LocalComputer -Description 'Account used for Citrix queries' -Verbose
	}
	Write-Color 'Citrix Admin Credentials: ', $CTXAdmin.UserName -ShowTime -Color yellow, Green

	if ($SendEmail) {
		$global:SMTPClientCredentials = Find-Credential | Where-Object target -Like '*Healthcheck_smtp' | Get-Credential -Store
		if ($null -eq $SMTPClientCredentials) {
			$Account = BetterCredentials\Get-Credential -Message 'smtp login for HealthChecks email'
			Set-Credential -Credential $Account -Target 'Healthcheck_smtp' -Persistence LocalComputer -Description 'Account used for XD health checks' -Verbose
		}
		Write-Color 'SMTP Credentials: ', $SMTPClientCredentials.UserName -ShowTime -Color yellow, Green -LinesBefore 2

	}

	if ($RedoCredentials) {
		foreach ($domain in $JSONParameter.TrustedDomains) { Find-Credential | Where-Object target -Like ('*' + $domain.Description.tostring()) | Remove-Credential -Verbose }
		Find-Credential | Where-Object target -Like '*CTXAdmin' | Remove-Credential -Verbose
		Find-Credential | Where-Object target -Like '*NSAdmin' | Remove-Credential -Verbose
	}

} #end Function

 
Export-ModuleMember -Function Import-ParametersFile
#endregion
 
#region Install-ParametersFile.ps1
############################################
# source: Install-ParametersFile.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Create a json config file with all needed farm details.

.DESCRIPTION
Create a json config file with all needed farm details.

.EXAMPLE
Install-ParametersFile

#>
function Install-ParametersFile {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Install-ParametersFile')]
	param ()

	[string]$CTXDDC = Read-Host 'A Citrix Data Collector FQDN'
	$CTXStoreFront = @()
	$ClientInput = ''
	While ($ClientInput.ToLower() -ne 'n') {
		$CTXStoreFront += Read-Host 'A Citrix StoreFront FQDN'
		$ClientInput = Read-Host 'Add more StoreFont Servers (y/n)'
	}
	
	[string]$RDSLicenseServer = Read-Host 'RDS LicenseServer FQDN'

	Write-Color -Text 'Add RDS License Type' -Color DarkGray -LinesAfter 1
	Write-Color '1: ', 'Per Device' -Color Yellow, Green
	Write-Color '2: ', 'Per User' -Color Yellow, Green
	$selection = Read-Host 'Please make a selection'
	switch ($selection) {
		'1' { [string]$RDSLicenseType = 'Per Device' }
		'2' { [string]$RDSLicenseType = 'Per User' }
	}
	$trusteddomains = @()
	$ClientInput = ''
	While ($ClientInput -ne 'n') {
		If ($null -ne $ClientInput) {
			$FQDN = Read-Host 'FQDN for the domain'
			$NetBiosName = Read-Host 'Net Bios Name for Domain '
			$CusObject = New-Object PSObject -Property @{
				FQDN        = $FQDN
				NetBiosName = $NetBiosName
				Description = $NetBiosName + '_ServiceAccount'
			} | Select-Object FQDN, NetBiosName, Description
			$trusteddomains += $CusObject
			$ClientInput = Read-Host 'Add more trusted domains? (y/n)'
		}
	}

	$ReportsFolder = Read-Host 'Path to the Reports Folder'
	$ParametersFolder = Read-Host 'Path to where the Parameters.json will be saved'
	$DashboardTitle = Read-Host 'Title to be used in the reports and Dashboard'
	$RemoveOldReports = Read-Host 'Remove Reports older than (in days)'

	Write-Color -Text 'Save reports to an excel report' -Color DarkGray -LinesAfter 1
	Write-Color '1: ', 'Yes' -Color Yellow, Green
	Write-Color '2: ', 'No' -Color Yellow, Green
	$selection = Read-Host 'Please make a selection'
	switch ($selection) {
		'1' { $SaveExcelReport = $true }
		'2' { $SaveExcelReport = $false }
	}

	Write-Color -Text 'Send Report via email' -Color DarkGray -LinesAfter 1
	Write-Color '1: ', 'Yes' -Color Yellow, Green
	Write-Color '2: ', 'No' -Color Yellow, Green
	$selection = Read-Host 'Please make a selection'
	switch ($selection) {
		'1' { $SendEmail = $true }
		'2' { $SendEmail = $false }
	}

	if ($SendEmail -eq 'true') {
		$emailFromA = Read-Host 'Email Address of the Sender'
		$emailFromN = Read-Host 'Full Name of the Sender'
		$FromAddress = $emailFromN + ' <' + $emailFromA + '>'

		$ToAddress = @()
		$ClientInput = ''
		While ($ClientInput -ne 'n') {
			If ($null -ne $ClientInput) {
				$emailtoA = Read-Host 'Email Address of the Recipient'
				$emailtoN = Read-Host 'Full Name of the Recipient'
				$ToAddress += $emailtoN + ' <' + $emailtoA + '>'
			}
			$ClientInput = Read-Host 'Add more recipients? (y/n)'
		}

		$smtpServer = Read-Host 'IP or name of SMTP server'
		$smtpServerPort = Read-Host 'Port of SMTP server'
		Write-Color -Text 'Use ssl for SMTP' -Color DarkGray -LinesAfter 1
		Write-Color '1: ', 'Yes' -Color Yellow, Green
		Write-Color '2: ', 'No' -Color Yellow, Green
		$selection = Read-Host 'Please make a selection'
		switch ($selection) {
			'1' { $smtpEnableSSL = $true }
			'2' { $smtpEnableSSL = $false }
		}
	}
	$AllXDData = New-Object PSObject -Property @{
		DateCollected    = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		CTXDDC           = $CTXDDC
		CTXStoreFront    = $CTXStoreFront
		RDSLicenseServer = $RDSLicenseServer
		RDSLicenseType   = $RDSLicenseType
		TrustedDomains   = $trusteddomains
		ReportsFolder    = $ReportsFolder
		ParametersFolder = $ParametersFolder
		DashboardTitle   = $DashboardTitle
		RemoveOldReports = $RemoveOldReports
		SaveExcelReport  = $SaveExcelReport
		SendEmail        = $SendEmail
		EmailFrom        = $FromAddress
		EmailTo          = $ToAddress
		SMTPServer       = $smtpServer
		SMTPServerPort   = $smtpServerPort
		SMTPEnableSSL    = $smtpEnableSSL
	} | Select-Object DateCollected, CTXDDC , CTXStoreFront , RDSLicenseServer , RDSLicenseType, TrustedDomains , ReportsFolder , ParametersFolder , DashboardTitle, RemoveOldReports, SaveExcelReport , SendEmail , EmailFrom , EmailTo , SMTPServer , SMTPServerPort , SMTPEnableSSL

	$ParPath = Join-Path -Path $ParametersFolder -ChildPath "\Parameters.json"
	if (Test-Path -Path $ParPath ) { Rename-Item $ParPath -NewName "Parameters_$(Get-Date -Format ddMMyyyy_HHmm).json" }
	else { $AllXDData | ConvertTo-Json -Depth 5 | Out-File -FilePath $ParPath -Force }

	Import-ParametersFile -JSONParameterFilePath $ParPath

}



 
Export-ModuleMember -Function Install-ParametersFile
#endregion
 
#region Set-XDHealthReportColors.ps1
############################################
# source: Set-XDHealthReportColors.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Set the color and logo for HTML Reports

.DESCRIPTION
Set the color and logo for HTML Reports. It updates the registry keys in HKCU:\Software\XDHealth with the new details and display a test report.

.PARAMETER Color1
New Background Color # code

.PARAMETER Color2
New foreground Color # code

.PARAMETER LogoURL
URL to the new Logo

.EXAMPLE
Set-XDHealthReportColors -Color1 '#d22c26' -Color2 '#2bb74e' -LogoURL 'https://gist.githubusercontent.com/default-monochrome.png'

#>
Function Set-XDHealthReportColors {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Set-XDHealthReportColors')]
	[Cmdletbinding()]
	PARAM(
		[string]$Color1 = '#061820',
		[string]$Color2 = '#FFD400',
		[string]$LogoURL = 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome.png'
	)
    if (Test-Path HKCU:\Software\XDHealth) {
    	Set-ItemProperty -Path HKCU:\Software\XDHealth -Name Color1 -Value $($Color1)
	    Set-ItemProperty -Path HKCU:\Software\XDHealth -Name Color2 -Value $($Color2)
	    Set-ItemProperty -Path HKCU:\Software\XDHealth -Name LogoURL -Value $($LogoURL)
    } else {
        New-Item -Path HKCU:\Software\XDHealth
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color1 -Value $($Color1)
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color2 -Value $($Color2)
        New-ItemProperty -Path HKCU:\Software\XDHealth -Name LogoURL -Value $($LogoURL)
    }
    $global:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
    $global:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
    $global:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL


#region Html Settings
$global:TableSettings = @{
	Style           = 'cell-border'
	TextWhenNoData  = 'No Data to display here'
	Buttons         = 'searchBuilder', 'pdfHtml5', 'excelHtml5'
	AutoSize        = $true
	DisableSearch   = $true
	FixedHeader     = $true
	HideFooter      = $true
	ScrollCollapse  = $true
	ScrollX         = $true
	ScrollY         = $true
	SearchHighlight = $true
}
$global:SectionSettings = @{
	BackgroundColor       = 'grey'
	CanCollapse           = $true
	HeaderBackGroundColor = $XDHealth_Color1
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = $XDHealth_Color2
	HeaderTextSize        = '20'
	BorderRadius          = '25px'
}
$global:TableSectionSettings = @{
	BackgroundColor       = 'white'
	CanCollapse           = $true
	HeaderBackGroundColor = $XDHealth_Color2
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = $XDHealth_Color1
	HeaderTextSize        = '20'
}
#endregion
	[string]$HTMLReportname = $env:TEMP + '\Test-color' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html'

	$HeadingText = 'Test | Report | ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)

	New-HTML -TitleText 'Report' -FilePath $HTMLReportname -ShowHTML {
		New-HTMLLogo -RightLogoString $XDHealth_LogoURL
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
		New-HTMLSection @SectionSettings -HeaderText 'Test' -Content {
			New-HTMLSection -HeaderText 'Test2' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable (Get-Process | Select-Object -First 5) }
			New-HTMLSection -HeaderText 'Test3' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable (Get-Service | Select-Object -First 5) }
		}
	}

} #end Function
 
Export-ModuleMember -Function Set-XDHealthReportColors
#endregion
 
#region Start-CitrixAudit.ps1
############################################
# source: Start-CitrixAudit.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Creates and distributes  a report on catalog, groups and published app config.

.DESCRIPTION
Creates and distributes  a report on catalog, groups and published app config.

.PARAMETER JSONParameterFilePath
Path to the json config file, created by Install-ParametersFile

.EXAMPLE
Start-CitrixAudit -JSONParameterFilePath 'C:\temp\Parameters.json'

#>
function Start-CitrixAudit {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Start-CitrixAudit')]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + '\Parameters.json'
	)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"
	##########################################
	#region xml imports
	##########################################
	Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath
	#endregion

	##########################################
	#region checking folders and report names
	##########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"

	if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFolder\logs\XDAudit_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.log'
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();

	if ((Test-Path -Path $ReportsFolder\XDAudit) -eq $false) { New-Item -Path "$ReportsFolder\XDAudit" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	if ([bool]$RemoveOldReports) {
		$oldReports = (Get-Date).AddDays(-$RemoveOldReports)
		Get-ChildItem $ReportsFolder\XDAudit *.html | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDAudit *.xlsx | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDAudit *.xml | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\logs\XDAudit_TransmissionLogs* | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
	}

	[string]$Reportname = $ReportsFolder + '\XDAudit\XD_Audit.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html'
	[string]$XMLExport = $ReportsFolder + '\XDAudit\XD_Audit.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xml'
	[string]$ExcelReportname = $ReportsFolder + '\XDAudit\XD_Audit.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx'

	#endregion

	########################################
	#region Getting Credentials
	#########################################


	#endregion

	########################################
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
	$CitrixObjects = Get-CitrixObjects -AdminServer $CTXDDC

	$MachineCatalog = $CitrixObjects.MachineCatalog | Select-Object MachineCatalogName, AllocationType, SessionSupport, UnassignedCount, UsedCount, MasterImageVM, MasterImageSnapshotName, MasterImageSnapshotCount, MasterImageVMDate
	$DeliveryGroups = $CitrixObjects.DeliveryGroups | Select-Object DesktopGroupName, Enabled, InMaintenanceMode, TotalApplications, TotalDesktops, DesktopsUnregistered, UserAccess, GroupAccess
	$PublishedApps = $CitrixObjects.PublishedApps | Select-Object DesktopGroupName, DesktopGroupUsersAccess, DesktopGroupGroupAccess, Enabled, ApplicationName, PublishedAppGroupAccess, PublishedAppUserAccess
	#endregion

	########################################
	#region saving data to xml
	########################################
	$AllXDData = New-Object PSObject -Property @{
		DateCollected     = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		MachineCatalog    = $CitrixObjects.MachineCatalog
		DeliveryGroups    = $CitrixObjects.DeliveryGroups
		PublishedApps     = $CitrixObjects.PublishedApps
		VDAServers        = $CitrixObjects.VDAServers
		VDAWorkstations   = $CitrixObjects.VDAWorkstations
		MachineCatalogSum = $MachineCatalog
		DeliveryGroupsSum = $DeliveryGroups
		PublishedAppsSum  = $PublishedApps
	}
	if (Test-Path -Path $XMLExport) { Remove-Item $XMLExport -Force -Verbose }
	$AllXDData | Export-Clixml -Path $XMLExport -Depth 25 -NoClobber -Force
	#endregion

	########################################
	#region Setting some table color and settings
	########################################

	

	#######################
	#region Building HTML the report
	#######################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"

	$HeadingText = $DashboardTitle + ' | XenDesktop Audit | ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)
	New-HTML -TitleText 'XenDesktop Audit' -FilePath $Reportname {
		New-HTMLLogo -RightLogoString $XDHealth_LogoURL
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Machine Catalogs' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $MachineCatalog }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $DeliveryGroups }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Published Apps' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $PublishedApps }
		}
	}
	#endregion

	#######################
	#region Saving Excel report
	#######################
	if ($SaveExcelReport) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Saving Excel Report"
		$AllXDData.MachineCatalog | Export-Excel -Path $ExcelReportname -AutoSize -AutoFilter -Title 'MachineCatalog' -WorksheetName MachineCatalog -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
		$AllXDData.DeliveryGroups | Export-Excel -Path $ExcelReportname -AutoSize -AutoFilter -Title 'DeliveryGroups' -WorksheetName DeliveryGroups -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
		$AllXDData.PublishedApps | Export-Excel -Path $ExcelReportname -AutoSize -AutoFilter -Title 'PublishedApps' -WorksheetName PublishedApps -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
		$AllXDData.VDAServers | Export-Excel -Path $ExcelReportname -AutoSize -AutoFilter -Title 'VDAServers' -WorksheetName VDAServers -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
		$AllXDData.VDAWorkstations | Export-Excel -Path $ExcelReportname -AutoSize -AutoFilter -Title 'VDAWorkstations' -WorksheetName VDAWorkstations -TitleBold -TitleSize 28 -TitleFillPattern LightTrellis -TableStyle Light20 -FreezeTopRow -FreezePane 3
	}
	#endregion
	
	#######################
	#region Sending email reports
	#######################
	if ($SendEmail) {

		$smtpClientCredentials = Find-Credential | Where-Object target -Like '*Healthcheck_smtp' | Get-Credential -Store
		if ($null -eq $smtpClientCredentials) {
			$Account = BetterCredentials\Get-Credential -Message 'smtp login for HealthChecks email'
			Set-Credential -Credential $Account -Target 'Healthcheck_smtp' -Persistence LocalComputer -Description 'Account used for ctx health checks' -Verbose
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Sending Report Email"
		$emailMessage = New-Object System.Net.Mail.MailMessage
		$emailMessage.From = $emailFrom
		$emailTo | ForEach-Object { $emailMessage.To.Add($_) }

		$emailMessage.Subject = $DashboardTitle + ' - Citrix Audit Results Report on ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy)
		$emailMessage.IsBodyHtml = $true
		$emailMessage.Body = 'Please see attached reports'
		$emailMessage.Attachments.Add($Reportname)
		$emailMessage.Attachments.Add($ExcelReportname)

		$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
		#$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
		$smtpClient.EnableSsl = $smtpEnableSSL
		$smtpClient.Timeout = 30000000
		$smtpClient.Send( $emailMessage )
	}
	#endregion

	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript
}


 
Export-ModuleMember -Function Start-CitrixAudit
#endregion
 
#region Start-CitrixHealthCheck.ps1
############################################
# source: Start-CitrixHealthCheck.ps1
# Module: XDHealthCheck
# version: 0.2.18
# Author: Pierre Smit
# Company: HTPCZA Tech
#############################################
 
<#
.SYNOPSIS
Creates and distributes  a report on citrix farm health.

.DESCRIPTION
Creates and distributes  a report on citrix farm health.

.PARAMETER JSONParameterFilePath
Path to the json config file, created by Install-ParametersFile

.EXAMPLE
Start-CitrixHealthCheck -JSONParameterFilePath 'C:\temp\Parameters.json'

#>
function Start-CitrixHealthCheck {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Start-CitrixHealthCheck')]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + '\Parameters.json'
	)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"
	##########################################
	#region xml imports
	##########################################
	Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath
	#endregion


	##########################################
	#region checking folders and report names
	##########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
	if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFolder\logs\XDHealth_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.log'
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();


	if ((Test-Path -Path $ReportsFolder\XDHealth) -eq $false) { New-Item -Path "$ReportsFolder\XDHealth" -ItemType Directory -Force -ErrorAction SilentlyContinue }

	if ([bool]$RemoveOldReports) {
		$oldReports = (Get-Date).AddDays(-$RemoveOldReports)
		Get-ChildItem $ReportsFolder\XDHealth *.html | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDHealth *.xlsx | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDHealth *.xml | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\logs\XDHealth_TransmissionLogs* | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
	}
	[string]$Reportname = $ReportsFolder + '\XDHealth\XD_Healthcheck.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html'
	[string]$AllXMLExport = $ReportsFolder + '\XDHealth\XD_All_Healthcheck.xml'
	[string]$ReportsXMLExport = $ReportsFolder + '\XDHealth\XD_Healthcheck.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xml'
	[string]$ExcelReportname = $ReportsFolder + '\XDHealth\XD_Healthcheck.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx'

	#endregion

	########################################
	#region Build other variables
	#########################################

	if (-not(Get-PSSnapin -Registered | Where-Object {$_.name -like 'Citrix*'})) {Add-PSSnapin citrix* -ErrorAction SilentlyContinue}

	[array]$CTXControllers = (Get-BrokerController -AdminAddress $CTXDDC).dnsname
	[array]$CTXLicenseServer = (Get-BrokerSite -AdminAddress $AdminServer).LicenseServerName
	$CTXCore = @()
	$CTXCore = $CTXControllers + $CTXStoreFront + $CTXLicenseServer | Sort-Object -Unique
	#endregion

	########################################
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting License Details"
	$CitrixLicenseInformation = Get-CitrixLicenseInformation -AdminServer $CTXDDC 
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
	$CitrixRemoteFarmDetails = Get-CitrixFarmDetail -AdminServer $CTXDDC 
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Eventlog Details"
	$CitrixServerEventLogs = Get-CitrixServerEventLog -Serverlist $CTXCore -Days 1 
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting RDS Details"
	$RDSLicenseInformation = Get-RDSLicenseInformation -LicenseServer $RDSLicenseServer | ForEach-Object { $_.$RDSLicenseType } | Where-Object { $_.TotalLicenses -ne 4294967295 } | Select-Object TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Config changes Details"
	$CitrixConfigurationChanges = Get-CitrixConfigurationChange -AdminServer $CTXDDC -Indays 7
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Server Performance Details"
	$ServerPerformance = Get-CitrixServerPerformance -ComputerName $CTXCore
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Citrix Env Test Results"
	$CitrixEnvTestResults = Get-CitrixEnvTestResults -AdminServer $CTXDDC -Infrastructure
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Citrix VDA Uptimes"
	$CitrixVDAUptime = Get-CitrixVDAUptime -AdminServer $CTXDDC
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Failures"
	$Failures = Get-CitrixFailures -AdminServer $AdminServer -hours 24
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] app ver"
	$appver = Get-CitrixWorkspaceAppVersions -AdminServer $AdminServer -hours 24 | Where-Object {$_.ClientVersion -notlike $null}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] CitrixSessionIcaRtt"
	$CitrixSessionIcaRtt = Get-CitrixSessionIcaRtt -AdminServer $AdminServer -hours 24


	#endregion

	########################################
	#region Adding more reports / scripts
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Building Red Flags"
	Function Redflags {
		$RedFlags = @()
		$FlagReport = @()

		$CitrixLicenseInformation | Where-Object LicensesAvailable -LT 500 | ForEach-Object { $RedFlags += 'Citrix License Product: ' + $_.LicenseProductName + ', has ' + $_.LicensesAvailable + ' available licenses' }
		$RDSLicenseInformation | Where-Object AvailableLicenses -LT 500 | ForEach-Object { $RedFlags += $_.TypeAndModel + ', has ' + $_.AvailableLicenses + ' Licenses Available' }

		if ($null -eq $CitrixRemoteFarmDetails.SiteDetails.Summary.Name) { $RedFlags += "Could not connect to the Farm with server $CTXDDC" }
		else {
			if ($CitrixRemoteFarmDetails.DBConnection[0].Value -NE 'OK') { $RedFlags += 'Farm ' + $CitrixRemoteFarmDetails.SiteDetails.Summary.Name + " can't connect to Database" }
			$CitrixRemoteFarmDetails.Controllers.Summary | Where-Object 'Desktops Registered' -LT 100 | ForEach-Object { $RedFlags += $_.Name + ' ony have ' + $_.'Desktops Registered' + ' Desktops Registered' }
			$CitrixRemoteFarmDetails.Controllers.Summary | Where-Object State -NotLike 'Active' | ForEach-Object { $RedFlags += $_.name + ' is not active' }
			if ($CitrixRemoteFarmDetails.SessionCounts.'Unregistered Servers' -gt 0) { $RedFlags += 'There are ' + $CitrixRemoteFarmDetails.SessionCounts.'Unregistered Servers' + ' Hosted Shared Server(s) Unregistered' }
			if ($CitrixRemoteFarmDetails.SessionCounts.'Unregistered Desktops' -gt 0) { $RedFlags += 'There are ' + $CitrixRemoteFarmDetails.SessionCounts.'Unregistered Desktops' + ' VDI Desktop(s) Unregistered' }
			if (($CitrixRemoteFarmDetails.VDAUptime | Where-Object { $_.uptime -gt 7 }).count -gt 0) { $RedFlags += 'There are ' + (($CitrixRemoteFarmDetails.VDAUptime | Where-Object { $_.uptime -gt 7 }).count) + ' VDA servers needed a reboot' }
		}

		$CitrixServerEventLogs | Where-Object Errors -GT 100 | ForEach-Object { $RedFlags += $_.'ServerName' + ' have ' + $_.Errors + ' errors in the last 24 hours' }
		$ServerPerformance | Where-Object 'Stopped Services' -NE $null | ForEach-Object { $RedFlags += $_.Servername + ' has stopped Citrix Services' }
		foreach ($server in $ServerPerformance) {
			if ([int]$server.'CDrive % Free' -lt 10) { $RedFlags += $server.Servername + ' has only ' + $server.'CDrive % Free' + ' % free disk space on C Drive' }
			if ([int]$server.Uptime -gt 20) { $RedFlags += $server.Servername + ' was last rebooted ' + $server.uptime + ' Days ago' }
		}

		$index = 0
		foreach ($flag in $RedFlags) {
			$index = $index + 1
			$Object = New-Object PSCustomObject
			$Object | Add-Member -MemberType NoteProperty -Name '#' -Value $index.ToString()
			$Object | Add-Member -MemberType NoteProperty -Name 'Description' -Value $flag
			$FlagReport += $Object
		}
		$FlagReport
	}

	$flags = Redflags
	#endregion


	########################################
	#region Setting some table color and settings
	########################################

	#######################
	#region Building HTML the report
	#######################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"
	$emailbody = New-HTML -TitleText 'Red Flags' { New-HTMLTable @TableSettings -DataTable $flags }

	$HeadingText = $DashboardTitle + ' | XenDesktop Report | ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)
	New-HTML -TitleText 'XenDesktop Report' -FilePath $Reportname {
		New-HTMLLogo -RightLogoString $XDHealth_LogoURL
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Citrix Sessions' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.SessionCounts $Conditions_sessions }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Citrix Controllers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Controllers.Summary $Conditions_controllers }
			New-HTMLSection -HeaderText 'Citrix DB Connection' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DBConnection $Conditions_db }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Citrix Licenses' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixLicenseInformation $Conditions_ctxlicenses }
			New-HTMLSection -HeaderText 'RDS Licenses' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($RDSLicenseInformation | Select-Object TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses) }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Citrix Error Counts' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixServerEventLogs | Select-Object ServerName, Errors, Warning) $Conditions_events }
			New-HTMLSection -HeaderText 'Citrix Events Top Events' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixServerEventLogs.TopProfider | Select-Object -First $CTXCore.count) }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Connection Failure' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $Failures.ConnectionFails }
			New-HTMLSection -HeaderText 'Machine Failure' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $Failures.mashineFails }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Client Versions' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.AppVer }
			New-HTMLSection -HeaderText 'ICA Rtt' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.IcaRtt }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Citrix Config Changes in the last 7 days' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixConfigurationChanges.Summary | Where-Object { $_.name -ne '' } | Sort-Object count -Descending | Select-Object -First 5 -Property count, name) }
			New-HTMLSection -HeaderText 'Citrix Server Performance' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($ServerPerformance) $Conditions_performance }
		}
		New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText 'VDA Uptime' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixVDAUptime} }
		New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText 'Citrix Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DeliveryGroups $Conditions_deliverygroup } }
		New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText 'Citrix UnRegistered Desktops' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops } }
		New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText 'Citrix UnRegistered Servers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredServers } }
		New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText "Today`'s Reboot Schedule" @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $RebootSchedule } }
		New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText 'Environment Test' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixEnvTestResults.InfrastructureResults } }
	}
	#endregion

	#######################
	#region Saving Excel report
	#######################
	if ($SaveExcelReport) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Saving Excel Report"
		$excelfile = $CitrixServerEventLogs.All | Export-Excel -Path $ExcelReportname -WorksheetName EventsRawData -AutoSize -AutoFilter -Title 'Citrix Events' -TitleBold -TitleSize 20 -FreezePane 3 -IncludePivotTable -TitleFillPattern DarkGrid -PivotTableName 'Events Summery' -PivotRows MachineName, LevelDisplayName, ProviderName -PivotData @{'Message' = 'count' } -NoTotalsInPivot
		$excelfile += $CitrixConfigurationChanges.Filtered | Export-Excel -Path $ExcelReportname -WorksheetName ConfigChangeRawData -AutoSize -AutoFilter -Title 'Citrix Config Changes' -TitleBold -TitleSize 20 -FreezePane 3

	}
	#endregion

	#######################
	#region Sending email reports
	#######################
	if ($SendEmail) {

		$smtpClientCredentials = Find-Credential | Where-Object target -Like '*Healthcheck_smtp' | Get-Credential -Store
		if ($null -eq $smtpClientCredentials) {
			$Account = BetterCredentials\Get-Credential -Message 'smtp login for HealthChecks email'
			Set-Credential -Credential $Account -Target 'Healthcheck_smtp' -Persistence LocalComputer -Description 'Account used for ctx health checks' -Verbose
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Sending Report Email"
		$emailMessage = New-Object System.Net.Mail.MailMessage
		$emailMessage.From = $emailFrom
		$emailTo | ForEach-Object { $emailMessage.To.Add($_) }
		$emailMessage.Subject = $DashboardTitle + ' - Citrix Health Check Report on ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy)
		$emailMessage.IsBodyHtml = $true
		$emailMessage.Body = $emailbody
		$emailMessage.Attachments.Add($Reportname)
		$emailMessage.Attachments.Add($ExcelReportname)
		$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
		#$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
		$smtpClient.EnableSsl = $smtpEnableSSL
		$smtpClient.Timeout = 30000000
		$smtpClient.Send( $emailMessage )
	}
	#endregion

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending]Healthcheck Complete"

	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript
}
 
Export-ModuleMember -Function Start-CitrixHealthCheck
#endregion
 
#endregion
 
