New-UDPage -Name "User Details" -Icon user -Content {
New-UDCollapsible -Items {
#region Section1
New-UDCollapsibleItem  -Endpoint {
			New-UDInput -Title "Username" -Endpoint {
				param(
					[Parameter(Mandatory)]
					[UniversalDashboard.ValidationErrorMessage("Invalid user")]
					[ValidateScript( { Get-ADUser -Identity $_ })]
					[string]$Username)

				New-UDInputAction -Content @(
	    $validuser = Get-FullUserDetail -UserToQuery $username  -DomainFQDN 'corp.dsarena.com' -DomainCredentials $CTXAdmin
	    $UserDetail = ConvertTo-FormatListView -Data $validuser.UserSummery

	    New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
	    New-UDLayout -Columns 2 -Content {
		    New-UDGrid -Id 'UserGrid1'  -Headers @("Name", "Value") -Properties @("Name", "Value") -NoPaging -Endpoint { $UserDetail | Out-UDGridData }
					New-UDGrid -Id 'UserGrid2' -Headers @("SamAccountName", "GroupScope") -Properties @("SamAccountName", "GroupScope") -NoPaging -Endpoint { $validuser.AllUserGroups | select SamAccountName, GroupScope | Out-UDGridData }
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


            
		New-UDInputAction -Toast $Username1
		New-UDInputAction -Toast $Username2

		$compareUsers = Compare-TwoADUsers -Username1 $Username1 -Username2 $Username2 -Verbose

		New-UDInputAction -Content  @(
			New-UDCard -Text (Get-Date -DisplayHint DateTime).ToString()-TextSize Medium -TextAlignment center
			New-UDLayout -Columns 2 -Content {
				New-UDGrid -Title $compareusers.User1Details.user1Headding  -Endpoint { $compareusers.User1Details.userDetailList1 | Out-UDGridData }
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
#endregion
} # Main Collapsble
} # Page
#endregion
