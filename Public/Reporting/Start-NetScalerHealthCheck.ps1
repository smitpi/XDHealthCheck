
<#PSScriptInfo

.VERSION 1.0.2

.GUID fce0b5d2-4e70-46db-868f-c730cca11832

.AUTHOR Pierre Smit

.COMPANYNAME iOCO Tech

.COPYRIGHT

.TAGS Citrix

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [01/07/2020_16:01] Initital Script Creating
Updated [01/07/2020_16:07] Script Fle Info was updated
Updated [01/07/2020_16:13] Script Fle Info was updated

.PRIVATEDATA

#> 





<# 

.DESCRIPTION 
Function for Citrix XenDesktop HTML Health Check Report

#> 

Param()


Function Start-NetScalerHealthCheck {
	[CmdletBinding()]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq ".json") })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.json"
	)

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Importing Variables"
	##########################################
	#region xml imports
	##########################################
	Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath
	#endregion


	##########################################
	#region checking folders and report names
	##########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Starting] Data Collection"
	if ((Test-Path -Path $ReportsFolder\logs) -eq $false) { New-Item -Path "$ReportsFolder\logs" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	[string]$Transcriptlog = "$ReportsFolder\logs\XDNS_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".log"
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();


	if ((Test-Path -Path $ReportsFolder\XDNS) -eq $false) { New-Item -Path "$ReportsFolder\XDNS" -ItemType Directory -Force -ErrorAction SilentlyContinue }

	if ([bool]$RemoveOldReports) {
		$oldReports = (Get-Date).AddDays(-$RemoveOldReports)
		Get-ChildItem $ReportsFolder\XDNS *.html | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDNS *.xlsx | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDNS *.xml | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\logs\XDNS_TransmissionLogs* | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
	}
	[string]$Reportname = $ReportsFolder + "\XDNS\XDNS_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".html"
	[string]$ReportsXMLExport = $ReportsFolder + "\XDNS\XDNS_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xml"
	[string]$ExcelReportname = $ReportsFolder + "\XDNS\XDNS_Healthcheck." + (Get-Date -Format yyyy.MM.dd-HH.mm) + ".xlsx"
	#endregion

	########################################
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting License Details"
	$NetScalerInfo = @()
	$NetScalerInfo = $CTXNS | ForEach-Object {
		[PSCustomObject]@{
			DateCollected = (Get-Date -Format dd-MM-yyyy_HH:mm).ToString()
			NSIP      = $_.NSIP
			NSDetails = Get-CitrixNetscalerDetails -NSIP $_.nsip -NSCredentials $NSAdmin
		}
	}
	$NetScalerInfo | Export-Clixml -Path $ReportsXMLExport -NoClobber -Force

	#endregion

	########################################
	#region Setting some table color and settings
	########################################

	$TableSettings = @{
		#Style          = 'stripe'
		Style          = 'cell-border'
		HideFooter     = $true
		OrderMulti     = $true
		TextWhenNoData = 'No Data to display here'
	}

	$SectionSettings = @{
		BackgroundColor       = 'white'
		CanCollapse           = $true
		HeaderBackGroundColor = 'white'
		HeaderTextAlignment   = 'center'
		HeaderTextColor       = $HeaderColor
	}

	$TableSectionSettings = @{
		BackgroundColor       = 'white'
		HeaderBackGroundColor = $HeaderColor
		HeaderTextAlignment   = 'center'
		HeaderTextColor       = 'white'
	}
	#endregion

	#######################
	#region Building HTML the report
	#######################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"
	$NetScalerInfo | ForEach-Object {
		$Reportnamenew = $Reportname.Replace("XDNS_Healthcheck", "XDNS_" + $_.nsip + "_Healthcheck")
		$HeadingText = $DashboardTitle + " | NetScaler Report | " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy) + " " + (Get-Date -Format HH:mm)
		New-HTML -TitleText "NetScaler Report"  -FilePath $Reportnamenew {
			New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
			New-HTMLSection @SectionSettings  -Content {
				New-HTMLSection -HeaderText 'NS Details' @TableSectionSettings { New-HTMLTable   @TableSettings  -DataTable $_.NSDetails[0].NSDetails }
			}
			New-HTMLSection @SectionSettings   -Content {
				New-HTMLSection -HeaderText 'NS Ips'  @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  $_.NSDetails[0].NSIP4 }
				New-HTMLSection -HeaderText 'Load Balancer' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $_.NSDetails[0].NSLBVServer }
			}
			New-HTMLSection  @SectionSettings  -Content {
				New-HTMLSection -HeaderText 'NS Cert'  @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $_.NSDetails[0].NSCert }
				New-HTMLSection -HeaderText 'NS SG' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $_.NSDetails[0].NSLBSG }
			}
			New-HTMLSection  @SectionSettings -Content {
				New-HTMLSection -HeaderText 'NS GateWay' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable  $_.NSDetails[0].NSGateway }
				New-HTMLSection -HeaderText 'NS Content Switch' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $_.NSDetails[0].NSContentSwitch }
			}
		}
	}
	#endregion

	#######################
	#region Saving Excel report
	#######################
	if ($SaveExcelReport) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Saving Excel Report"
		$NetScalerInfo | ForEach-Object {
			$ExcelReportnameNew = $ExcelReportname.Replace("XDNS_Healthcheck", "XDNS_" + $_.nsip + "_Healthcheck")
			$_.NSDetails[0].NSDetails | Export-Excel -Path $ExcelReportnameNew -WorksheetName 'Details' -AutoSize -AutoFilter -TitleBold -TitleSize 20 -FreezePane 3
			$_.NSDetails[0].NSIP4 | Export-Excel -Path $ExcelReportnameNew -WorksheetName 'IP' -AutoSize -AutoFilter -TitleBold -TitleSize 20 -FreezePane 3
			$_.NSDetails[0].NSLBVServer | Export-Excel -Path $ExcelReportnameNew -WorksheetName 'NSLBVServer' -AutoSize -AutoFilter -TitleBold -TitleSize 20 -FreezePane 3
			$_.NSDetails[0].NSCert | Export-Excel -Path $ExcelReportnameNew -WorksheetName 'NSCert' -AutoSize -AutoFilter -TitleBold -TitleSize 20 -FreezePane 3
			$_.NSDetails[0].NSLBSG | Export-Excel -Path $ExcelReportnameNew -WorksheetName 'NSLBSG' -AutoSize -AutoFilter -TitleBold -TitleSize 20 -FreezePane 3
			$_.NSDetails[0].NSGateway | Export-Excel -Path $ExcelReportnameNew -WorksheetName 'NSGateway' -AutoSize -AutoFilter -TitleBold -TitleSize 20 -FreezePane 3
			$_.NSDetails[0].NSContentSwitch | Export-Excel -Path $ExcelReportnameNew -WorksheetName 'NSContentSwitch' -AutoSize -AutoFilter -TitleBold -TitleSize 20 -FreezePane 3
		}
	}
	#endregion

	#######################
	#region Sending email reports
	#######################
	if ($SendEmail) {

		$smtpClientCredentials = Find-Credential | Where-Object target -Like "*Healthcheck_smtp" | Get-Credential -Store
		if ($smtpClientCredentials -eq $null) {
			$Account = BetterCredentials\Get-Credential -Message "smtp login for HealthChecks email"
			Set-Credential -Credential $Account -Target "Healthcheck_smtp" -Persistence LocalComputer -Description "Account used for ctx health checks" -Verbose
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Sending Report Email"
		$emailMessage = New-Object System.Net.Mail.MailMessage
		$emailMessage.From = $emailFrom
        $emailTo | ForEach-Object {$emailMessage.To.Add($_)}
		$emailMessage.Subject = "Citrix Health Check Report on " + (Get-Date -Format dd) + " " + (Get-Date -Format MMMM) + "," + (Get-Date -Format yyyy)
		$emailMessage.IsBodyHtml = $true
		$emailMessage.Body = $emailbody
		$emailMessage.Attachments.Add((Get-ChildItem $ReportsFolder\XDNS *.html | Sort-Object LastWriteTime -Descending)[0])
		$emailMessage.Attachments.Add((Get-ChildItem $ReportsFolder\XDNS *.html | Sort-Object LastWriteTime -Descending)[1])
		$emailMessage.Attachments.Add((Get-ChildItem $ReportsFolder\XDNS *.xlsx | Sort-Object LastWriteTime -Descending)[0])
		$emailMessage.Attachments.Add((Get-ChildItem $ReportsFolder\XDNS *.xlsx | Sort-Object LastWriteTime -Descending)[1])
		$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
		#$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
		$smtpClient.EnableSsl = $smtpEnableSSL
		$smtpClient.Timeout = 30000000
		$smtpClient.Send( $emailMessage )
	}
	#endregion

	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Ending]Healthcheck Complete"

	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript
}
 #end Function
