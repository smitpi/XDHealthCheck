
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
            foreach ($catalog in Get-BrokerCatalog -AdminAddress $AdminAddress) {
                Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Catalog: $($catalog.Name)"
                $testResult = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminAddress -TargetIdType 'Catalog' -TestSuiteId 'Catalog' -TargetId $catalog.UUID | Start-EnvTestTask -AdminAddress $AdminAddress -ExcludeNotRunTests 
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
            foreach ($DesktopGroup in Get-BrokerDesktopGroup -AdminAddress $AdminAddress) {
                Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Catalog: $($DesktopGroup.Name)"
                $testResult = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminAddress -TargetIdType 'DesktopGroup' -TestSuiteId 'DesktopGroup' -TargetId $DesktopGroup.UUID | Start-EnvTestTask -AdminAddress $AdminAddress -ExcludeNotRunTests 
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
            foreach ($Hypervisor in Get-BrokerHypervisorConnection -AdminAddress $AdminAddress) {
                Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Catalog: $($Hypervisor.Name)"
                $testResult = New-EnvTestDiscoveryTargetDefinition -AdminAddress $AdminAddress -TargetIdType 'HypervisorConnection' -TestSuiteId 'HypervisorConnection' -TargetId $Hypervisor.Uid | Start-EnvTestTask -AdminAddress $AdminAddress -ExcludeNotRunTests 
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
            $Infra = New-EnvTestDiscoveryTargetDefinition -TestSuiteId Infrastructure | Start-EnvTestTask -AdminAddress $AdminAddress -ExcludeNotRunTests
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
        $catalogResults | Out-HtmlView -DisablePaging -Title 'Catalog Results' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixEnvTestResults-catalog-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
        $DesktopGroupResults | Out-HtmlView -DisablePaging -Title 'DesktopGroup Results' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixEnvTestResults-DesktopGroup-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
        $HypervisorConnectionResults | Out-HtmlView -DisablePaging -Title 'Hypervisor Connection Results' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixEnvTestResults-Hypervisor-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
        $InfrastructureResults | Out-HtmlView -DisablePaging -Title 'Infrastructure Results' -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixEnvTestResults-Infrastructure-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") 
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
