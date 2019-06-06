
<#PSScriptInfo

.VERSION 1.0.0

.GUID 144e3fd9-5999-4364-bdd6-99e1a6451adf

.AUTHOR Pierre Smit

.COMPANYNAME EUV Team

.COPYRIGHT

.TAGS Powershell

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Date Created - 06/06/2019_04:01

.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Universal Dashboard 

#> 

Param()

$CTXFunctions = New-UDEndpointInitialization -Module @('CTXHealthCheck','PoshRSJob')


$CTXHomePage = New-UDPage -Name 'Current Citrix Health Check' -DefaultHomePage -Icon home -Content{

	# New-UDFabButton -Id 'RefreshData1' -Text 'Refresh Data' -Floating -Icon refresh -OnClick {
	# 	$job = Start-RSJob -ScriptBlock { Initialize-CitrixHealthCheck -XMLParameterFilePath 'D:\users\smitp\GitRepository\XDHealthCheck\Modules\CTXHealthCheck\Private\Setup\Parameters.xml' -Verbose }
	# 	do {
	# 		Show-UDModal -Content { New-UDHeading -Text "Refreshing your data" } -Persistent
	# 		Start-Sleep -Seconds 4
	# 		Hide-UDModal
	# 	} until ($job.State -notlike 'Running')
	# }

	$latestreport = Get-Item ((Get-ChildItem \\corp.dsarena.com\za\group\120000_Euv\Personal\ABPS835-ADMIN\Powershell\Reports\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	[string]$latesthtml = Get-Content $latestreport.FullName
	#New-UDCard -Title "Data was captured on:" ($latestreport.LastWriteTime).ToString() -Size small -TextAlignment right
	New-UDCard -FontColor black -BackgroundColor white -Content {New-UDHtml $latesthtml}
 }

$CitrixAudit = New-UDPage -Name "Citrix Config Audit" -Content {
#New-UDGridLayout -Content {
#    New-UDCard -Title "Card 1" -Id 'Card1' 
#    New-UDCard -Title "Card 2" -Id 'Card2'
#    New-UDCard -Title "Card 3" -Id 'Card3'

  	$latestreport2 = Get-Item ((Get-ChildItem \\corp.dsarena.com\za\group\120000_Euv\Personal\ABPS835-ADMIN\Powershell\Reports\Audit\*.html | Sort-Object -Property LastWriteTime -Descending)[0]) | select *
	[string]$latesthtml2 = Get-Content $latestreport2.FullName
	#New-UDCard -Title "Data was captured on:" ($latestreport2.LastWriteTime).ToString() -Size small -TextAlignment right
	New-UDCard -FontColor black -BackgroundColor white -Content {New-UDHtml $latesthtml2}

} 



Get-UDDashboard | Stop-UDDashboard

$Dahboard  = New-UDDashboard -Title "XenDektop Universal Dashboard" -Pages @($CTXHomePage,$CitrixAudit) -EndpointInitialization $CTXFunctions

Start-UDDashboard -Dashboard $Dahboard -Port 10002
Start-Process http://localhost:10002

