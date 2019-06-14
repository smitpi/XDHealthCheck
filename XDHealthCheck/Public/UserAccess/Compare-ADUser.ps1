
<#PSScriptInfo

.VERSION 1.0.1

.GUID d972299f-af10-4c8b-a5fa-1ce80d8892af

.AUTHOR Pierre Smit

.COMPANYNAME

.COPYRIGHT

.TAGS AD

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [07/06/2019_03:58]
Updated [09/06/2019_09:18]

.PRIVATEDATA

#>



<#

.DESCRIPTION
Find the diferences in ad groups

#>

Param()



Function Compare-ADUser {
                PARAM(
                [Parameter(Mandatory=$true, Position=0, ValueFromPipeline = $true)]
                [ValidateNotNull()]
                [ValidateNotNullOrEmpty()]
                [string]$Username1,
                [Parameter(Mandatory=$true, Position=1)]
                [ValidateNotNull()]
                [ValidateNotNullOrEmpty()]
                [string]$Username2)


$ValidUser1 = Get-ADUser $Username1  -Properties * | Select-Object Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
$ValidUser2 = Get-ADUser $Username2  -Properties * | Select-Object Name,GivenName,Surname,UserPrincipalName, EmailAddress, EmployeeID, EmployeeNumber, HomeDirectory, Enabled, Created, Modified, LastLogonDate,samaccountname
$userDetailList1 = $ValidUser1.psobject.Properties | Select-Object -Property Name, Value
$userDetailList2 = $ValidUser2.psobject.Properties | Select-Object -Property Name, Value

$user1Headding = $ValidUser1.Name
$user2Headding = $ValidUser2.Name
$user1HeaddingMissing = $ValidUser1.Name + " Missing"
$user2HeaddingMissing = $ValidUser2.Name + " Missing"

$allusergroups1 = Get-ADUser $Username1 -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object {Get-ADGroup $_} | Select-Object samaccountname
$allusergroups2 = Get-ADUser $Username2 -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object {Get-ADGroup $_} | Select-Object samaccountname

$Compare = Compare-Object -ReferenceObject $allusergroups1 -DifferenceObject $allusergroups2 -Property samaccountname -IncludeEqual

$SameGroups = $Compare | Where-Object {$_.SideIndicator -eq '=='} | Select-Object samaccountname
$User1Missing = $Compare | Where-Object {$_.SideIndicator -eq '=>'} | Select-Object samaccountname
$User2Missing = $Compare | Where-Object {$_.SideIndicator -eq '<='} | Select-Object samaccountname


$User1Details = New-Object PSObject  -Property @{
        ValidUser1               = $ValidUser1
        userDetailList1          = $userDetailList1
        user1Headding            = $user1Headding
        user1HeaddingMissing     = $user1HeaddingMissing
        allusergroups1           = $allusergroups1
        User1Missing             = $User1Missing
        }
$User2Details = New-Object PSObject  -Property @{
        ValidUser2               = $ValidUser2
        userDetailList2          = $userDetailList2
        user2Headding            = $user2Headding
        user2HeaddingMissing     = $user2HeaddingMissing
        allusergroups2           = $allusergroups2
        User2Missing             = $User2Missing
        }

$Details = New-Object PSObject  -Property @{
User1Details = $User1Details
User2Details = $User2Details
SameGroups = $SameGroups
}
$Details

} #end Function

