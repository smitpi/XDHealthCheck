
<#PSScriptInfo

.VERSION 1.0.1

.GUID d34519b3-ab9b-4a1a-b86e-ace49d909036

.AUTHOR Pierre Smit

.COMPANYNAME Absa Corp:EUV Team

.COPYRIGHT

.TAGS EUV Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Date Created - 14/05/2019_16:39
Date Updated - 14/05/2019_16:40

.PRIVATEDATA

#> 



<# 

.DESCRIPTION 
CTX Dashboard

#> 

Param()
add-PSSnapin citrix*
Import-Module ActiveDirectory
Import-Module Pscx
Import-Module CTXDashboard -Force -Verbose

#$AdminServer = "ZAPRNBCTX0001.corp.dsarena.com"
$AdminServer ="core-svr01.htpcza.com"

############################
## Get ctx details for single user
############################

function UserAccessReport ($username){

#$AdminServer = "ZAPRNBCTX0001.corp.dsarena.com"
$AdminServer ="core-svr01.htpcza.com"
$UserDetail = Get-CitrixUserPublishedAccess -Username $username -AdminServer $AdminServer
$userDetailList = $UserDetail.UserDetail.psobject.Properties | Select-Object -Property Name, Value
$DesktopsCombined = $UserDetail.DirectPublishedDesktops + $UserDetail.PublishedDesktops | sort -Property DesktopGroupName -Unique

$HeddingText = "Access Report for User:" + $UserDetail.UserDetail.Name + " on " + (get-date -Format dd) + " " + (get-date -Format MMMM) + "," + (get-date -Format yyyy)
$HTMLReport = New-HTML -TitleText "Access Report" -FilePath  $PSScriptRoot\Dashboard01.html -ShowHTML {
New-HTMLHeading -Heading h1 -HeadingText $HeddingText -Color Black
New-HTMLSection -HeaderBackGroundColor DarkGray -Content {
    New-HTMLSection -HeaderText 'User details' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $userDetailList -HideFooter}
    New-HTMLSection -HeaderText 'Current Applications' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable ($UserDetail.AccessPublishedApps | Select PublishedName,Description,enabled) -HideFooter}
    New-HTMLSection -HeaderText 'Current Desktops' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable ($DesktopsCombined) -HideFooter}
}
New-HTMLSection -HeaderBackGroundColor DarkGray -Content {
    New-HTMLSection -HeaderText 'No Access Apps' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable ($UserDetail.NoAccessPublishedApps  | Select PublishedName,Description,enabled)  -HideFooter}
    New-HTMLSection -HeaderText 'All User Groups' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $UserDetail.AllUserGroups -HideFooter}
    }
}
}
####################################
## Get details for all published apps
####################################

function AllPublishedApps {
#$AdminServer = "ZAPRNBCTX0001.corp.dsarena.com"
$AdminServer ="core-svr01.htpcza.com"
$progress = New-ProgressBar -MaterialDesign -Type Horizontal -PrimaryColor Blue -Size Small -Theme Light
$PublishedApplicationObjects = Get-PublishedApplicationObjects -AdminServer $AdminServer
$DeliveryGroupObjects = Get-DeliveryGroupObjects -AdminServer $AdminServer
$AppsMissingGroups = $PublishedApplicationObjects | where {[bool]$_.PublishedAppGroup -EQ $false} |select DesktopGroupName,PublishedApp,PublishedAppUser |  sort PublishedApp -Unique
$DGMissingGroups = $DeliveryGroupObjects | where {[bool]$_.IncludeADGroups -eq $false -and $_.DeliveryType -like 'DesktopsAndApps'} | select DesktopGroupName,TotalDesktops,TotalApplications,IncludedUser
Close-ProgressBar -ProgressBar $progress

$HTMLReport = New-HTML -TitleText "Access Report" -FilePath  $PSScriptRoot\Dashboard01.html -ShowHTML {
New-HTMLSection -HeaderBackGroundColor DarkGray -Content {
    New-HTMLSection -HeaderText 'Published Applications'  -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue -CanCollapse -Collapsed {New-HTMLTable -DataTable ($PublishedApplicationObjects | select PublishedApp,HumanReadable,DesktopGroupName)  -HideFooter}
    New-HTMLSection -HeaderText 'Desktop Groups' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue -CanCollapse -Collapsed { New-HTMLTable -DataTable ($DeliveryGroupObjects | select HumanReadable, DesktopGroupName, DeliveryType, TotalDesktops, TotalApplications) -HideFooter}
}
New-HTMLSection -HeaderBackGroundColor DarkGray -Content {
    New-HTMLSection -HeaderText 'Delivery GRoups without Groups ' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $DGMissingGroups -HideFooter}
    New-HTMLSection -HeaderText 'Apps Without Applications' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $AppsMissingGroups -HideFooter}
    }
}
}
####################################
## Compare 2 user accounts
####################################

function CompareUsers {
                PARAM(
                [string]$Username1,
                [string]$Username2)

$ValidUser1 = Get-ADUser $Username1  -Properties * | select Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
$ValidUser2 = Get-ADUser $Username2  -Properties * | select Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
$userDetailList1 = $ValidUser1.psobject.Properties | Select-Object -Property Name, Value
$userDetailList2 = $ValidUser2.psobject.Properties | Select-Object -Property Name, Value

$user1Headding = $ValidUser1.Name
$user2Headding = $ValidUser2.Name
$user1HeaddingMissing = $ValidUser1.Name + " Missing"
$user2HeaddingMissing = $ValidUser2.Name + " Missing"



$allusergroups1 = Get-ADUser $Username1 -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object {Get-ADGroup $_} | select samaccountname
$allusergroups2 = Get-ADUser $Username2 -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object {Get-ADGroup $_} | select samaccountname

$Compare = Compare-Object -ReferenceObject $allusergroups1 -DifferenceObject $allusergroups2 -Property samaccountname -IncludeEqual

$SameGroups = $Compare | where {$_.SideIndicator -eq '=='} | select samaccountname
$User1Missing = $Compare | where {$_.SideIndicator -eq '=>'} | select samaccountname
$User2Missing = $Compare | where {$_.SideIndicator -eq '<='} | select samaccountname


$HTMLReport = New-HTML -TitleText "Compare User Report" -FilePath  $PSScriptRoot\Dashboard01.html -ShowHTML {
New-HTMLSection -HeaderBackGroundColor DarkGray -Content {
    New-HTMLSection -HeaderText $user1Headding -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue -CanCollapse -Collapsed {New-HTMLTable -DataTable $userDetailList1 -HideFooter}
    New-HTMLSection -HeaderText $user2Headding -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue -CanCollapse -Collapsed {New-HTMLTable -DataTable $userDetailList2 -HideFooter}
    }

New-HTMLSection -HeaderBackGroundColor DarkGray -Content {
    New-HTMLSection -HeaderText $user1HeaddingMissing -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $User1Missing -HideFooter}
    New-HTMLSection -HeaderText $user2HeaddingMissing -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $User2Missing  -HideFooter}
    New-HTMLSection -HeaderText 'Same Groups' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $SameGroups  -HideFooter}
    }


New-HTMLSection -HeaderBackGroundColor DarkGray -Content {
    New-HTMLSection -HeaderText $user1Headding -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $allusergroups1 -HideFooter}
    New-HTMLSection -HeaderText $user2Headding -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $allusergroups2  -HideFooter}
    }
}
}
####################################
## Get all Published Desktop Servers
####################################

function GetHostedDesktops {
#$AdminServer = "ZAPRNBCTX0001.corp.dsarena.com"
$AdminServer ="core-svr01.htpcza.com"
$desktops = Get-BrokerMachine -OSType "Windows 2016" -AdminAddress $AdminServer | select dnsname,DesktopGroupName,CatalogName | Sort-Object DesktopGroupName
#$promt =  @(New-AnyBoxPrompt -Message "Username" -Name Username -InputType Link)
#$UserAccess = Show-AnyBox @childWinParams -Title 'Compare Access Details' -Buttons 'Okay', 'Cancel' -CancelButton 'Cancel' -DefaultButton 'Okay' -Prompt $promt -GridData 
Import-Module AnyBox

$anybox = New-Object AnyBox.AnyBox

$anybox.Title = 'Desktops Services'
$anybox.ContentAlignment = 'Center'
$anybox.MaxHeight = 600

$anybox.GridData = $desktops
$anybox.Buttons = @(
  New-AnyBoxButton -Text 'Close'
)

$anybox | Show-AnyBox

$HTMLReport = New-HTML -TitleText "Access Report" -FilePath  $PSScriptRoot\Dashboard01.html -ShowHTML {
        New-HTMLSection -HeaderText 'Server details' -HeaderTextAlignment center -HeaderBackGroundColor RoyalBlue {New-HTMLTable -DataTable $desktops -HideFooter}
}
}


####################################
## Create the gui
####################################

$anypromt =  @(New-AnyBoxPrompt -Message "Choose Function" -Name Funtion -InputType Text -ValidateNotEmpty -ValidateSet 'Report On User Access','Report on All Apps','Compare two users','List Hosted Desktop Servers')
$anybutton = @(New-AnyBoxButton -Text Okay -Name Okay -IsCancel -IsDefault -OnClick {
if ($_.Funtion -eq 'Report On User Access'){
      $promt =  @(New-AnyBoxPrompt -Message "Username" -Name Username -InputType Text)
      $UserAccess = Show-AnyBox @childWinParams -Title 'Compare Access Details' -Buttons 'Okay', 'Cancel' -CancelButton 'Cancel' -DefaultButton 'Okay' -Prompt $promt
      UserAccessReport -username $UserAccess.Username
}
if ($_.Funtion -eq 'Report on All Apps'){AllPublishedApps}

        if ($_.Funtion -eq 'Compare two users')
        {
            $promt = @(New-AnyBoxPrompt -Message "Username 1" -Name Username1 -InputType Text)
            $promt += @(New-AnyBoxPrompt -Message "Username 2" -Name Username2 -InputType Text)
            $CompareUsers = Show-AnyBox @childWinParams -Title 'Compare Access Details' -Buttons 'Okay', 'Cancel' -CancelButton 'Cancel' -DefaultButton 'Okay' -Prompt $promt
            CompareUsers -Username1 $CompareUsers.Username1 -Username2 $CompareUsers.Username2

        }
if ($_.Funtion -eq 'List Hosted Desktop Servers') {GEtHostedDesktops}
})
$anybutton += @(New-AnyBoxButton -Text Close -Name Close -IsCancel)
$userinput = Show-AnyBox -Icon 'Question' -Title "Choose Function" -WindowStyle ThreeDBorderWindow -Message "Please supply your credentials" -Buttons $anybutton -Prompt $anypromt


