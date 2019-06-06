cls
[string]$ScriptPath = $PSScriptRoot
Import-Module .\Modules\PSWriteColor\0.85\PSWriteColor.psm1

Write-Color -Text "Script Path - $ScriptPath" -Color Cyan -ShowTime
set-location -Path $ScriptPath
Write-Color -Text "Script Root Folder - $PSScriptRoot" -Color Cyan -ShowTime

[xml]$Parameters = Get-Content .\Parameters.xml

Write-Color -Text 'Checking Credentials' -Color DarkCyan -ShowTime
########################################
## Getting Credentials
#########################################

$smtpClientCredentials = Find-Credential | where target -Like "*Healthcheck_smtp" | Get-Credential -Store
if ($smtpClientCredentials -eq $null) {
    $Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
    Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}

$CTXAdmin = Find-Credential | where target -Like "*Healthcheck" | Get-Credential -Store
if ($CTXAdmin -eq $null) {
    $AdminAccount = BetterCredentials\Get-Credential -Message "Admin Account: DOMAIN\Username for CTX HealthChecks"
    Set-Credential -Credential $AdminAccount -Target "Healthcheck" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
}


########################################
## Build other variables
#########################################
Write-Color -Text 'Checking XML Parameters' -Color DarkCyan -ShowTime

$Parameters.Settings.Variables.Variable | ft
Write-Verbose "$((get-date -Format HH:mm:ss).ToString()) [Starting] Variable Details"

$Parameters.Settings.Variables.Variable | foreach {
		# Set Variables contained in XML file
		$VarValue = $_.Value
		$CreateVariable = $True # Default value to create XML content as Variable
		switch ($_.Type) {
			# Format data types for each variable
			'[string]' { $VarValue = [string]$VarValue } # Fixed-length string of Unicode characters
			'[char]' { $VarValue = [char]$VarValue } # A Unicode 16-bit character
			'[byte]' { $VarValue = [byte]$VarValue } # An 8-bit unsigned character
            '[bool]' { If ($VarValue.ToLower() -eq 'false'){$VarValue = [bool]$False} ElseIf ($VarValue.ToLower() -eq 'true'){$VarValue = [bool]$True} } # An boolean True/False value
			'[int]' { $VarValue = [int]$VarValue } # 32-bit signed integer
			'[long]' { $VarValue = [long]$VarValue } # 64-bit signed integer
			'[decimal]' { $VarValue = [decimal]$VarValue } # A 128-bit decimal value
			'[single]' { $VarValue = [single]$VarValue } # Single-precision 32-bit floating point number
			'[double]' { $VarValue = [double]$VarValue } # Double-precision 64-bit floating point number
			'[DateTime]' { $VarValue = [DateTime]$VarValue } # Date and Time
			'[Array]' { $VarValue = [Array]$VarValue.Split(',') } # Array
			'[Command]' { $VarValue = Invoke-Expression $VarValue; $CreateVariable = $False } # Command
		}
		If ($CreateVariable) { New-Variable -Name $_.Name -Value $VarValue -Scope $_.Scope -Force }
	}

Write-Color -Text 'Checking PS Remoting to servers' -Color DarkCyan -ShowTime

$DDC = Invoke-Command -ComputerName $CTXDDC.ToString() -Credential $CTXAdmin -ScriptBlock {[System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname}
$StoreFront = Invoke-Command -ComputerName $CTXStoreFront -Credential $CTXAdmin -ScriptBlock {[System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname}
$LicensServer = Invoke-Command -ComputerName $RDSLicensServer -Credential $CTXAdmin -ScriptBlock {[System.Net.Dns]::GetHostByName(($env:COMPUTERNAME)).Hostname}

if ($DDC -like '') {Write-Error '$CTXDDC is not valid'}
else {Write-Color -Text "$DDC is valid" -Color green -ShowTime }
if ($StoreFront -like '') {Write-Error '$CTXStoreFront is not valid'}
else {Write-Color -Text "$StoreFront is valid" -Color green -ShowTime}
if ($LicensServer -like '') {Write-Error '$RDSLicensServer is not valid'}
else {Write-Color -Text "$LicensServer is valid" -Color green -ShowTime}

if ($SendEmail){
Write-Color -Text 'Checking Sending Emails' -Color DarkCyan -ShowTime

$emailMessage = New-Object System.Net.Mail.MailMessage
$emailMessage.From = $emailFrom
$emailMessage.To.Add($emailTo)
$emailMessage.Subject = "Test Healthcheck Email"
$emailMessage.IsBodyHtml = $true
$emailMessage.Body = "Test Healthcheck Email"


$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
$smtpClient.EnableSsl = $smtpEnableSSL
$smtpClient.Timeout = 30000000


$smtpClient.Send( $emailMessage )

}