﻿
<#PSScriptInfo

.VERSION 0.1.0

.GUID c80e1f5a-57cd-4717-9dbb-62b2382912ee

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
Created [06/05/2022_08:38] Initial Script Creating

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Perform and report on tests on catalogs, delivery groups, hypervisor and Infrastructure 

#> 

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
