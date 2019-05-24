
<#PSScriptInfo

.VERSION 1.0.1

.GUID 7942ecd6-a40d-488c-bb1e-dabeca200618

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
Date Created - 21/05/2019_19:57
Date Updated - 22/05/2019_20:14

.PRIVATEDATA

#> 



<#

.DESCRIPTION 
Xendesktop Farm Details

#>

Param()



Function Get-ScriptVariables {
    PARAM(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [xml]$Config)


    Write-Output "Using these Variables"
    $Config.Settings.Variables.Variable | ft
Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Variable Details"

$Config.Settings.Variables.Variable | foreach {
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
    If ($CreateVariable) { New-Variable -Name $_.Name -Value $VarValue -Scope $_.Scope -Force | Out-Host }
}

Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending] Variable Details"

} #end Function

<#
 #

 <?xml version="1.0" encoding="utf-8"?>
<settings>
	<Variables>
		<Variable>
			<Name>CTXDDC</Name>
			<Value>core-svr01.htpcza.com</Value> <!-- Add One Citrix Data Collector FQDN  -->
			<Type>[string]</Type>
			<Scope>Script</Scope>
		</Variable>
		<Variable>
			<Name>CTXStoreFront</Name>
			<Value>core-svr01.htpcza.com</Value> <!-- Add One Citrix StoreFront FQDN -->
			<Type>[string]</Type>
			<Scope>Script</Scope>
		</Variable>
		<Variable>
			<Name>RDSLicensServer</Name>
			<Value>core-svr01.htpcza.com</Value> <!-- Add RDS LicenseServer FQDN -->
			<Type>[string]</Type>
			<Scope>Script</Scope>
		</Variable>
<!-- E-Mail Configuration -->
		<Variable>
			<Name>emailFrom</Name>
			<Value>pierre.smit@eoh.com</Value> <!-- Address of the sender -->
			<Type>[string]</Type>
			<Scope>Script</Scope>
		</Variable>
		<Variable>
			<Name>emailTo</Name>
			<Value>pierre.smit@outlook.com</Value> <!-- Address of the recipient -->
			<Type>[string]</Type>
			<Scope>Script</Scope>
		</Variable>
		<Variable>
			<Name>smtpServer</Name>
			<Value>outlook.office365.com</Value> <!-- IP or name of SMTP server  -->
			<Type>[string]</Type>
			<Scope>Script</Scope>
		</Variable>
		<Variable>
			<Name>smtpServerPort</Name>
			<Value>587</Value> <!-- Port of SMTP server -->
			<Type>[string]</Type>
			<Scope>Script</Scope>
		</Variable>
		<Variable>
			<Name>smtpEnableSSL</Name>
			<Value>True</Value> <!-- Use ssl for SMTP or not(False or True) -->
			<Type>[bool]</Type>
			<Scope>Script</Scope>
		</Variable>
	</Variables>
</settings>

#>
