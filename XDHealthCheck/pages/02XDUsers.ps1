$XDUserPage = New-UDPage -Name "User Details" -Icon user -Content {
New-UDCollapsible -Items {
#region Section1
New-UDCollapsibleItem  -Endpoint {
			New-UDInput -Content {
                New-UDInputField -Name 'Username' -Type textbox -Placeholder 'Username'
                New-UDInputField -Name 'Domain' -Values @('corp.dsarena.com','ds1.ad.absa.co.za','client.barclayscorp.com','intranet.barcapint.com') -Type select -Placeholder 'Domain'
            } -Endpoint {
		param([string]$Username,$DomainFQDN)

        
		New-UDInputAction -Content @(
        $domaincreds = $TrustedDomains| where {$_.fqdn -like $Domain}
	    $validuser = Get-FullUserDetail -UserToQuery $username  -DomainFQDN $Domain -DomainCredentials $domaincreds -RunAsPSRemote -PSRemoteServerName $CTXDDC -PSRemoteCredentials $CTXAdmin
	    $UserDetail = $validuser.UserSummery.psobject.Properties | Select-Object -Property Name, Value

	    New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
	    New-UDLayout -Columns 2 -Content {
		    New-UDGrid -Id 'UserGrid1'  -Headers @("Name", "Value") -Properties @("Name", "Value") -NoPaging -Endpoint { $UserDetail | Out-UDGridData }
					New-UDGrid -Id 'UserGrid2' -Headers @("SamAccountName", "GroupScope") -Properties @("SamAccountName", "GroupScope") -NoPaging -Endpoint { $validuser.AllUserGroups | Select-Object SamAccountName, GroupScope | Out-UDGridData }
			}

		)
	}
} -Title "Single user Details" -FontColor black
#endregion

#region Section1
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

				$compareUsers = Compare-ADUser -Username1 $Username1 -Username2 $Username2 -DomainFQDN 'corp.dsarena.com' -DomainCredentials $TrustedDomains[0].Credentials -RunAsPSRemote -PSRemoteServerName $CTXDDC -Verbose

		New-UDInputAction -Content  @(
			New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
			New-UDLayout -Columns 2 -Content {
			    New-UDGrid -Title $compareusers.User1Details.user1Headding  -NoPaging -NoFilter  -Endpoint { $compareusers.User1Details.userDetailList1 | Out-UDGridData }
			    New-UDGrid -Title $compareusers.User2Details.user2Headding  -NoPaging -NoFilter -Endpoint { $compareusers.User2Details.userDetailList2 | Out-UDGridData }
	    }
	    New-UDLayout -Columns 3 -Content {
		    New-UDGrid -Title $compareusers.User1Details.user1HeaddingMissing  -NoPaging -NoFilter -Endpoint { $compareusers.User1Details.User1Missing | Out-UDGridData }
	        New-UDGrid -Title $compareusers.User2Details.user2HeaddingMissing  -NoPaging -NoFilter -Endpoint { $compareusers.User2Details.User2Missing | Out-UDGridData }
            New-UDGrid -Title 'Same Groups'  -NoPaging -NoFilter -Endpoint { $compareusers.SameGroups | Out-UDGridData }
        }
        New-UDLayout -Columns 2 -Content {
	        New-UDGrid -Title $compareusers.User1Details.user1Headding  -NoPaging -NoFilter -Endpoint { $compareusers.User1Details.allusergroups1 | Out-UDGridData }
            New-UDGrid -Title $compareusers.User2Details.user2Headding  -NoPaging -NoFilter -Endpoint { $compareusers.User2Details.allusergroups2 | Out-UDGridData }
        }
)
}
} -Title "Compare Two Users" -FontColor black
#endregion

#region Section1
New-UDCollapsibleItem  -Endpoint {
	New-UDInput -Title "Username" -Endpoint {
		param(
			[Parameter(Mandatory)]
			[UniversalDashboard.ValidationErrorMessage("Invalid user")]
			[ValidateScript( { Get-ADUser -Identity $_ })]
			[string]$Username)
        
		New-UDInputAction -Content @(
        
		$UserDetail = Get-CitrixUserAccessDetail -Username $username -AdminServer $CTXDDC -DomainFQDN 'corp.dsarena.com' -DomainCredentials $TrustedDomains[0].Credentials -RunAsPSRemote -PSRemoteServerName $CTXDDC -Verbose
		$userDetailList = $UserDetail.UserDetail.psobject.Properties | Select-Object -Property Name, Value
		$Desktops = $UserDetail.PublishedDesktops | Sort-Object -Property DesktopGroupName -Unique
	New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
	New-UDLayout -Columns 5 -Content {
		New-UDGrid -Title 'User details' -NoPaging -NoFilter -Endpoint { $userDetailList | Out-UDGridData }
		New-UDGrid -Title 'Current Applications' -NoPaging -NoFilter -Endpoint { ($UserDetail.AccessPublishedApps | Select-Object PublishedName) | Out-UDGridData }
		New-UDGrid -Title 'Current VDI' -NoPaging -NoFilter -Endpoint {($UserDetail.DirectPublishedDesktops | select DNSName) | Out-UDGridData }
		New-UDGrid -Title 'Current Published Dekstops' -NoPaging -NoFilter -Endpoint {($Desktops | select DesktopGroupName)  | Out-UDGridData }
		New-UDGrid -Title 'Available Applications' -NoPaging -NoFilter -Endpoint { ($UserDetail.NoAccessPublishedApps | Select-Object PublishedName) | Out-UDGridData }
	}
)
}
} 	 -Title "Check User Access In Citrix" -FontColor black
#endregion
} # Main Collapsible
} # Page
#endregion
$XDUserPage
