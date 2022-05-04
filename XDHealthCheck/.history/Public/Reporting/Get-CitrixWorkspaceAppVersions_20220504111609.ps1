
<#PSScriptInfo

.VERSION 0.1.0

.GUID 8b29da17-5e3b-41dd-ade5-fb88f385fe88

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
Created [03/05/2022_23:16] Initial Script Creating

#>

#Requires -Module ImportExcel
#Requires -Module PSWriteHTML
#Requires -Module PSWriteColor

<# 

.DESCRIPTION 
 Reports on the versions of workspace app your users are using to connect 

#> 


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
Parameter description

.PARAMETER hours
Parameter description

.PARAMETER Export
Parameter description

.PARAMETER ReportPath
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-CitrixWorkspaceAppVersions {
		[Cmdletbinding(DefaultParameterSetName='Set1', HelpURI = "https://smitpi.github.io/XDHealthCheck/Get-CitrixWorkspaceAppVersions")]
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
	if ($Export -eq 'HTML') { $ClientObject | Out-GridHtml -DisablePaging -Title "CitrixWorkspaceAppVersions" -HideFooter -SearchHighlight -FixedHeader -FilePath $(Join-Path -Path $ReportPath -ChildPath "\CitrixWorkspaceAppVersions-$(Get-Date -Format yyyy.MM.dd-HH.mm).html") }
	if ($Export -eq 'Host') { $ClientObject }


} #end Function
