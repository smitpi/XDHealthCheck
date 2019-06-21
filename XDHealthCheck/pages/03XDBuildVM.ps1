$XDBuildvm = New-UDPage -Name "Build Machines" -Icon server -Content {
New-UDCollapsible -Items {
#region Section1
New-UDCollapsibleItem -Title "Machine Catalogs"  -Endpoint {
New-UDInput  -Content {
            $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
            $SelectCatalog =  $auditXML.MashineCatalog  | Select-Object MachineCatalogName | ForEach-Object {$_.MachineCatalogName}
             New-UDInputField -Name machineCatalog -Values @($SelectCatalog) -Type select
         } -Endpoint {param([string]$machineCatalog)

                 New-UDInputAction -Toast $machineCatalog
                 New-UDInputAction -Content @(
                 New-UDCard -Content { New-UDHeading -Text $machineCatalog}
                 )
           }
}

New-UDCollapsibleItem -Title "Delivery Group"  -Endpoint {
New-UDInput  -Content {
            $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
            $SelectCatalog =  $auditXML.DeliveryGroups | Select-Object DesktopGroupName | ForEach-Object {$_.DesktopGroupName}
             New-UDInputField -Name DeliveryGroups -Values @($SelectCatalog) -Type select
         } -Endpoint {param([string]$DeliveryGroups)

                 New-UDInputAction -Toast $DeliveryGroups
                 New-UDInputAction -Content @(
                 New-UDCard -Content { New-UDHeading -Text $DeliveryGroups}
                 )
           }
}

} 
} -ArgumentList @("CTXAdmin", "CTXDDC", "CTXStoreFront", "RDSLicensServer", "RDSLicensType", "ReportsFolder", "ParametersFolder", "DashboardTitle", "SaveExcelReport")
$XDBuildvm