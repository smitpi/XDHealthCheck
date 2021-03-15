
<#PSScriptInfo

.VERSION 1.0.0

.GUID c4ed36da-90b4-41a3-9cf3-a71ffeaa7395

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


Function Start-CitrixUserDetailGUI {
Add-Type -AssemblyName System.Windows.Forms
$btn_Click = {
	Start-CitrixUserDetail -Username $txtUsername.Text 
}
$item = Get-Item (Join-Path -Path ((Get-Module XDHealthCheck).ModuleBase).ToString() -ChildPath 'Private\Start-CitrixUserDetail.form.designer.ps1') 
. $item.FullName
$FormUserDetail.ShowDialog()




} #end Function
