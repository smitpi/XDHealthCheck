﻿#region Private Functions
#region DirectorCodes.ps1
########### Private Function ###############
# Source:           DirectorCodes.ps1
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 22:30:01
# ModifiedOn:       2022/05/24 00:34:09
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
    0   = 'AgentShutdown'
    1   = 'AgentSuspended'
    100	= 'IncompatibleVersion'
    101	= 'AgentAddressResolutionFailed'
    102	= 'AgentNotContactable'
    103	= 'AgentWrongActiveDirectoryOU'
    104	= 'EmptyRegistrationRequest'
    105	= 'MissingRegistrationCapabilities'
    106	= 'MissingAgentVersion'
    107	= 'InconsistentRegistrationCapabilities'
    108	= 'NotLicensedForFeature'
    109	= 'UnsupportedCredentialSecurityversion'
    110	= 'InvalidRegistrationRequest'
    111	= 'SingleMultiSessionMismatch'
    112	= 'FunctionalLevelTooLowForCatalog'
    113	= 'FunctionalLevelTooLowForDesktopGroup'
    200	= 'PowerOff'
    203	= 'AgentRejectedSettingsUpdate'
    206	= 'SessionPrepareFailure'
    207	= 'ContactLost'
    301	= 'BrokerRegistrationLimitReached'
    208	= 'SettingsCreationFailure'
    204	= 'SendSettingsFailure'
    2   = 'AgentRequested'
    201	= 'DesktopRestart'
    202	= 'DesktopRemoved'
    205	= 'SessionAuditFailure'
    300	= 'UnknownError'
    302	= 'RegistrationStateMismatch'
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
#endregion
#region Reports-Colors.ps1
########### Private Function ###############
# Source:           Reports-Colors.ps1
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:32
# ModifiedOn:       2022/05/24 00:34:05
############################################

if (Test-Path HKCU:\Software\XDHealth) {

	$script:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
	$script:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
	$script:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL

} else {
	New-Item -Path HKCU:\Software\XDHealth
	New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color1 -Value '#2b1200'
	New-ItemProperty -Path HKCU:\Software\XDHealth -Name Color2 -Value '#f37000'
	New-ItemProperty -Path HKCU:\Software\XDHealth -Name LogoURL -Value 'https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome.png'

	$script:XDHealth_Color1 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color1
	$script:XDHealth_Color2 = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name Color2
	$script:XDHealth_LogoURL = Get-ItemPropertyValue -Path HKCU:\Software\XDHealth -Name LogoURL
}


#region Html Settings
$script:TableSettings = @{
	Style           = 'cell-border'
	TextWhenNoData  = 'No Data to display here'
	Buttons         = 'searchBuilder', 'pdfHtml5', 'excelHtml5'
	FixedHeader     = $true
	HideFooter      = $true
	SearchHighlight = $true
	PagingStyle     = 'full'
	PagingLength    = 10
}
$script:SectionSettings = @{
	BackgroundColor       = 'grey'
	CanCollapse           = $true
	HeaderBackGroundColor = $XDHealth_Color1
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = $XDHealth_Color2
	HeaderTextSize        = '15'
	BorderRadius          = '20px'
}
$script:TableSectionSettings = @{
	BackgroundColor       = 'white'
	CanCollapse           = $true
	HeaderBackGroundColor = $XDHealth_Color2
	HeaderTextAlignment   = 'center'
	HeaderTextColor       = $XDHealth_Color1
	HeaderTextSize        = '15'
}
$script:TabSettings = @{
    TextTransform             = 'uppercase'
    #IconSolid                 = 'file-export'
    IconBrands                = 'mix'
    TextSize                  = '16' 
    TextColor                 =  '#00203F'
    IconSize                  = '16'
    IconColor                 =  '#00203F'
}
#endregion


#endregion
#endregion
 
#region Public Functions
#region Get-CitrixConfigurationChange.ps1
######## Function 1 of 19 ##################
# Function:         Get-CitrixConfigurationChange
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 13:13:56
# ModifiedOn:       2022/09/09 03:14:14
# Synopsis:         Show the changes that was made to the farm
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
		$ReportTitle = 'Citrix Configuration Change'
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$CTXObject.Filtered | Export-Excel -Title CitrixConfigurationChange -WorksheetName CitrixConfigurationChange @ExcelOptions
	}
	if ($Export -eq 'HTML') { 
		$ReportTitle = 'Citrix Configuration Change'
		$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
		New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
				New-HTMLLogo -RightLogoString $XDHealth_LogoURL
			}
			if ($CTXObject.Filtered) { New-HTMLTab -Name 'Ctx Changes' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($CTXObject.Filtered) @TableSettings}}}
		}
	}
	if ($Export -eq 'Host') { 
		$CTXObject
	}
}
 
Export-ModuleMember -Function Get-CitrixConfigurationChange
#endregion
 
#region Get-CitrixConnectionFailures.ps1
######## Function 2 of 19 ##################
# Function:         Get-CitrixConnectionFailures
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 22:57:00
# ModifiedOn:       2022/05/24 00:01:58
# Synopsis:         Creates a report from monitoring data about machine and connection failures
#############################################
 
<#
.SYNOPSIS
Creates a report from monitoring data about machine and connection failures

.DESCRIPTION
Creates a report from monitoring data about machine and connection failures

.PARAMETER MonitorData
Use Get-CitrixMonitoringData to create OData, and use that variable in this parameter.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER SessionCount
Will collect data for the last x amount of sessions.

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
$monitor = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount 50
Get-CitrixConnectionFailures -MonitorData $monitor

#>
Function Get-CitrixConnectionFailures {
    [Cmdletbinding(DefaultParameterSetName = 'Fetch odata', HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixConnectionFailures')]
    [OutputType([System.Object[]])]
    PARAM(
        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [PSTypeName('CTXMonitorData')]$MonitorData,

        [Parameter(Mandatory = $true, ParameterSetName = 'Fetch odata')]
        [string]$AdminServer,

        [Parameter(Mandatory = $true, ParameterSetName = 'Fetch odata')]
        [int32]$SessionCount,

        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Fetch odata')]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',

        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Fetch odata')]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )					

    if (-not($MonitorData)) {
        try {
            $mon = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount $SessionCount
        } catch {$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount $SessionCount -AllowUnencryptedAuthentication}
    } else {$Mon = $MonitorData}

    $ConnectionFailure = $mon.Connections.Where({$_.ConnectionFailureLog -notlike $null})
    if ($ConnectionFailure.count -eq 0) {Write-Warning 'No connection Failures during this time frame'}
    else {
        [System.Collections.ArrayList]$ConnectionFails = @()
        foreach ($CFail in $ConnectionFailure.ConnectionFailureLog) {
            Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Connection Failures $($ConnectionFailure.ConnectionFailureLog.IndexOf($CFail)) of $($ConnectionFailure.ConnectionFailureLog.count)"
            try {
                $user = Invoke-RestMethod -Method Get -Uri "$($CFail.User.__deferred.uri)?`$format=json" -UseDefaultCredentials
                $device = Invoke-RestMethod -Method Get -Uri "$($CFail.Machine.__deferred.uri)?`$format=json" -UseDefaultCredentials
            } catch {
                $user = Invoke-RestMethod -Method Get -Uri "$($CFail.User.__deferred.uri)?`$format=json" -UseDefaultCredentials -AllowUnencryptedAuthentication
                $device = Invoke-RestMethod -Method Get -Uri "$($CFail.Machine.__deferred.uri)?`$format=json" -UseDefaultCredentials -AllowUnencryptedAuthentication
            }
            [void]$ConnectionFails.Add([pscustomobject]@{
                    UserName       = $user.UserName
                    Upn            = $user.Upn
                    Name           = $device.Name
                    IP             = $device.IPAddress
                    FailureDate    = [datetime]$CFail.FailureDate
                    FailureDetails = $SessionFailureCode[$CFail.ConnectionFailureEnumValue]
                })
        }
    }


    if ($Export -eq 'Excel') { 
        $ExcelOptions = @{
            Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_Connection_Failures-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
            AutoSize         = $True
            AutoFilter       = $True
            TitleBold        = $True
            TitleSize        = '28'
            TitleFillPattern = 'LightTrellis'
            TableStyle       = 'Light20'
            FreezeTopRow     = $True
            FreezePane       = '3'
        }
        if ($ConnectionFails) {$ConnectionFails | Export-Excel -Title ConnectionFailures -WorksheetName ConnectionFailures @ExcelOptions}
    }
    if ($Export -eq 'HTML') { 
        $ReportTitle = 'Citrix Connection Failures'
        $HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
        New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
            New-HTMLHeader {
                New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
                New-HTMLLogo -RightLogoString $XDHealth_LogoURL
            }
            if ($ConnectionFails) { New-HTMLTab -Name 'Connection Failures' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($ConnectionFails) @TableSettings}}}
        }
    }
    if ($Export -eq 'Host') { 
        [pscustomobject]@{
            ConnectionFails = $ConnectionFails
        }
    }
} #end Function
 
Export-ModuleMember -Function Get-CitrixConnectionFailures
#endregion
 
#region Get-CitrixEnvTestResults.ps1
######## Function 3 of 19 ##################
# Function:         Get-CitrixEnvTestResults
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/06 08:38:57
# ModifiedOn:       2022/05/24 00:02:10
# Synopsis:         Perform and report on tests on catalogs, delivery groups, hypervisor and Infrastructure
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
        $ExcelOptions = @{
            Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_Env_Test_Results-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
            AutoSize         = $true
            AutoFilter       = $true
            TitleBold        = $true
            TitleSize        = '28' 
            TitleFillPattern = 'LightTrellis' 
            TableStyle       = 'Light20' 
            FreezeTopRow     = $true
            FreezePane       = '3'
        }
        if ($catalogResults) { $catalogResults | Export-Excel -Title 'Catalog Results' -WorksheetName 'Catalog' @ExcelOptions}
        if ($DesktopGroupResults) { $DesktopGroupResults | Export-Excel -Title 'DesktopGroup Results' -WorksheetName DesktopGroup @ExcelOptions }
        if ($HypervisorConnectionResults) { $HypervisorConnectionResults | Export-Excel -Title 'Hypervisor Connection Results' -WorksheetName Hypervisor @ExcelOptions }
        if ($InfrastructureResults) { $InfrastructureResults | Export-Excel -Title 'Infrastructure Results' -WorksheetName Infrastructure @ExcelOptions }
    }
    if ($Export -eq 'HTML') { 
        $ReportTitle = 'Citrix Env Test Results'
        $HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
        New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
            New-HTMLHeader {
                New-HTMLText -FontSize 20 -FontStyle oblique -Color '#00203F' -Alignment left -Text $HeadingText
                New-HTMLLogo -RightLogoString $XDHealth_LogoURL
            }
            if ($catalogResults) { New-HTMLTab -Name 'Catalog Results' @TableSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($catalogResults) @TableSettings}}}
            if ($DesktopGroupResults) { New-HTMLTab -Name 'DesktopGroup Results' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($DesktopGroupResults) @TableSettings}}}
            if ($HypervisorConnectionResults) { New-HTMLTab -Name 'Hypervisor Connection Results' $TableSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($HypervisorConnectionResults) @TableSettings}}}
            if ($InfrastructureResults) { New-HTMLTab -Name 'Infrastructure Results' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($InfrastructureResults) @TableSettings}}}
        }
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
 
#region Get-CitrixFarmDetail.ps1
######## Function 4 of 19 ##################
# Function:         Get-CitrixFarmDetail
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 23:57:06
# ModifiedOn:       2022/05/23 21:20:21
# Synopsis:         Get needed Farm details.
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

	Write-Verbose "[$(Get-Date -Format HH:mm:ss) BEGIN] Starting $($myinvocation.mycommand)"
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
		Get-BrokerRebootScheduleV2 -AdminAddress $AdminServer | ForEach-Object {
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
		} | Select-Object 'Active Sessions', 'Disconnected Sessions', 'Connection Failures', 'Unregistered Servers', 'Unregistered Desktops'
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
######## Function 5 of 19 ##################
# Function:         Get-CitrixLicenseInformation
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 13:14:16
# ModifiedOn:       2022/05/24 00:03:33
# Synopsis:         Show Citrix License details
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
	[OutputType([System.Object[]])]
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
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_License_Information-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$LicDetails | Export-Excel -Title CitrixLicenseInformation -WorksheetName CitrixLicenseInformation @ExcelOptions
	}
	if ($Export -eq 'HTML') { 
		$ReportTitle = 'Citrix License Information'
		$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
		New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
				New-HTMLLogo -RightLogoString $XDHealth_LogoURL
			}
			if ($LicDetails) { New-HTMLTab -Name 'Ctx Changes' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($LicDetails) @TableSettings}}}
		}
	}
	if ($Export -eq 'Host') { 
		$LicDetails
	}
} #end Function
 
Export-ModuleMember -Function Get-CitrixLicenseInformation
#endregion
 
#region Get-CitrixMonitoringData.ps1
######## Function 6 of 19 ##################
# Function:         Get-CitrixMonitoringData
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 23:03:42
# ModifiedOn:       2022/05/20 20:58:22
# Synopsis:         Connects and collects data from the monitoring OData feed.
#############################################
 
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
 
Export-ModuleMember -Function Get-CitrixMonitoringData
#endregion
 
#region Get-CitrixObjects.ps1
######## Function 7 of 19 ##################
# Function:         Get-CitrixObjects
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:32
# ModifiedOn:       2022/05/23 22:27:00
# Synopsis:         Get details of citrix objects
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

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] XDSite"
	$XDSite = Get-XDSite -AdminAddress $adminserver
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] Controllers"
	$Controllers = $XDSite.Controllers | Select-Object DnsName,ControllerState,ControllerVersion,DesktopsRegistered,LastActivityTime,LastStartTime,OSType,OSVersion
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] Databases"
	$DataBases = $XDSite.Databases
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] Licenses"
	$Licenses = Get-XDLicensing -AdminAddress $adminserver | Select-Object LicenseServer,LicensingBurnInDate,LicensingModel,ProductCode,ProductEdition,ProductVersion

	#region Catalogs
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Machine Catalogs"
	[System.Collections.ArrayList]$CTXMachineCatalog = @()
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
		[void]$CTXMachineCatalog.Add([PSCustomObject]@{
			MachineCatalogName           = $MachineCatalog.name
			AllocationType               = $MachineCatalog.AllocationType
			Description                  = $MachineCatalog.Description
			MinimumFunctionalLevel       = $MachineCatalog.MinimumFunctionalLevel
			PersistUserChanges           = $MachineCatalog.PersistUserChanges
			ProvisioningType             = $MachineCatalog.ProvisioningType
			SessionSupport               = $MachineCatalog.SessionSupport
			UnassignedCount              = $MachineCatalog.UnassignedCount
			UsedCount                    = $MachineCatalog.UsedCount
			AssignedCount                = $MachineCatalog.AssignedCount
			AvailableCount               = $MachineCatalog.AvailableCount
			PvsAddress                   = $MachineCatalog.PvsAddress
			PvsDomain                    = $MachineCatalog.PvsDomain
			CleanOnBoot                  = $MasterImage.CleanOnBoot
			MasterImageVM                = $mastervm
			MasterImageSnapshotName      = $masterSnapshot
			MasterImageSnapshotCount     = $masterSnapshotcount
			MasterImageVMDate            = $MasterImage.MasterImageVMDate
			UseFullDiskCloneProvisioning = $MasterImage.UseFullDiskCloneProvisioning
			UseWriteBackCache            = $MasterImage.UseWriteBackCache
		})
	}
	#endregion

	#region desktop groups
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Delivery Groups"
	$BrokerDesktopGroup = Get-BrokerDesktopGroup -AdminAddress $AdminServer
	[System.Collections.ArrayList]$CTXDeliveryGroup = @()
	foreach ($DesktopGroup in $BrokerDesktopGroup) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Delivery Group: $($DesktopGroup.name.ToString())"
		$BrokerAccess = @()
		$BrokerGroups = @()
		$BrokerAccess = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -notlike '' } } | Select-Object UPN
		$BrokerGroups = Get-BrokerAccessPolicyRule -DesktopGroupUid $DesktopGroup.Uid -AdminAddress $AdminServer -AllowedConnections ViaAG | ForEach-Object { $_.IncludedUsers | Where-Object { $_.upn -Like '' } } | Select-Object Name
		[void]$CTXDeliveryGroup.Add([PSCustomObject]@{
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
		})
	}
	#endregion

	#region pub apps
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Application config"
		[System.Collections.ArrayList]$HostedApps = @()
		$PublishedApps = Get-BrokerApplication -AdminAddress $AdminServer
		foreach ($PublishedApp in $PublishedApps) {
			Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Published Application:$($PublishedApp.PublishedName.ToString())"
			[system.Collections.ArrayList]$DesktopGroups = @()
			[void]$DesktopGroups.Add(($PublishedApp.AssociatedDesktopGroupUids | ForEach-Object {(Get-BrokerDesktopGroup -Uid $($_)).name}))
			[System.Collections.ArrayList]$PublishedAppGroup = @()
			[System.Collections.ArrayList]$PublishedAppUser = @($PublishedApp.AssociatedUserNames | Where-Object { $_ -notlike $null })
			$index = 0
			foreach ($upn in $PublishedApp.AssociatedUserNames) {
				if ($null -like $upn) { $PublishedAppGroup += @($PublishedApp.AssociatedUserNames)[$index] }
				$index ++
			}
			[void]$HostedApps.Add([PSCustomObject]@{
				ApplicationName         = $PublishedApp.ApplicationName
				ApplicationType         = $PublishedApp.ApplicationType
				DesktopGroups           = @(($DesktopGroups) | Out-String).Trim()
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
			})
		}
	#endregion

	#region servers
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Server Details"
	[System.Collections.ArrayList]$VDAServers = @()
	Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 100000 | Where-Object { $_.OSType -like '*20*' } | ForEach-Object {
		[void]$VDAServers.Add([PSCustomObject]@{
			DNSName           = $_.DNSName
			CatalogName       = $_.CatalogName
			DesktopGroupName  = $_.DesktopGroupName
			IPAddress         = $_.IPAddress
			AgentVersion      = $_.AgentVersion
			OSType            = $_.OSType
			RegistrationState = $_.RegistrationState
			InMaintenanceMode = $_.InMaintenanceMode
		})
	}
#endregion

	#region desktops
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Begining] All Workstation Details"
	[System.Collections.ArrayList]$VDAWorkstations = @()
	Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 100000 | Where-Object { $_.OSType -notlike 'Windows 20*' } | ForEach-Object {
		[void]$VDAWorkstations.Add([PSCustomObject]@{
			DNSName             = $_.DNSName
			CatalogName         = $_.CatalogName
			DesktopGroupName    = $_.DesktopGroupName
			IPAddress           = $_.IPAddress
			AgentVersion        = $_.AgentVersion
			AssociatedUserNames = @(($_.AssociatedUserNames) | Out-String).Trim()
			OSType              = $_.OSType
			RegistrationState   = $_.RegistrationState
			InMaintenanceMode   = $_.InMaintenanceMode
		})
	}
	#endregion

	$ObjectCount = [PSCustomObject]@{
		Sitename        = $XDSite.name
		Controllers     = $Controllers.count
		Catalogs        = $CTXMachineCatalog.count
		DesktopGroup    = $CTXDeliveryGroup.count
		PublishedApps   = $HostedApps.count
		VDAServers      = $VDAServers.count
		VDAWorkstations = $VDAWorkstations.count
	}

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Published Applications"
	$CusObject = New-Object PSObject -Property @{
		DateCollected   = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
		ObjectCount     = $ObjectCount 
		Controllers		= $Controllers
		Databases       = $DataBases
		Licenses        = $Licenses
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
 
#region Get-CitrixResourceUtilizationSummary.ps1
######## Function 8 of 19 ##################
# Function:         Get-CitrixResourceUtilizationSummary
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/19 01:48:11
# ModifiedOn:       2022/05/24 00:29:41
# Synopsis:         Resource Utilization Summary for machines
#############################################
 
<#
.SYNOPSIS
Resource Utilization Summary for machines

.DESCRIPTION
Resource Utilization Summary for machines

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER hours
Limit the report to this time frame

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
Get-CitrixResourceUtilizationSummary -AdminServer $CTXDDC -hours 24 -Export Excel -ReportPath C:\temp

#>
Function Get-CitrixResourceUtilizationSummary {
    [Cmdletbinding(DefaultParameterSetName = 'Set1', HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixResourceUtilizationSummary')]
    [OutputType([System.Object[]])]
    PARAM(
        [Parameter(Mandatory = $true, ParameterSetName = 'Fetch odata')]
        [string]$AdminServer,

        [Parameter(Mandatory = $true, ParameterSetName = 'Fetch odata')]
        [int32]$hours,

        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Fetch odata')]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',

        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Fetch odata')]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )              
    
    $now = Get-Date -Format yyyy-MM-ddTHH:mm:ss.ffZ
    $past = ((Get-Date).AddHours(-$hours)).ToString('yyyy-MM-ddTHH:mm:ss.ffZ')
    $headers = @{ 'Accept' = 'application/json; odata=verbose'}

    $urisettings = @{
        UseDefaultCredentials = $true
        headers               = $headers
        Method                = 'Get'
    }

    $ResourceUtilizationSummary = (Invoke-RestMethod -Uri "http://$($AdminServer)/Citrix/Monitor/OData/v3/Data/ResourceUtilizationSummary?`$filter = CreatedDate ge datetime'$($past)' and CreatedDate le datetime'$($now)'" @urisettings).d
    [System.Collections.ArrayList]$ResourceUtilization = @()
    $grouped = $ResourceUtilizationSummary | Group-Object MachineId
    foreach ($resource in $grouped) {
        Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] ResourceUtilization $($grouped.IndexOf($resource)) of $($grouped.count)"
        $machine = (Invoke-RestMethod -Uri $resource.Group[0].Machine.__deferred.uri @urisettings).d
        [void]$ResourceUtilization.add([PSCustomObject]@{
                Name              = $machine.DnsName
                ObjectCount       = ($resource.group | Measure-Object -Property AvgPercentCpu -Average).count
                AvgPercentCpu     = [Decimal]::Round((($resource.group | Measure-Object -Property AvgPercentCpu -Average).Average))
                AvgUsedMemory     = [Decimal]::Round((($resource.group | Measure-Object -Property AvgUsedMemory -Average).Average) / 1gb, 2)
                AvgTotalMemory    = [Decimal]::Round((($resource.group | Measure-Object -Property AvgTotalMemory -Average).Average) / 1gb, 2)
                TotalSessionCount = [Decimal]::Round((($resource.group | Measure-Object -Property TotalSessionCount -Average).Average))
            })
    }


    if ($Export -eq 'Excel') { 
        $ExcelOptions = @{
            Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_Resource_Utilization_Summary-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
            AutoSize         = $True
            AutoFilter       = $True
            TitleBold        = $True
            TitleSize        = '28'
            TitleFillPattern = 'LightTrellis'
            TableStyle       = 'Light20'
            FreezeTopRow     = $True
            FreezePane       = '3'
        }
        if ($ResourceUtilization) { $ResourceUtilization | Export-Excel -Title ResourceUtilization -WorksheetName ResourceUtilization @ExcelOptions }
    }

    if ($Export -eq 'HTML') { 
        $ReportTitle = 'Citrix Resource Utilization Summary'
        $HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
        New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
            New-HTMLHeader {
                New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
                New-HTMLLogo -RightLogoString $XDHealth_LogoURL
            }
            if ($ResourceUtilization) { New-HTMLTab -Name 'Resource Utilization' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($ResourceUtilization) @TableSettings}}}
        }
        }
    if ($Export -eq 'Host') { $ResourceUtilization }


} #end Function
 
Export-ModuleMember -Function Get-CitrixResourceUtilizationSummary
#endregion
 
#region Get-CitrixServerEventLog.ps1
######## Function 9 of 19 ##################
# Function:         Get-CitrixServerEventLog
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 06:52:16
# ModifiedOn:       2022/09/09 03:14:15
# Synopsis:         Get windows event log details
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
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix Server Event Log-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$ServerEvents.TopProfider | Export-Excel -Title 'EventLog Top Profider' -WorksheetName TopProfider @ExcelOptions
		$ServerEvents.All | Export-Excel -Title 'Citrix Server Event Log' -WorksheetName All @ExcelOptions
	}
	if ($Export -eq 'HTML') { 
		$ReportTitle = 'Citrix Server Event Log'
        $HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
        New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
            New-HTMLHeader {
                New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
                New-HTMLLogo -RightLogoString $XDHealth_LogoURL
            }
			$ServerEvents | ForEach-Object {
				New-HTMLTab -Name "$($_.ServerName)" @TableSettings -HtmlData {
					New-HTMLPanel -Content { New-HTMLTable -DataTable ($($_.TopProfider) | Sort-Object -Property TimeCreated -Descending) @TableSettings}
					New-HTMLPanel -Content { New-HTMLTable -DataTable ($($_.All) | Sort-Object -Property TimeCreated -Descending) @TableSettings {
							New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'Error' -Color GhostWhite -Row -BackgroundColor FaluRed
							New-TableCondition -Name LevelDisplayName -ComparisonType string -Operator eq -Value 'warning' -Color GhostWhite -Row -BackgroundColor InternationalOrange } }}
			}
		}
	}
	if ($Export -eq 'Host') { $ServerEvents	}
} #end Function

 
Export-ModuleMember -Function Get-CitrixServerEventLog
#endregion
 
#region Get-CitrixServerPerformance.ps1
######## Function 10 of 19 ##################
# Function:         Get-CitrixServerPerformance
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 10:26:18
# ModifiedOn:       2022/09/09 03:14:15
# Synopsis:         Collects perform data for the core servers.
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
	[OutputType([System.Object[]])]
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
		$Uptime = New-TimeSpan -Start $OS.LastBootUpTime -End (Get-Date)
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
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_Server_Performance-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$ServerPerfMon | Export-Excel -Title CitrixServerPerformance -WorksheetName CitrixServerPerformance @ExcelOptions
	}
	if ($Export -eq 'HTML') {
		$ReportTitle = 'Citrix Server Performance'
        $HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
        New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
            New-HTMLHeader {
                New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
                New-HTMLLogo -RightLogoString $XDHealth_LogoURL
            }
            if ($ServerPerfMon) { New-HTMLTab -Name 'Performance' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($ServerPerfMon) @TableSettings}}}
        }
	}
	if ($Export -eq 'Host') {
		$ServerPerfMon
	}
} #end Function
 
Export-ModuleMember -Function Get-CitrixServerPerformance
#endregion
 
#region Get-CitrixSessionIcaRtt.ps1
######## Function 11 of 19 ##################
# Function:         Get-CitrixSessionIcaRtt
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 23:53:46
# ModifiedOn:       2022/05/24 00:10:08
# Synopsis:         Creates a report of users sessions with a AVG IcaRttMS
#############################################
 
<#
.SYNOPSIS
Creates a report of users sessions with a AVG IcaRttMS

.DESCRIPTION
Creates a report of users sessions with a AVG IcaRttMS

.PARAMETER MonitorData
Use Get-CitrixMonitoringData to create OData, and use that variable in this parameter.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER SessionCount
Will collect data for the last x amount of sessions.

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
                [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
                [PSTypeName('CTXMonitorData')]$MonitorData,

                [Parameter(Mandatory = $true, ParameterSetName = 'Fetch odata')]
                [string]$AdminServer,

                [Parameter(Mandatory = $true, ParameterSetName = 'Fetch odata')]
                [int32]$SessionCount,

                [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
                [Parameter(Mandatory = $false, ParameterSetName = 'Fetch odata')]
                [ValidateSet('Excel', 'HTML')]
                [string]$Export = 'Host',

                [ValidateScript( { if (Test-Path $_) { $true }
                                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
                        })]
                [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
                [Parameter(Mandatory = $false, ParameterSetName = 'Fetch odata')]
                [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
        )					

        if (-not($MonitorData)) {
                try {
                        $mon = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount $SessionCount
                } catch {$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount $SessionCount -AllowUnencryptedAuthentication}
        } else {$Mon = $MonitorData}

        [System.Collections.ArrayList]$IcaRttObject = @()
        $UniqueSession = $mon.Sessions.SessionMetrics | Sort-Object -Property SessionId -Unique
        foreach ($sessid in $UniqueSession) {
                Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Sessions $($UniqueSession.IndexOf($sessid)) of $($UniqueSession.count)"
                try {
                        $session = $mon.Sessions | Where-Object {$_.SessionKey -like $sessid.SessionId}
                        $user = ($mon.Sessions.User | Where-Object {$_.id -like $session.userid})[0]
                        $Measure = $mon.Sessions.SessionMetrics | Where-Object {$_.SessionId -like $sessid.SessionId} | Measure-Object -Property IcaRttMS -Average   
                        [void]$IcaRttObject.Add([pscustomobject]@{
                                        StartDate    = [datetime]$session.StartDate
                                        EndDate      = [datetime]$session.EndDate
                                        ObjectCount  = $Measure.Count
                                        'AVG IcaRtt' = [math]::Round($Measure.Average)
                                        UserName     = $user.UserName
                                        UPN          = $user.Upn
                                })

                } catch {Write-Warning "`n`tMessage:$($_.Exception.Message)`n`tItem:$($_.Exception.ItemName)"}
        }

        if ($Export -eq 'Excel') { 
                $ExcelOptions = @{
                        Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_Session_IcaRtt-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
                        AutoSize         = $True
                        AutoFilter       = $True
                        TitleBold        = $True
                        TitleSize        = '28'
                        TitleFillPattern = 'LightTrellis'
                        TableStyle       = 'Light20'
                        FreezeTopRow     = $True
                        FreezePane       = '3'
                }
                $IcaRttObject | Export-Excel -Title CitrixSessionIcaRtt -WorksheetName CitrixSessionIcaRtt @ExcelOptions
        }
        if ($Export -eq 'HTML') { 
                $ReportTitle = 'Citrix Session IcaRtt'
                $HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
                New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
                        New-HTMLHeader {
                                New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
                                New-HTMLLogo -RightLogoString $XDHealth_LogoURL
                        }
                        if ($IcaRttObject) { New-HTMLTab -Name 'ICA RTT' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($IcaRttObject) @TableSettings}}}
                }
        }
        if ($Export -eq 'Host') { $IcaRttObject }


} #end Function
 
Export-ModuleMember -Function Get-CitrixSessionIcaRtt
#endregion
 
#region Get-CitrixVDAUptime.ps1
######## Function 12 of 19 ##################
# Function:         Get-CitrixVDAUptime
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/09 12:55:37
# ModifiedOn:       2022/05/24 00:11:25
# Synopsis:         Calculate the uptime of VDA Servers.
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
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixVDAUptime')]
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
		Get-BrokerMachine -AdminAddress $AdminServer -MaxRecordCount 1000000 | Where-Object {$_.DesktopGroupName -notlike $null -and $_.OSType -notlike '*10' -and $_.OSType -notlike '*11' } | ForEach-Object {
			try {
				$ctxobject = $_	
				$OS = Get-CimInstance Win32_OperatingSystem -ComputerName $_.DNSName -ErrorAction Stop | Select-Object *
				$Uptime = New-TimeSpan -Start $OS.LastBootUpTime -End (Get-Date)
				$updays = [math]::Round($uptime.Days, 0)
			} catch {
				try {
					Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"
					Write-Warning "Unable to remote to $($ctxobject.DNSName), defaulting uptime to LastRegistrationTime"
					if ($ctxobject.RegistrationState -like 'Registered') {
						$Uptime = New-TimeSpan -Start $ctxobject.LastRegistrationTime -End (Get-Date)
						$updays = [math]::Round($uptime.Days, 0)
					} else {$updays = 'Unknown'}
				} catch {
					Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"
					$updays = 'Unknown'
    }
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

	if ($Export -eq 'Excel') { 
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_VDA_Uptime-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$VDAUptime | Export-Excel -Title CitrixVDAUptime -WorksheetName CitrixVDAUptime @ExcelOptions
 }
	if ($Export -eq 'HTML') { 
		$ReportTitle = 'Citrix VDA Uptime'
		$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
		New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
				New-HTMLLogo -RightLogoString $XDHealth_LogoURL
			}
			if ($VDAUptime) { New-HTMLTab -Name 'VDA Uptime' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($VDAUptime) @TableSettings}}}
		}
	}
	if ($Export -eq 'Host') { $VDAUptime }


} #end Function
 
Export-ModuleMember -Function Get-CitrixVDAUptime
#endregion
 
#region Get-CitrixWorkspaceAppVersions.ps1
######## Function 13 of 19 ##################
# Function:         Get-CitrixWorkspaceAppVersions
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 23:22:10
# ModifiedOn:       2022/05/24 00:12:25
# Synopsis:         Reports on the versions of workspace app your users are using to connect
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

.PARAMETER MonitorData
Use Get-CitrixMonitoringData to create OData, and use that variable in this parameter.

.PARAMETER AdminServer
FQDN of the Citrix Data Collector

.PARAMETER SessionCount
Will collect data for the last x amount of sessions.

.PARAMETER Export
Export the result to a report file. (Excel or html)

.PARAMETER ReportPath
Where to save the report.

.EXAMPLE
$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -hours $hours
Get-CitrixWorkspaceAppVersions -MonitorData $Mon

#>
Function Get-CitrixWorkspaceAppVersions {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Get-CitrixWorkspaceAppVersions')]
	[OutputType([System.Object[]])]
    PARAM(
        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [PSTypeName('CTXMonitorData')]$MonitorData,

        [Parameter(Mandatory = $true, ParameterSetName = 'Fetch odata')]
        [string]$AdminServer,

        [Parameter(Mandatory = $true, ParameterSetName = 'Fetch odata')]
        [int32]$SessionCount,

        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Fetch odata')]
        [ValidateSet('Excel', 'HTML')]
        [string]$Export = 'Host',

        [ValidateScript( { if (Test-Path $_) { $true }
                else { New-Item -Path $_ -ItemType Directory -Force | Out-Null; $true }
            })]
        [Parameter(Mandatory = $false, ParameterSetName = 'Got odata')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Fetch odata')]
        [System.IO.DirectoryInfo]$ReportPath = 'C:\Temp'
    )					

        if (-not($MonitorData)) {
                try {
                        $mon = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount $SessionCount
                } catch {$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount $SessionCount -AllowUnencryptedAuthentication}
        } else {$Mon = $MonitorData}


	[System.Collections.ArrayList]$ClientObject = @()
	foreach ($session in $mon.sessions) {
    Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Sessions $($mon.Sessions.IndexOf($session)) of $($mon.Sessions.count)"
		[void]$ClientObject.Add([pscustomobject]@{
				Domain         = $session.User.domain
				UserName       = $session.User.UserName
				Upn            = $session.User.Upn
				FullName       = $session.User.FullName
				ClientName     = $session.CurrentConnection.ClientName
				ClientAddress  = $session.CurrentConnection.ClientAddress
				ClientVersion  = $session.CurrentConnection.ClientVersion
				ClientPlatform = $session.CurrentConnection.ClientPlatform
				Protocol       = $session.CurrentConnection.Protocol
			})
	}

	if ($Export -eq 'Excel') {
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\Citrix_Workspace_App_Versions-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$ClientObject | Export-Excel -Title CitrixWorkspaceAppVersions -WorksheetName CitrixWorkspaceAppVersions @ExcelOptions}
	if ($Export -eq 'HTML') { 
		$ReportTitle = 'Citrix Workspace App Versions'
		$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
		New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
				New-HTMLLogo -RightLogoString $XDHealth_LogoURL
			}
			if ($ClientObject) { New-HTMLTab -Name 'App Versions' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($ClientObject) @TableSettings}}}
		}
	}
	if ($Export -eq 'Host') { $ClientObject }


} #end Function
 
Export-ModuleMember -Function Get-CitrixWorkspaceAppVersions
#endregion
 
#region Get-RDSLicenseInformation.ps1
######## Function 14 of 19 ##################
# Function:         Get-RDSLicenseInformation
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 10:26:40
# ModifiedOn:       2022/09/09 03:14:16
# Synopsis:         Report on RDS License Usage
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
		$ExcelOptions = @{
			Path             = $(Join-Path -Path $ReportPath -ChildPath "\RDS_License_Information-$(Get-Date -Format yyyy.MM.dd-HH.mm).xlsx")
			AutoSize         = $True
			AutoFilter       = $True
			TitleBold        = $True
			TitleSize        = '28'
			TitleFillPattern = 'LightTrellis'
			TableStyle       = 'Light20'
			FreezeTopRow     = $True
			FreezePane       = '3'
		}
		$CTXObject.'Per Device' | Export-Excel -Title 'Per Device' -WorksheetName 'Per Device' @ExcelOptions
		$CTXObject.'Per User' | Export-Excel -Title 'Per User' -WorksheetName 'Per User' @ExcelOptions
	}
	if ($Export -eq 'HTML') { 
		$ReportTitle = 'RDS_License_Information'
		$HeadingText = "$($ReportTitle) [$(Get-Date -Format dd) $(Get-Date -Format MMMM) $(Get-Date -Format yyyy) $(Get-Date -Format HH:mm)]"
		New-HTML -TitleText $($ReportTitle) -FilePath $(Join-Path -Path $ReportPath -ChildPath "\$($ReportTitle.Replace(' ','_'))-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") {
			New-HTMLHeader {
				New-HTMLText -FontSize 20 -FontStyle normal -Color '#00203F' -Alignment left -Text $HeadingText
				New-HTMLLogo -RightLogoString $XDHealth_LogoURL
			}
			if ($CTXObject.'Per Device') { New-HTMLTab -Name 'Per Device' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($CTXObject.'Per Device') @TableSettings}}}
			if ($CTXObject.'Per User') { New-HTMLTab -Name 'Per User' @TabSettings -HtmlData {New-HTMLSection @TableSectionSettings { New-HTMLTable -DataTable $($CTXObject.'Per User') @TableSettings}}}
		}     
	}
	if ($Export -eq 'Host') { 
		$CTXObject
	}


} #end Function

 
Export-ModuleMember -Function Get-RDSLicenseInformation
#endregion
 
#region Import-ParametersFile.ps1
######## Function 15 of 19 ##################
# Function:         Import-ParametersFile
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:32
# ModifiedOn:       2022/09/09 03:14:16
# Synopsis:         Import the config file and creates the needed variables
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

	# $global:CTXAdmin = Find-Credential | Where-Object target -Like '*CTXAdmin' | Get-Credential -Store
	# if ($null -eq $CTXAdmin) {
	# 	$AdminAccount = BetterCredentials\Get-Credential -Message 'Admin Account: DOMAIN\Username for CTX Admin'
	# 	Set-Credential -Credential $AdminAccount -Target 'CTXAdmin' -Persistence LocalComputer -Description 'Account used for Citrix queries' -Verbose
	# }
	# Write-Color 'Citrix Admin Credentials: ', $CTXAdmin.UserName -ShowTime -Color yellow, Green

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
######## Function 16 of 19 ##################
# Function:         Install-ParametersFile
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:33
# ModifiedOn:       2022/09/09 03:14:16
# Synopsis:         Create a json config file with all needed farm details.
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
######## Function 17 of 19 ##################
# Function:         Set-XDHealthReportColors
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/03/20 13:17:33
# ModifiedOn:       2022/05/20 21:23:50
# Synopsis:         Set the color and logo for HTML Reports
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
		[string]$Color1 = '#2b1200',
		[string]$Color2 = '#f37000',
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
		FixedHeader     = $true
		HideFooter      = $true
		SearchHighlight = $true
		PagingStyle     = 'full'
		PagingLength    = 10
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
######## Function 18 of 19 ##################
# Function:         Start-CitrixAudit
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 13:34:46
# ModifiedOn:       2022/09/09 03:14:16
# Synopsis:         Creates and distributes  a report on Catalog, groups and published app config.
#############################################
 
<#
.SYNOPSIS
Creates and distributes  a report on Catalog, groups and published app config.

.DESCRIPTION
Creates and distributes  a report on Catalog, groups and published app config.

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
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
	$CitrixObjects = Get-CitrixObjects -AdminServer $CTXDDC


	#######################
	#region Building HTML the report
	#######################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"

	$HeadingText = $DashboardTitle + ' | XenDesktop Audit | ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)
	New-HTML -TitleText 'XenDesktop Audit' -FilePath $Reportname {
		New-HTMLLogo -RightLogoString $XDHealth_LogoURL
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Site Details' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.ObjectCount }
			New-HTMLSection -HeaderText 'Site Databases' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.Databases }
        }
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Site Controllers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.Controllers }
			New-HTMLSection -HeaderText 'Site Licenses' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.Licenses }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Machine Catalogs' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.MachineCatalog }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.DeliveryGroups }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Published Apps' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.PublishedApps }
		}
	}
	#endregion

	#######################
	#region Saving Excel report
	#######################
	if ($SaveExcelReport) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Saving Excel Report"
         $ExcelOptions = @{
            Path             = $ExcelReportname
            AutoSize         = $True
            AutoFilter       = $True
            TitleBold        = $True
            TitleSize        = '28'
            TitleFillPattern = 'LightTrellis'
            TableStyle       = 'Light20'
            FreezeTopRow     = $True
            FreezePane       = '3'
        }
        if ($CitrixObjects.ObjectCount) {$CitrixObjects.ObjectCount | Export-Excel -Title ObjectCount -WorksheetName ObjectCount @ExcelOptions}
        if ($CitrixObjects.Controllers) {$CitrixObjects.Controllers | Export-Excel -Title Controllers -WorksheetName Controllers @ExcelOptions}
        if ($CitrixObjects.Databases) {$CitrixObjects.Databases | Export-Excel -Title Databases -WorksheetName Databases @ExcelOptions}
        if ($CitrixObjects.Licenses) {$CitrixObjects.Licenses | Export-Excel -Title Licenses -WorksheetName Licenses @ExcelOptions}
        if ($CitrixObjects.MachineCatalog) {$CitrixObjects.MachineCatalog | Export-Excel -Title MachineCatalog -WorksheetName MachineCatalog @ExcelOptions}
        if ($CitrixObjects.DeliveryGroups) {$CitrixObjects.DeliveryGroups | Export-Excel -Title DeliveryGroups -WorksheetName DeliveryGroups @ExcelOptions}
        if ($CitrixObjects.PublishedApps) {$CitrixObjects.PublishedApps | Export-Excel -Title PublishedApps -WorksheetName PublishedApps @ExcelOptions}
        if ($CitrixObjects.VDAServers) {$CitrixObjects.VDAServers | Export-Excel -Title VDAServers -WorksheetName VDAServers @ExcelOptions}
        if ($CitrixObjects.VDAWorkstations) {$CitrixObjects.VDAWorkstations | Export-Excel -Title VDAWorkstations -WorksheetName VDAWorkstations @ExcelOptions}
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
		$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
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
######## Function 19 of 19 ##################
# Function:         Start-CitrixHealthCheck
# Module:           XDHealthCheck
# ModuleVersion:    0.2.13
# Author:           Pierre Smit
# Company:          HTPCZA Tech
# CreatedOn:        2022/05/03 13:14:56
# ModifiedOn:       2022/09/09 03:14:17
# Synopsis:         Creates and distributes  a report on citrix farm health.
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
	$TodayReboots = $CitrixRemoteFarmDetails.RebootSchedule | Where-Object {$_.day -like "$((Get-Date).DayOfWeek)"}
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
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Monitor Data"
	$monitor = Get-CitrixMonitoringData -AdminServer $CTXDDC -SessionCount 100
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Failures"
	$Failures = Get-CitrixConnectionFailures -MonitorData $monitor
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] app ver"
	$appver = Get-CitrixWorkspaceAppVersions -MonitorData $monitor | Where-Object {$_.ClientVersion -notlike $null}
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] CitrixSessionIcaRtt"
	$CitrixSessionIcaRtt = Get-CitrixSessionIcaRtt -MonitorData $monitor
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] CitrixResourceUtilizationSummary"
	$CitrixResourceUtilizationSummary = Get-CitrixResourceUtilizationSummary -AdminServer $CTXDDC -hours 24

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
			New-HTMLSection -HeaderText 'Citrix Sessions' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.SessionCounts }
		}
		if ($CitrixRemoteFarmDetails.Controllers -or $CitrixRemoteFarmDetails.DBConnection) {
			New-HTMLSection @SectionSettings -Content {
				if ( $CitrixRemoteFarmDetails.Controllers) {New-HTMLSection -HeaderText 'Citrix Controllers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Controllers.Summary }}
				if ($CitrixRemoteFarmDetails.DBConnection) {New-HTMLSection -HeaderText 'Citrix DB Connection' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DBConnection }}
			}
		}
		if ($CitrixLicenseInformation -or $RDSLicenseInformation) {
			New-HTMLSection @SectionSettings -Content {
				if ($CitrixLicenseInformation) {New-HTMLSection -HeaderText 'Citrix Licenses' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixLicenseInformation }}
				if ($RDSLicenseInformation) {New-HTMLSection -HeaderText 'RDS Licenses' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($RDSLicenseInformation | Select-Object TypeAndModel, ProductVersion, TotalLicenses, IssuedLicenses, AvailableLicenses) }}
			}
		}
		if ($CitrixServerEventLogs) {
			New-HTMLSection @SectionSettings -Content {
				New-HTMLSection -HeaderText 'Citrix Error Counts' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixServerEventLogs | Select-Object ServerName, Errors, Warning) }
				New-HTMLSection -HeaderText 'Citrix Events Top Events' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixServerEventLogs.TopProfider | Select-Object -First $CTXCore.count) }
			}
		}
		if ($CitrixResourceUtilizationSummary -or $AppVer ) {
			New-HTMLSection @SectionSettings -Content {
				if ($CitrixResourceUtilizationSummary) {New-HTMLSection -HeaderText 'Resource Utilization Summary' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixResourceUtilizationSummary }}
				if ($AppVer) {New-HTMLSection -HeaderText 'Client Versions' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $AppVer }}
			}
		}
		if ($CitrixConfigurationChanges.Summary -or $ServerPerformance) {
			New-HTMLSection @SectionSettings -Content {
				if ($CitrixConfigurationChanges.Summary) {New-HTMLSection -HeaderText 'Citrix Config Changes in the last 7 days' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixConfigurationChanges.Summary | Where-Object { $_.name -ne '' } | Sort-Object count -Descending | Select-Object -First 5 -Property count, name) }}
			 if ($ServerPerformance) {New-HTMLSection -HeaderText 'Citrix Server Performance' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($ServerPerformance) $Conditions_performance }}
			}
		}
		if ($Failures.ConnectionFails -or $CitrixSessionIcaRtt) {
			New-HTMLSection @SectionSettings -Content {
				if ($Failures.ConnectionFails) {New-HTMLSection -HeaderText 'Connection Failure' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $Failures.ConnectionFails }}
				if ($CitrixSessionIcaRtt) {New-HTMLSection -HeaderText 'ICA Rtt' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixSessionIcaRtt }}
			}
		}
		if (($CitrixVDAUptime | Where-Object {$_.uptime -gt '7'})) {New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText 'VDA Uptime' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable ($CitrixVDAUptime | Where-Object {$_.uptime -gt '7'})} }}
		if ($CitrixRemoteFarmDetails.DeliveryGroups) {New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText 'Citrix Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.DeliveryGroups } }}
		if ($CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops) {New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText 'Citrix UnRegistered Desktops' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops } }}
		if ($CitrixRemoteFarmDetails.Machines.UnRegisteredServers) {New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText 'Citrix UnRegistered Servers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixRemoteFarmDetails.Machines.UnRegisteredServers } }}
		if ($TodayReboots) {New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText "Today`'s Reboot Schedule" @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $TodayReboots } }}
		if ($CitrixEnvTestResults.InfrastructureResults) {New-HTMLSection @SectionSettings -Content { New-HTMLSection -HeaderText 'Environment Test' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixEnvTestResults.InfrastructureResults } }}
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
		$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
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
 
