New-UDPage -Name "PS Repository" -Icon database -Content {
new-UDButton -Text "Map to the Teamshare" -Icon hdd -IconAlignment left -onClick {
Sync-UDElement -Id 'Form'
}

 
New-UDCollapsible -Items {
 New-UDCollapsibleItem  -Endpoint {

#region Section1
}
} 	 



<#
 # 

 New-UDCollapsibleItem  -Endpoint {

New-UDInput -Title "Login Form" -Id "Form" -Content {
      New-UDInputField -Type 'textbox' -Name 'Username' -Placeholder 'User'
      New-UDInputField -Type 'password' -Name 'password' -Placeholder 'Password'
    } -Endpoint {
		param($Username,$password)

		New-UDInputAction -Content @(
$sharepath = '\\corp.dsarena.com\za\group\120000_Euv'
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
if (test-path s:) {Show-UDModal -Content { New-UDHeading -Text "Drive already mapped"  -Color 'white' } -BackgroundColor red}
else {New-SmbMapping -LocalPath S: -RemotePath $sharepath -UserName $admincred.UserName.ToString() -Password $password -Verbose
    Show-UDModal -Content { New-UDHeading -Text "Drive Mapped"  -Color 'white' } -BackgroundColor green
    Start-Sleep -Seconds 5
    Hide-UDModal		   
	}
)




}
}
}

 
#region Section1
New-UDCollapsibleItem  -Endpoint {
    param($username,$password)

 New-UDInput -Title "Credentials" -Id "Form" -Content {
    New-UDInputField -Type textbox -Name 'username' -Placeholder 'Username'
    New-UDInputField -Type 'password' -Name 'password' -Placeholder 'Password'
} -Endpoint { param($username,$password)
$sharepath = '\\corp.dsarena.com\za\group\120000_Euv'
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
if (test-path s:) {Show-UDModal -Content { New-UDHeading -Text "Drive already mapped"  -Color 'white' } -BackgroundColor red}
else {New-SmbMapping -LocalPath S: -RemotePath $sharepath -UserName $admincred.UserName.ToString() -Password $password -Verbose
New-UDHeading -Text "Drive Mapped"  -Color 'white' } -BackgroundColor green
Start-Sleep -Seconds 5
Hide-UDModal		   
}
}
}        		


}
}

#>
