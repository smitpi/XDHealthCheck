
<#PSScriptInfo

.VERSION 1.0.1

.GUID 144e3fd9-5999-4364-bdd6-99e1a6451adf

.AUTHOR Pierre Smit

.COMPANYNAME  

.COPYRIGHT

.TAGS Powershell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [06/06/2019_04:01]
Updated [06/06/2019_19:25] 

.PRIVATEDATA

#> 



<# 

.DESCRIPTION 
Universal Dashboard

#> 

Param()
Set-Location $PSScriptRoot
Import-Module ..\CTXHealthCheck.psm1 -Force -Verbose
[XML]$XMLParameter = Get-Content $PSParameters
#[XML]$XMLParameter = Get-Content \\corp.dsarena.com\za\group\120000_Euv\Personal\ABPS835-ADMIN\Powershell\Parameters.xml
$XMLParameter.Settings.Variables.Variable | ft
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"

$XMLParameter.Settings.Variables.Variable | foreach {
	# Set Variables contained in XML file
	$VarValue = $_.Value
	$CreateVariable = $True # Default value to create XML content as Variable
	switch ($_.Type) {
		# Format data types for each variable
		'[string]' { $VarValue = [string]$VarValue } # Fixed-length string of Unicode characters
		'[char]' { $VarValue = [char]$VarValue } # A Unicode 16-bit character
		'[byte]' { $VarValue = [byte]$VarValue } # An 8-bit unsigned character
		'[bool]' { If ($VarValue.ToLower() -eq 'false') { $VarValue = [bool]$False } ElseIf ($VarValue.ToLower() -eq 'true') { $VarValue = [bool]$True } } # An boolean True/False value
		'[int]' { $VarValue = [int]$VarValue } # 32-bit signed integer
		'[long]' { $VarValue = [long]$VarValue } # 64-bit signed integer
		'[decimal]' { $VarValue = [decimal]$VarValue } # A 128-bit decimal value
		'[single]' { $VarValue = [single]$VarValue } # Single-precision 32-bit floating point number
		'[double]' { $VarValue = [double]$VarValue } # Double-precision 64-bit floating point number
		'[DateTime]' { $VarValue = [DateTime]$VarValue } # Date and Time
		'[Array]' { $VarValue = [Array]$VarValue.Split(',') } # Array
		'[Command]' { $VarValue = Invoke-Expression $VarValue; $CreateVariable = $False } # Command
	}
	If ($CreateVariable) { New-Variable -Name $_.Name -Value $VarValue -Scope $_.Scope -Force }
}

$CTXAdmin = Find-Credential | where target -Like "*Healthcheck" | Get-Credential -Store
if ($CTXAdmin -eq $null) {
	$AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
	Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}

########################################
## build pages
#########################################

$CTXFunctions = New-UDEndpointInitialization -Module @("CTXHealthCheck", "PoshRSJob") -Variable @(" $CTXDDC","ReportsFolder", "ParametersFolder", "CTXAdmin", "PSParameters") -Function @("Get-FullUserDetail", "Initialize-CitrixAudit", "Initialize-CitrixHealthCheck")
$Theme = Get-UDTheme -Name Default 

#region Page1
$CTXHomePage = New-UDPage -Name "Health Check" -Icon home -DefaultHomePage -Content {
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {         		
        $job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($PSParameters)
		do {
            Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white'} -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal		   
}   until( $job.State -notlike 'Running')
    $TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    Sync-UDElement -Id 'Healcheck1'
} # onclick
New-UDCollapsible -Items {
    New-UDCollapsibleItem -Title 'Latest Health Check Report'-Content {
    New-UDCard -Id 'Healcheck1' -Endpoint {
	param ($TodayReport)
    $TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	New-UDHtml ([string](Get-Content $TodayReport.FullName))
    }
} -Active
}
}
#endregion

#region Page2
$CTXAuditPage = New-UDPage -Name "Audit Results" -Icon bomb -Content {
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {         		
        $job = Start-RSJob -ScriptBlock { Initialize-CitrixAudit -XMLParameterFilePath  $args[0] -Verbose } -ArgumentList @($PSParameters)
		do {
            Show-UDModal -Content { New-UDHeading -Text "Refreshing your data"  -Color 'white'} -Persistent -BackgroundColor green
			Start-Sleep -Seconds 10
			Hide-UDModal		   
}   until( $job.State -notlike 'Running')
    $AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
    Sync-UDElement -Id 'Audit1'
} # onclick
New-UDCollapsible -Items {
    New-UDCollapsibleItem -Title 'Latest Health Check Report'-Content {
    New-UDCard -Id 'Audit1' -Endpoint {
	param ($AuditReport)
    $AuditReport = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	New-UDHtml ([string](Get-Content $AuditReport.FullName))
}
}
}
}
#endregion

#region Page 3
$UserPage1 = New-UDPage -Name "User Details" -Icon user -Content {
	New-UDCollapsible -Items {
		New-UDCollapsibleItem  -Endpoint {
			New-UDInput -Title "Username" -Endpoint {
				param(
					[Parameter(Mandatory)]
					[UniversalDashboard.ValidationErrorMessage("Invalid user")]
					[ValidateScript( { Get-ADUser -Identity $_ })]
					[string]$Username)

				New-UDInputAction -Content @(
	    $validuser = Get-FullUserDetail -UserToQuery $username -DomainFQDN htpcza.com -DomainCredentials $CTXAdmin
	    $UserDetail = ConvertTo-FormatListView -Data $validuser.UserSummery

	    New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
	    New-UDLayout -Columns 2 -Content {
		    New-UDGrid -Id 'UserGrid1'  -Headers @("Name", "Value") -Properties @("Name", "Value") -NoPaging -Endpoint { $UserDetail | Out-UDGridData }
					New-UDGrid -Id 'UserGrid2' -Headers @("SamAccountName", "GroupScope") -Properties @("SamAccountName", "GroupScope") -NoPaging -Endpoint { $validuser.AllUserGroups | select SamAccountName, GroupScope | Out-UDGridData }
			}

		)
	}
} -Title "Single user Details" -FontColor black

New-UDCollapsibleItem -Endpoint {
	New-UDInput -Title "Compare Users" -Content {
		New-UDInputField -Name 'Username1' -Type textbox -Placeholder 'Username1'
		New-UDInputField -Name 'Username2' -Type textbox -Placeholder 'Username2'
	} -Endpoint {
		param(
			[Parameter(Mandatory)]
			[UniversalDashboard.ValidationErrorMessage("Invalid user")]
			[ValidateScript( { Get-ADUser -Identity $_ })]
			[string]$Username1,
			[Parameter(Mandatory)]
			[UniversalDashboard.ValidationErrorMessage("Invalid user")]
			[ValidateScript( { Get-ADUser -Identity $_ })]
			[string]$Username2)


            
		New-UDInputAction -Toast $Username1
		New-UDInputAction -Toast $Username2

		$compareUsers = Compare-TwoADUsers -Username1 $Username1 -Username2 $Username2 -Verbose

		New-UDInputAction -Content  @(
			New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
			New-UDLayout -Columns 2 -Content {
				New-UDGrid -Title $compareusers.User1Details.user1Headding -Endpoint { $compareusers.User1Details.userDetailList1 | Out-UDGridData }
			New-UDGrid -Title $compareusers.User2Details.user2Headding -Endpoint { $compareusers.User2Details.userDetailList2 | Out-UDGridData }
	}
	New-UDLayout -Columns 3 -Content {
		New-UDGrid -Title $compareusers.User1Details.user1HeaddingMissing -Endpoint { $compareusers.User1Details.User1Missing | Out-UDGridData }
	New-UDGrid -Title $compareusers.User2Details.user2HeaddingMissing -Endpoint { $compareusers.User2Details.User2Missing | Out-UDGridData }
New-UDGrid -Title 'Same Groups' -Endpoint { $compareusers.SameGroups | Out-UDGridData }
}
New-UDLayout -Columns 2 -Content {
	New-UDGrid -Title $compareusers.User1Details.user1Headding -Endpoint { $compareusers.User1Details.allusergroups1 | Out-UDGridData }
New-UDGrid -Title $compareusers.User2Details.user2Headding -Endpoint { $compareusers.User2Details.allusergroups2 | Out-UDGridData }
}
)


}
        
} -Title "Compare Two Users" -FontColor black

New-UDCollapsibleItem  -Endpoint {
	New-UDInput -Title "Username" -Endpoint {
		param(
			[Parameter(Mandatory)]
			[UniversalDashboard.ValidationErrorMessage("Invalid user")]
			[ValidateScript( { Get-ADUser -Identity $_ })]
			[string]$Username)

		New-UDInputAction -Content @(
			$UserDetail = Get-CitrixUserAccessDetails -Username $Username -AdminServer $CTXDDC -Verbose
			$userDetailList = $UserDetail.UserDetail.psobject.Properties | Select-Object -Property Name, Value
		$DesktopsCombined = $UserDetail.DirectPublishedDesktops + $UserDetail.PublishedDesktops | sort -Property DesktopGroupName -Unique
	New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
	New-UDLayout -Columns 4 -Content {
		New-UDGrid -Title 'User details' -Endpoint { $userDetailList | Out-UDGridData }
	New-UDGrid -Title 'Current Applications' -Endpoint { ($UserDetail.AccessPublishedApps | select PublishedName, Description, enabled) | Out-UDGridData }
New-UDGrid -Title 'Current Desktops' -Endpoint { $DesktopsCombined | Out-UDGridData }
New-UDGrid -Title 'Available Applications' -Endpoint { ($UserDetail.NoAccessPublishedApps | select PublishedName, Description, enabled) | Out-UDGridData }
}
)




}
} 	 -Title "Check User Access In Citrix" -FontColor black
}
}
#endregion



man New-UDEndpoint -ShowWindow

########################################
## Build dashboard
#########################################

Get-UDDashboard | Stop-UDDashboard

$Dashboard = New-UDDashboard -Title "XenDektop Universal Dashboard" -Pages @($CTXHomePage,$CTXAuditPage, $UserPage1) -EndpointInitialization $CTXFunctions -Theme $Theme

Start-UDDashboard -Dashboard $Dashboard -Port 10007
Start-Process http://localhost:10007

<#
 #


 #region Page 4
$XDUD = New-UDPage -Name "XD Dashboard" -Icon server -Content {
########################################
## Build other variables
#########################################
$CTXControllers = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerController | select dnsname } | foreach { $_.dnsname }
$CTXLicenseServer = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerSite -AdminAddress $AdminServer | select LicenseServerName } | foreach { $_.LicenseServerName }
$CTXStoreFrontFarm = Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-STFServerGroup | select -ExpandProperty ClusterMembers | select hostname | foreach { ([System.Net.Dns]::GetHostByName(($_.hostname))).Hostname } }
$CTXCore = $CTXControllers + $CTXStoreFrontFarm + $CTXLicenseServer | sort -Unique

########################################
## Connect and get info
########################################
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
$CitrixLicenseInformation = Get-CitrixLicenseInformation -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$CitrixRemoteFarmDetails = Get-CitrixFarmDetails -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$CitrixServerEventLogs = Get-CitrixServerEventLogs -Serverlist $CTXCore -Days 1 -RemoteCredentials $CTXAdmin -Verbose
$RDSLicenseInformation = Get-RDSLicenseInformation -LicenseServer $RDSLicensServer  -RemoteCredentials $CTXAdmin -Verbose
$CitrixConfigurationChanges = Get-CitrixConfigurationChanges -AdminServer $CTXDDC -Indays 7 -RemoteCredentials $CTXAdmin -Verbose
$StoreFrontDetails = Get-StoreFrontDetails -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
#$ServerPerformance = Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin -Verbose


$HeddingText = "XenDesktop Report for Farm: " + $CitrixRemoteFarmDetails.SiteDetails.Summary.Name + " on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)  + " " + (Get-Date -Format HH:mm)

New-UDCard -Text $HeddingText -TextSize Medium -TextAlignment center
New-UDLayout -Columns 1 -Content{
       New-UDGrid -Title 'Citrix Sessions' -Endpoint {$CitrixRemoteFarmDetails.SessionCounts| Out-UDGridData}
       New-UDGrid -Title 'Citrix Controllers' -Endpoint { $CitrixRemoteFarmDetails.Controllers.Summary | Out-UDGridData}
       New-UDGrid -Title 'Citrix DB Connection' -Endpoint {  $CitrixRemoteFarmDetails.DBConnection | Out-UDGridData}
       New-UDGrid -Title 'Citrix Licenses' -Endpoint {$CitrixLicenseInformation | Out-UDGridData}
       New-UDGrid -Title 'RDS Licenses' -Endpoint {  $RDSLicenseInformation.$RDSLicensType| Out-UDGridData}
       New-UDGrid -Title 'Citrix Error Counts' -Endpoint {   ($CitrixServerEventLogs.SingleServer | select ServerName, Errors, Warning)| Out-UDGridData}
       New-UDGrid -Title 'Citrix Events Top Events' -Endpoint {  ($CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count) | Out-UDGridData}
       New-UDGrid -Title 'StoreFront Site' -Endpoint {   $StoreFrontDetails.SiteDetails| Out-UDGridData}
       New-UDGrid -Title 'StoreFront Server' -Endpoint {  $StoreFrontDetails.ServerDetails | Out-UDGridData}
       New-UDGrid -Title 'Citrix Config Changes in the last 7 days' -Endpoint {  ($CitrixConfigurationChanges.Summary | where { $_.name -ne "" } | Sort-Object count -Descending | select -First 5 -Property count, name) | Out-UDGridData}
       New-UDGrid -Title 'Citrix Server Performace' -Endpoint {  ($ServerPerformance)| Out-UDGridData}
       New-UDGrid -Title 'Citrix Delivery Groups' -Endpoint {  $CitrixRemoteFarmDetails.DeliveryGroups| Out-UDGridData}
       New-UDGrid -Title 'Citrix UnRegistered Desktops' -Endpoint {  $CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops| Out-UDGridData}
       New-UDGrid -Title 'Citrix UnRegistered Servers' -Endpoint {  $CitrixRemoteFarmDetails.Machines.UnRegisteredServers| Out-UDGridData}
       New-UDGrid -Title 'Citrix Tainted Objects' -Endpoint {  $CitrixRemoteFarmDetails.ADObjects.TaintedObjects| Out-UDGridData}
}
}
#endregion

 #region Page2
$Audit = New-UDPage -Name "Citrix Audit"  -Icon database -Content {
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {

		$job = Start-RSJob -ScriptBlock { Initialize-CitrixAudit -XMLParameterFilePath $PSParameters -Verbose }
		do {
			Show-UDModal -Content { New-UDHeading -Text "Refreshing your data" } -Persistent
			Start-Sleep -Seconds 10
			Hide-UDModal
		} until ($job.State -notlike 'Running')
	} # end button
	$TodayAudit = Get-Item ((Get-ChildItem $ReportsFolder\XDAudit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *    
Sync-UDElement -Id 'CardDisplayNameCARD'
New-UDCollapsible -Items {
	New-UDCollapsibleItem -Content {
		New-UDCard -Id 'CardDisplayNameCARD' -Endpoint {
			param ($TodayAudit)
			New-UDHtml ([string](Get-Content $TodayAudit.FullName))
		} } -Active -Title '  Latest Citrix Audit'
        
} 
}
#endregion

 $CTXHomePage = New-UDPage -Name "Health Check" -Icon home -DefaultHomePage -Content {
	New-UDButton -Text "Refresh" -Icon cloud -IconAlignment left -onClick {

		$job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath $PSParameters -Verbose }
		do {
			Show-UDModal -Content { New-UDHeading -Text "Refreshing your data" } -Persistent
			Start-Sleep -Seconds 10
			Hide-UDModal
		} until ($job.State -notlike 'Running')
	} # end button

$TodayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
$YesterdayReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[1]) | select *
$2daysReport = Get-Item ((Get-ChildItem $ReportsFolder\XDHealth\*.html | Sort-Object -Property LastWriteTime -Descending)[2]) | select *

Sync-UDElement -Id 'Healcheck1'
Sync-UDElement -Id 'Healcheck2'
Sync-UDElement -Id 'Healcheck3'


New-UDCollapsible -Items {
	New-UDCollapsibleItem -Content {
		New-UDCard -Id 'Healcheck1' -Endpoint {
			param ($TodayReport)
			New-UDHtml ([string](Get-Content $TodayReport.FullName))
		} 
	} -Active  -Title '  Today''s Report'

	New-UDCollapsibleItem -Content {
		New-UDCard -Id 'Healcheck2' -Endpoint {
			param ($YesterdayReport)
			New-UDHtml ([string](Get-Content $YesterdayReport.FullName)) }
 } -Title '  Yesterday''s Report'
    
	New-UDCollapsibleItem -Content {
		New-UDCard -Id 'Healcheck3' -Endpoint {
			param ($2daysReport)
			New-UDHtml ([string](Get-Content $2daysReport.FullName)) } } -Title '  2 Days Ago''s Report'
 
}
}

New-UDTable -Title "Server Information" -Headers @("Severity", "Name",'Affected Hosts') -Endpoint {
    1..10 | foreach {
      [pscustomobject]@{
        Severity = 'CRITICAL'
        Name = New-UDLink -Text 'KB123456' -Url "localhost\kb123456"
        'Affected Hosts' = '123'
      }
    }| Out-UDTableData -Property @("Severity", "Name",'Affected Hosts')
  }



New-UDCard -Id 'CardDisplayNameCARD' -Title 'DisplayName Card' -Endpoint {
         New-UDParagraph -Text $Session:DisplayName
    }
     
    New-UDInput -Title "Input testing" -Id "MyUserForm" -Content {
        New-UDInputField -Type 'textbox' -Name 'InputDisplayName' -Placeholder 'Name Here!'
 
    } -Endpoint {
 
        param($InputDisplayName)
         
        $Session:DisplayName = $InputDisplayName
 
         Sync-UDElement -Id 'CardDisplayNameCARD'       
    }





#region Page 4
$XDUD = New-UDPage -Name "XD Dash" -Icon server -Content {

########################################
## Build other variables
#########################################
$CTXControllers = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerController | select dnsname } | foreach { $_.dnsname }
$CTXLicenseServer = Invoke-Command -ComputerName $CTXDDC -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-BrokerSite -AdminAddress $AdminServer | select LicenseServerName } | foreach { $_.LicenseServerName }
$CTXStoreFrontFarm = Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock { Add-PSSnapin citrix* ; Get-STFServerGroup | select -ExpandProperty ClusterMembers | select hostname | foreach { ([System.Net.Dns]::GetHostByName(($_.hostname))).Hostname } }
$CTXCore = $CTXControllers + $CTXStoreFrontFarm + $CTXLicenseServer | sort -Unique

########################################
## Connect and get info
########################################
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
$CitrixLicenseInformation = Get-CitrixLicenseInformation -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$CitrixRemoteFarmDetails = Get-CitrixFarmDetails -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
$CitrixServerEventLogs = Get-CitrixServerEventLogs -Serverlist $CTXCore -Days 1 -RemoteCredentials $CTXAdmin -Verbose
$RDSLicenseInformation = Get-RDSLicenseInformation -LicenseServer $RDSLicensServer  -RemoteCredentials $CTXAdmin -Verbose
$CitrixConfigurationChanges = Get-CitrixConfigurationChanges -AdminServer $CTXDDC -Indays 7 -RemoteCredentials $CTXAdmin -Verbose
$StoreFrontDetails = Get-StoreFrontDetails -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote -Verbose
#$ServerPerformance = Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin -Verbose

########################################
## Adding more reports / scripts
########################################

$HeddingText = "XenDesktop Report for Farm: " + $CitrixRemoteFarmDetails.SiteDetails.Summary.Name + " on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)  + " " + (Get-Date -Format HH:mm)

New-UDCard -Text $HeddingText -TextSize Medium -TextAlignment center
New-UDLayout -Columns 1 -Content{
       New-UDGrid -Title 'Citrix Sessions' -Endpoint {$CitrixRemoteFarmDetails.SessionCounts| Out-UDGridData}
       New-UDGrid -Title 'Citrix Controllers' -Endpoint { $CitrixRemoteFarmDetails.Controllers.Summary | Out-UDGridData}
       New-UDGrid -Title 'Citrix DB Connection' -Endpoint {  $CitrixRemoteFarmDetails.DBConnection | Out-UDGridData}
       New-UDGrid -Title 'Citrix Licenses' -Endpoint {$CitrixLicenseInformation | Out-UDGridData}
       New-UDGrid -Title 'RDS Licenses' -Endpoint {  $RDSLicenseInformation.$RDSLicensType| Out-UDGridData}
       New-UDGrid -Title 'Citrix Error Counts' -Endpoint {   ($CitrixServerEventLogs.SingleServer | select ServerName, Errors, Warning)| Out-UDGridData}
       New-UDGrid -Title 'Citrix Events Top Events' -Endpoint {  ($CitrixServerEventLogs.TotalProvider | Select-Object -First $CTXCore.count) | Out-UDGridData}
       New-UDGrid -Title 'StoreFront Site' -Endpoint {   $StoreFrontDetails.SiteDetails| Out-UDGridData}
       New-UDGrid -Title 'StoreFront Server' -Endpoint {  $StoreFrontDetails.ServerDetails | Out-UDGridData}
       New-UDGrid -Title 'Citrix Config Changes in the last 7 days' -Endpoint {  ($CitrixConfigurationChanges.Summary | where { $_.name -ne "" } | Sort-Object count -Descending | select -First 5 -Property count, name) | Out-UDGridData}
       New-UDGrid -Title 'Citrix Server Performace' -Endpoint {  ($ServerPerformance)| Out-UDGridData}
       New-UDGrid -Title 'Citrix Delivery Groups' -Endpoint {  $CitrixRemoteFarmDetails.DeliveryGroups| Out-UDGridData}
       New-UDGrid -Title 'Citrix UnRegistered Desktops' -Endpoint {  $CitrixRemoteFarmDetails.Machines.UnRegisteredDesktops| Out-UDGridData}
       New-UDGrid -Title 'Citrix UnRegistered Servers' -Endpoint {  $CitrixRemoteFarmDetails.Machines.UnRegisteredServers| Out-UDGridData}
       New-UDGrid -Title 'Citrix Tainted Objects' -Endpoint {  $CitrixRemoteFarmDetails.ADObjects.TaintedObjects| Out-UDGridData}
}
}
#endregion






#region Page 5
$DynamicUserPage2 = New-UDPage -Url "/compare/:Username1/:$username2" -Icon user_o -Endpoint {
param($Username1,$Username2)

		$job = Start-RSJob -ScriptBlock { Initialize-CitrixUserReports -XMLParameterFilePath "$ParametersFolder\Parameters.xml" -Username1 $Username1 -Username2 $Username2 }
		do {
			Show-UDModal -Content { New-UDHeading -Text "Calculating" } -Persistent
			Start-Sleep -Seconds 10
			Hide-UDModal
		} until ($job.State -notlike 'Running')

		$UserCompare = Get-Item ((Get-ChildItem $ReportsFolder\XDUsers\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *    
		New-UDCollapsible -Items {
		New-UDCollapsibleItem -Icon arrow_circle_right -Content { New-UDHtml ([string](Get-Content $UserCompare.FullName)) } -Active -BackgroundColor lightgrey -FontColor black
        }
}
#endregion


             $job = Start-RSJob -ScriptBlock { Initialize-CitrixUserReports -XMLParameterFilePath "$ParametersFolder\Parameters.xml" -Username1 $Username1 -Username2 $Username2 }
            $UserCompare = Get-Item ((Get-ChildItem $ReportsFolder\XDUsers\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *    
		    do {
			    Show-UDModal -Content { New-UDHeading -Text "Comparing $Username1 with $Username2" } -Persistent
			    Start-Sleep -Seconds 10
			    Hide-UDModal
		    } until ($job.State -notlike 'Running')


New-UDInput -Title "Module Info Locator" -Endpoint {
    param($ModuleName) 

    # Get a module from the gallery
    $Module = Find-Module $ModuleName

    # Output a new card based on that info
    New-UDInputAction -Content @(
        New-UDCard -Title "$ModuleName - $($Module.Version)" -Text $Module.Description
    )
}



 New-UDInput -Title "Simple Form" -Id "Form" -Content {
    New-UDInputField -Type 'textbox' -Name 'Email' -Placeholder 'Email Address'
    New-UDInputField -Type 'checkbox' -Name 'Newsletter' -Placeholder 'Sign up for newsletter'
    New-UDInputField -Type 'select' -Name 'FavoriteLanguage' -Placeholder 'Favorite Programming Language' -Values @("PowerShell", "Python", "C#")
    New-UDInputField -Type 'radioButtons' -Name 'FavoriteEditor' -Placeholder @("Visual Studio", "Visual Studio Code", "Notepad") -Values @("VS", "VSC", "NP")
    New-UDInputField -Type 'password' -Name 'password' -Placeholder 'Password'
    New-UDInputField -Type 'textarea' -Name 'notes' -Placeholder 'Additional Notes'
} -Endpoint {
    param($Email, $Newsletter, $FavoriteLanguage, $FavoriteEditor, $password, $notes)
}


 


#New-UDGridLayout -Content {
#    New-UDCard -Title "Card 1" -Id 'Card1' 
#    New-UDCard -Title "Card 2" -Id 'Card2'
#    New-UDCard -Title "Card 3" -Id 'Card3'





$CompareUsers = New-UDPage -Name 'ADUser' -Icon user -Title 'Compare users' -Content {
	New-UDInput -Title "User Details" -Endpoint {
		param @($user1, $user2)
		New-UDInputField -Type 'textbox' -Name 'user1' -Placeholder 'Username1'
		New-UDInputField -Type 'textbox' -Name 'user2' -Placeholder 'Username2'
		New-UDInputAction -RedirectUrl 	"/dynamic/$User1" }
}

$DynamicUserPage = New-UDPage -Url "/dynamic/:User1" -Icon address_book -Endpoint {
		param @($user1, $user2)
}
#>