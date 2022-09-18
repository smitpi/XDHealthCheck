
<#PSScriptInfo

.VERSION 1.0.10

.GUID bfdc02c2-9c62-4e67-a192-b55e3a7f2c8f

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Creates and distributes  a report on Catalog, groups and published app config. 

#> 



<#
.SYNOPSIS
Creates and distributes  a report on Catalog, groups and published app config.

.DESCRIPTION
Creates and distributes  a report on Catalog, groups and published app config.

.PARAMETER JSONParameterFilePath
Path to the json config file, created by Install-ParametersFile

.EXAMPLE
Start-CitrixAudit -JSONParameterFilePath 'C:\temp\Parameters.json'

#>
function Start-CitrixAudit {
	[Cmdletbinding(HelpURI = 'https://smitpi.github.io/XDHealthCheck/Start-CitrixAudit')]
	PARAM(
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.json') })]
		[string]$JSONParameterFilePath = (Get-Item $profile).DirectoryName + '\Parameters.json'
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
	[string]$Transcriptlog = "$ReportsFolder\logs\XDAudit_TransmissionLogs." + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.log'
	Start-Transcript -Path $Transcriptlog -IncludeInvocationHeader -Force -NoClobber
	$timer = [Diagnostics.Stopwatch]::StartNew();

	if ((Test-Path -Path $ReportsFolder\XDAudit) -eq $false) { New-Item -Path "$ReportsFolder\XDAudit" -ItemType Directory -Force -ErrorAction SilentlyContinue }
	if ([bool]$RemoveOldReports) {
		$oldReports = (Get-Date).AddDays(-$RemoveOldReports)
		Get-ChildItem $ReportsFolder\XDAudit *.html | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDAudit *.xlsx | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\XDAudit *.xml | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
		Get-ChildItem $ReportsFolder\logs\XDAudit_TransmissionLogs* | Where-Object { $_.LastWriteTime -le $oldReports } | Remove-Item -Force -Verbose
	}

	[string]$Reportname = $ReportsFolder + '\XDAudit\XD_Audit.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.html'
	[string]$XMLExport = $ReportsFolder + '\XDAudit\XD_Audit.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xml'
	[string]$ExcelReportname = $ReportsFolder + '\XDAudit\XD_Audit.' + (Get-Date -Format yyyy.MM.dd-HH.mm) + '.xlsx'

	#endregion

	########################################
	#region Connect and get info
	########################################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Collecting Farm Details"
	$CitrixObjects = Get-CitrixObjects -AdminServer $CTXDDC


	#######################
	#region Building HTML the report
	#######################
	Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing] Building HTML Page"

	$HeadingText = $DashboardTitle + ' | XenDesktop Audit | ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy) + ' ' + (Get-Date -Format HH:mm)
	New-HTML -TitleText 'XenDesktop Audit' -FilePath $Reportname {
		New-HTMLLogo -RightLogoString $XDHealth_LogoURL
		New-HTMLHeading -Heading h1 -HeadingText $HeadingText -Color Black
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Site Details' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.ObjectCount }
			New-HTMLSection -HeaderText 'Site Databases' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.Databases }
        }
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Site Controllers' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.Controllers }
			New-HTMLSection -HeaderText 'Site Licenses' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.Licenses }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Machine Catalogs' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.MachineCatalog }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Delivery Groups' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.DeliveryGroups }
		}
		New-HTMLSection @SectionSettings -Content {
			New-HTMLSection -HeaderText 'Published Apps' @TableSectionSettings { New-HTMLTable @TableSettings -DataTable $CitrixObjects.PublishedApps }
		}
	}
	#endregion

	#######################
	#region Saving Excel report
	#######################
	if ($SaveExcelReport) {
		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Processing] Saving Excel Report"
         $ExcelOptions = @{
            Path             = $ExcelReportname
            AutoSize         = $True
            AutoFilter       = $True
            TitleBold        = $True
            TitleSize        = '28'
            TitleFillPattern = 'LightTrellis'
            TableStyle       = 'Light20'
            FreezeTopRow     = $True
            FreezePane       = '3'
        }
        if ($CitrixObjects.ObjectCount) {$CitrixObjects.ObjectCount | Export-Excel -Title ObjectCount -WorksheetName ObjectCount @ExcelOptions}
        if ($CitrixObjects.Controllers) {$CitrixObjects.Controllers | Export-Excel -Title Controllers -WorksheetName Controllers @ExcelOptions}
        if ($CitrixObjects.Databases) {$CitrixObjects.Databases | Export-Excel -Title Databases -WorksheetName Databases @ExcelOptions}
        if ($CitrixObjects.Licenses) {$CitrixObjects.Licenses | Export-Excel -Title Licenses -WorksheetName Licenses @ExcelOptions}
        if ($CitrixObjects.MachineCatalog) {$CitrixObjects.MachineCatalog | Export-Excel -Title MachineCatalog -WorksheetName MachineCatalog @ExcelOptions}
        if ($CitrixObjects.DeliveryGroups) {$CitrixObjects.DeliveryGroups | Export-Excel -Title DeliveryGroups -WorksheetName DeliveryGroups @ExcelOptions}
        if ($CitrixObjects.PublishedApps) {$CitrixObjects.PublishedApps | Export-Excel -Title PublishedApps -WorksheetName PublishedApps @ExcelOptions}
        if ($CitrixObjects.VDAServers) {$CitrixObjects.VDAServers | Export-Excel -Title VDAServers -WorksheetName VDAServers @ExcelOptions}
        if ($CitrixObjects.VDAWorkstations) {$CitrixObjects.VDAWorkstations | Export-Excel -Title VDAWorkstations -WorksheetName VDAWorkstations @ExcelOptions}
   }
	#endregion
	
	#######################
	#region Sending email reports
	#######################
	if ($SendEmail) {

		$smtpClientCredentials = Find-Credential | Where-Object target -Like '*Healthcheck_smtp' | Get-Credential -Store
		if ($null -eq $smtpClientCredentials) {
			$Account = BetterCredentials\Get-Credential -Message 'smtp login for HealthChecks email'
			Set-Credential -Credential $Account -Target 'Healthcheck_smtp' -Persistence LocalComputer -Description 'Account used for ctx health checks' -Verbose
		}

		Write-Verbose "$((Get-Date -Format HH:mm:ss).ToString()) [Proccessing]Sending Report Email"
		$emailMessage = New-Object System.Net.Mail.MailMessage
		$emailMessage.From = $emailFrom
		$emailTo | ForEach-Object { $emailMessage.To.Add($_) }

		$emailMessage.Subject = $DashboardTitle + ' - Citrix Audit Results Report on ' + (Get-Date -Format dd) + ' ' + (Get-Date -Format MMMM) + ',' + (Get-Date -Format yyyy)
		$emailMessage.IsBodyHtml = $true
		$emailMessage.Body = 'Please see attached reports'
		$emailMessage.Attachments.Add($Reportname)
		$emailMessage.Attachments.Add($ExcelReportname)

		$smtpClient = New-Object System.Net.Mail.SmtpClient( $smtpServer , $smtpServerPort )
		$smtpClient.Credentials = [Net.NetworkCredential]$smtpClientCredentials
		$smtpClient.EnableSsl = $smtpEnableSSL
		$smtpClient.Timeout = 30000000
		$smtpClient.Send( $emailMessage )
	}
	#endregion

	$timer.Stop()
	$timer.Elapsed | Select-Object Days, Hours, Minutes, Seconds | Format-List
	Stop-Transcript
}


