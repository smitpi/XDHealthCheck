
<#PSScriptInfo

.VERSION 1.0.0

.GUID 9203d8c1-e715-41b8-add7-15b79fa17e23

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT 

.TAGS AD

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Created [15/03/2021_18:58] Initital Script Creating

#>

<# 

.DESCRIPTION 
 Gui Wrapper for script 

#> 

Param()


Function Start-CitrixUserCompareGUI {
Add-Type -AssemblyName System.Windows.Forms
$btn_Click = {
	Start-CitrixUserCompare -Username1 $txtUsername1.Text -Username2 $txtUsername2.Text 
}
$item = Get-Item (Join-Path -Path ((Get-Module XDHealthCheck).ModuleBase).ToString() -ChildPath 'Private\Start-CitrixUserCompare.form.designer.ps1') 
. $item.FullName

$FormUserCompare.ShowDialog()




} #end Function
