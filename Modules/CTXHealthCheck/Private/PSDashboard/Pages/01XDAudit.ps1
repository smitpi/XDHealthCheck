New-UDPage -Name "XD Audit Results" -Icon bomb -Content {
New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {         		
        $job = Start-RSJob -ScriptBlock { Initialize-CitrixAudit -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($CTXParameters)
		do {
            Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white'} -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal		   
}   until( $job.State -notlike 'Running')
    $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
    $AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    Sync-UDElement -Id 'Audit1'
    Sync-UDElement -Id 'Auditxml1'
} # onclick
New-UDCollapsible -Items {
	param ($CitrixCatalog, $auditXML)
	$auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)

	#region Section1
	New-UDCollapsibleItem -Title 'Latest Audit Report' -Content {
		param ($AuditReport)
		$AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
New-UDHtml ([string](Get-Content $AuditReport.FullName)) }


New-UDCollapsibleItem -Title 'MashineCatalog Details' -Content {

	New-UDInput -Title 'MashineCatalog' -Content {
		$names = ($auditXML.MashineCatalog | select MachineCatalogName).MachineCatalogName | sort
New-UDInputField -Name 'MashineCatalog' -Values @($names) -Type select 
} -Endpoint { param ($MashineCatalog, $auditXML) }

New-UDInputAction -RedirectUrl "/catalog/$MashineCatalog/$auditXML"
New-UDInputAction -Toast $MashineCatalog
}

New-UDCollapsibleItem -Title 'DeliveryGroups Details' -Content {
	New-UDInput -Content {
		New-UDInputField -Name 'DeliveryGroup' -Values @( $auditXML.DeliveryGroups | foreach { $_.DesktopGroupName }) -Type select 
} -Endpoint {
	param ($DeliveryGroup, $auditXML)
	New-UDInputAction -Toast $DeliveryGroup       
}
}

New-UDCollapsibleItem -Title 'PublishedApps Details' -Content {
	New-UDInput -Content {
		New-UDInputField -Name 'PublishedApps' -Values @($auditXML.PublishedApps | foreach { $_.PublishedName }) -Type select 
} -Endpoint {
	param ($PublishedApps, $auditXML)
	New-UDInputAction -Toast $PublishedApps       
}
}
}
} #UDCollapsible




 
 


<# 

 New-UDPage -Url "/catalog/:MashineCatalog/:auditXML"  -Endpoint {
    param($MashineCat,$auditXML)
    $result = ($auditXML.MashineCatalog | where MachineCatalogName -like $MashineCat).psobject.Properties | Select-Object -Property Name, Value
    New-UDLayout -Columns 1 -Content {New-UdGrid -Title 'MashineCat' -Endpoint{ $result| Out-UDGridData}

      }

    }


New-UDCollapsible -Items {
#region Section1
New-UDCollapsibleItem -Title 'HTML Audit Results'-Content {
	New-UDCard -Id 'Audit1' -Endpoint {
		param ($AuditReport)
		$AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	    New-UDHtml ([string](Get-Content $AuditReport.FullName))
}
} -FontColor black
#endregion
#region Section2
New-UDCollapsibleItem -Title 'Citrix Objects Detals'-Content {



}
}
}
#endregion
#region Section3
New-UDCollapsibleItem -Title 'test'-Content {
New-UDLayout -Columns 3 -Content {
    New-UDInput -Title "Citrix Catlogs" -Id 'ctxcat01' -Content {
    $LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1] 
    New-UDInputField -Name 'CitrixCatalog' -Values @($auditXML.MashineCatalog | foreach {$_.MachineCatalogName}) -Type select } -Endpoint 
    {
    param($CitrixCatalog)
    New-UDCard -Title $CitrixCatalog 
    }
}
} 
#endregion


}  # Main Collapsible
}#endregion



New-UDCollapsible -Items {
#region Section1
New-UDCollapsibleItem -Title 'HTML Audit Results'-Content {
	New-UDCard -Id 'Audit1' -Endpoint {
		param ($AuditReport)
		$AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	    New-UDHtml ([string](Get-Content $AuditReport.FullName))
}
} -FontColor black
#endregion
#region Section2
New-UDCollapsibleItem -Title 'Citrix Objects Detals'-Content {
New-UDLayout -Columns 3 -Content {
New-UDCard -Id 'xmlcat' -Endpoint {
    param ($xmlcat,$auditXML)
     $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
     New-UDInput -Title 'Catalog Name' -Content {
        New-UDInputField -Name 'CitrixCatalog' -Values @($auditXML.MashineCatalog | foreach {$_.MachineCatalogName}) -Type select 
        } -Endpoint {
           param ($xmlcat,$auditXML)
           New-UDInputAction -Toast $xmlcat
        }



}
}
}
#endregion
#region Section3
New-UDCollapsibleItem -Title 'test'-Content {
New-UDLayout -Columns 3 -Content {
    New-UDInput -Title "Citrix Catlogs" -Id 'ctxcat01' -Content {
    $LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1] 
    New-UDInputField -Name 'CitrixCatalog' -Values @($auditXML.MashineCatalog | foreach {$_.MachineCatalogName}) -Type select } -Endpoint 
    {
    param($CitrixCatalog)
    New-UDCard -Title $CitrixCatalog 
    }
}
} 
#endregion


}  # Main Collapsible
}#endregio


#########################


#########################
#########################


#########################

#region Section2
New-UDCollapsibleItem -Title 'Audit Results' -Id 'Auditxml1' -Endpoint {
param($auditXML)
$auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)

$LastRunXML =$auditXML.DateCollected.split("_")
$Dayxml = $LastRunXML[0].Split("-")[0]
$Monthxml = $LastRunXML[0].Split("-")[1]
$yearxml = $LastRunXML[0].Split("-")[2]

$LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1] 

$HeddingText = "XenDesktop Audit " + $LastRunXML
New-UDLayout -Columns 1 -Content{
    New-UDCard -Text $HeddingText -TextSize Small -TextAlignment right
    New-UDGrid -Title 'Citrix Mashine Catalog' -NoPaging -Endpoint {$auditXML.MashineCatalog| Out-UDGridData}
    New-UDGrid -Title 'Citrix Delivery Groups'-NoPaging -Endpoint { $auditXML.DeliveryGroups | Out-UDGridData}
    New-UDGrid -Title 'Citrix PublishedApps' -NoPaging -Endpoint { $auditXML.PublishedApps | Out-UDGridData}
}
} 
#endregion


#region Section3
New-UDLayout -Columns 3 -Content {
New-UDCollapsible -Items {  
    New-UDInput -Title "Citrix Catlogs" -Id 'ctxcat01' -Content {
    $auditXML = Import-Clixml (Get-ChildItem $ReportsFolder\XDAudit\*.xml)
    $LastRun = Get-Date -Day $LastRunXML[0].Split("-")[0] -Month $LastRunXML[0].Split("-")[1] -Year $LastRunXML[0].Split("-")[2] -Hour $LastRunXML[1].Split(":")[0] -Minute $LastRunXML[1].Split(":")[1] 
    New-UDInputField -Name 'CitrixCatalog' -Values @($auditXML.MashineCatalog | foreach {$_.MachineCatalogName}) -Type select } -Endpoint 
    {
    param($CitrixCatalog)
    New-UDCard -Title $CitrixCatalog 
    }
}
}

#>
