<#
    .SYNOPSIS
        Generates a report of a Citrix farm.

    .DESCRIPTION
        The Get-FarmReport.ps1 script retrieves all Citrix farm content, like Delivery Groups, Machine Catalogs, Machines, etc. The report format is based on the -Path parameter extension. This script uses the Monitoring Service configured on the Delivery Controller, so no additional snap-ins or modules are needed.

    .PARAMETER DeliveryController
        Address of the Delivery Controller to connect to

    .PARAMETER Path
        Path to the exported report. Report format is based on the file extension (can be either .docx, .pdf or .html)

    .PARAMETER Protocol
        Protocol to use, this can either be HTTP or HTTPS

    .PARAMETER Credential
        Credentials to use when connecting to the Delivery Controller

    .EXAMPLE
        Get-FarmReport.ps1 -DeliveryController SRVDC001.local.lab -Path C:\Data\MyFarm-Report.docx -Credential (Get-Credential)

        Creates a Citrix farm report connecting to Delivery Controller SRVDC001.local.lab and saves it as a Microsoft Word document. User is prompted for credentials.

    .EXAMPLE
        Get-FarmReport.ps1 -DeliveryController SRVDC001.local.lab -Path C:\Data\MyFarm-Report.html -Protocol HTTPS -Credential (Get-Credential)

        Creates a Citrix farm report connecting to Delivery Controller SRVDC001.local.lab, using a HTTPS connection and saves it as a HTML document. User is prompted for credentials.

    .NOTES
        Title:      Get-FarmReport
        Author:     Floris van der Ploeg
        Created:    2018-11-14		
        ChangeLog:
            2018-11-14 - Initial version
            2018-11-27 - Fixed hotfixes header formatting and missing information (machine name, change type)
#>

function Invoke-FarmDocumentation {
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)][string]$DeliveryController,
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$false)][ValidateSet("HTTP","HTTPS")][string]$Protocol = "HTTP",
    [Parameter(Mandatory=$false)][PSCredential]$Credential = [PSCredential]::Empty
)

<# Global variables #>
$Global:ScriptPath  = Split-Path $MyInvocation.MyCommand.Path -Parent
$Global:ScriptName  = Split-Path $MyInvocation.MyCommand.Path -Leaf
$Global:URLSuffix   = "/Citrix/Monitor/OData/v2/Data"
$Global:cache       = New-Object -TypeName System.Net.CredentialCache
$Global:WordObject  = $null
$Global:DocObject   = $null
$Global:TOCObject   = $null
$Global:HTMLObject  = ""

# PDF / DOCX specific styles
$Global:Styles = @{
    "DOCX" = @{
        "TitleStyle"        = "Title";
        "TableStyle"        = "Grid Table 4 - Accent 5";
        "ListTableStyle"    = "List Table 1 Light - Accent 5";
        "HeaderStyle"       = "Heading 1";
        "SubHeaderStyle"    = "Heading 2";
        "SubHeaderStyle2"   = "Heading 3";
        "SubHeaderStyle3"   = "Heading 4";
        "SubtitleStyle"     = "Subtitle"
    }
    "HTML" = @{
        "TitleStyle"        = "<h1>{0}</h1>";
        "TableStyle"        = "tbl-normal";
        "ListTableStyle"    = "tbl-list";
        "HeaderStyle"       = "<a name=`"{0}`"></a><h2>{0}</h2>";
        "SubHeaderStyle"    = "<h3>{0}</h3>";
        "SubHeaderStyle2"   = "<h4>{0}</h4>";
        "SubHeaderStyle3"   = "<h5>{0}</h5>";
        "SubtitleStyle"     = "<b>{0}</b><br />"
    }
}

# Monitoring specific enums
$Global:AllocationType = @{
    0 = @{"Name" = "Unknown"; "Description" = "Unknown. When the Broker does not send an allocation type."};
    1 = @{"Name" = "Static"; "Description" = "Machines get assigned to a user either by the admin or on first use. This relationship is static and changes only if an admin explicitly changes the assignments."};
    2 = @{"Name" = "Random"; "Description" = "Machines are allocated to users randomly from a pool of available machines."};
    3 = @{"Name" = "Permanent"; "Description" = "Equivalent to 'Static'."}
}
$Global:ApplicationType = @{
    0 = @{"Name" = "HostedOnDesktop"; "Description" = "The application is hosted from a desktop."};
    1 = @{"Name" = "InstalledOnClient"; "Description" = "The application is installed on a client."}
}
$Global:CatalogType = @{
    0 = @{"Name" = "ThinCloned"; "Description" = "A thin-cloned catalog is used for original golden VM images that are cloned when they are assigned to a VM, and users' changes to the VM image are retained after the VM is restarted."};
    1 = @{"Name" = "SingleImage"; "Description" = "A single-image catalog is used when multiple machines provisioned with Provisioning Services for VMs all share a single golden VM image when they run and, when restarted, they revert to the original VM image state."};
    2 = @{"Name" = "PowerManaged"; "Description" = "This catalog kind is for managed machines that are manually provisioned by administrators. All machines in this type of catalog are managed, and so must be associated with a hypervisor connection."};
    3 = @{"Name" = "Unmanaged"; "Description" = "This catalog kind is for unmanaged machines, so there is no associated hypervisor connection."};
    4 = @{"Name" = "Pvs"; "Description" = "This catalog kind is for managed machines that are provisioned using Provisioning Services. All machines in this type of catalog are managed, and so must be associated with a hypervisor connection. Only shared desktops are suitable for this catalog kind."};
    5 = @{"Name" = "Pvd"; "Description" = "A personal vDisk catalog is similar to a single-image catalog, but it also uses personal vDisk technology."};
    6 = @{"Name" = "PvsPvd"; "Description" = "A Provisioning Services-personal vDisk (PvsPvd) catalog is similar to a Provisioning Services catalog, but it also uses personal vDisk technology."}
}
$Global:HotfixChangeType = @{
    0 = @{"Name" = "Remove"; "Description" = "Removed"};
    1 = @{"Name" = "Add"; "Description" = "Added"}
}
$Global:DeliveryType = @{
    0 = @{"Name" = "DesktopsOnly"; "Description" = "Only desktops are published."};
    1 = @{"Name" = "AppsOnly"; "Description" = "Only applications are published."};
    2 = @{"Name" = "DesktopsAndApps"; "Description" = "Both desktops and applications are published."}
}
$Global:DesktopKind = @{
    0 = @{"Name" = "Private"; "Description" = "Private"};
    1 = @{"Name" = "Shared"; "Description" = "Shared"}
}
$Global:LifecycleState = @{
    0 = @{"Name" = "Active"; "Description" = "Default value - entity is active"};
    1 = @{"Name" = "Deleted"; "Description" = "Object was deleted"};
    2 = @{"Name" = "RequiresResolution"; "Description" = "Object was created, but values are missing, so a background process should poll to update missing values"};
    3 = @{"Name" = "Stub"; "Description" = "Stub object - for example, a Machine or Session that didn't really exist but is created by internal processing logic to preserve data relationships"}
}
$Global:MachineRole = @{
    0 = @{"Name" = "VDA"; "Description" = "VDA machine"};
    1 = @{"Name" = "DDC"; "Description" = "DDC machine"};
    2 = @{"Name" = "DDC, VDA"; "Description" = "Machine acting as VDA and DDC"}
}
$Global:PersistentUserChanges = @{
    0 = @{"Name" = "Unknown"; "Description" = "Unknown"};
    1 = @{"Name" = "Discard"; "Description" = "User changes are discarded."};
    2 = @{"Name" = "OnLocal"; "Description" = "User changes are persisted locally."};
    3 = @{"Name" = "OnPvd"; "Description" = "User changes are persisted on the Pvd."}
}
$Global:ProvisioningType = @{
    0 = @{"Name" = "Unknown"; "Description" = "Unknown"};
    1 = @{"Name" = "MCS"; "Description" = "Machine provisioned by Machine Creation Services (machine must be a VM)."};
    2 = @{"Name" = "PVS"; "Description" = "Machine provisioned by Provisioning Services (may be physical, blade, VM,...)."};
    3 = @{"Name" = "Manual"; "Description" = "No automated provisioning."}
}
$Global:RegistrationState = @{
    0 = @{"Name" = "Unknown"; "Description" = "Unknown"};
    1 = @{"Name" = "Registered"; "Description" = "Machine is currently registered."};
    2 = @{"Name" = "Unregistered"; "Description" = "Machine has been unregistered."}
}

<# Functions #>
Function Write-Log {
    Param
    (
        [Parameter(Mandatory=$true,Position=0)][string]$Value,
        [Parameter(Mandatory=$false,Position=1)][ConsoleColor]$Color = "White"
    )

    Write-Host ("[{0:dd-MM-yyyy HH:mm:ss}] " -f (Get-Date)) -NoNewline
    Write-Host $Value -ForegroundColor $Color
}

Function Invoke-ODataRequest {
    Param (
        [Parameter(Mandatory=$true)][string]$URL,
        [Parameter(Mandatory=$true)][string]$Table,
        [Parameter(Mandatory=$false)][string]$TableFilter = "",
        [Parameter(Mandatory=$false)][string]$SubObject = $null,
        [Parameter(Mandatory=$false)][HashTable]$ArgumentList        
    )

    # Create the return object
    $returnobject = @{
        "Status" = $false;
        "Message" = "";
        "Data" = $null
    }

    # Construct the ClientHandler and add the global credential cache
    $handler = New-Object -TypeName System.Net.Http.HttpClientHandler
    $handler.Credentials = $cache

    # Construct the URL based on the argument list
    if (-not [string]::IsNullOrEmpty($SubObject)) {
        $subobjecturl = "/$SubObject"
    } else {
        $subobjecturl = ""
    }
    $odataurl = ("{0}/{1}({2}){3}?`$format=json" -f $URL,$Table,$TableFilter,$subobjecturl)

    # Add each argumentlist item to the url
    foreach ($item in $ArgumentList.Keys) {
        $odataurl += "&`$" + ([System.Web.HttpUtility]::UrlEncode($item)) + "=" + ([System.Web.HttpUtility]::UrlEncode($ArgumentList[$item]))
    }

    # Create the HttpClient and get the result from the GET request
    $client = New-Object -TypeName System.Net.Http.HttpClient -ArgumentList $handler
    $client.DefaultRequestHeaders.Accept.Add([System.Net.Http.Headers.MediaTypeWithQualityHeaderValue]("application/json"))

    # Get the result from the GET request
    $result = $client.GetAsync($odataurl).Result
    if ($result.IsSuccessStatusCode -eq $true) {
        $returnobject.Status = $true
        $returnobject.Data = ConvertFrom-Json $result.Content.ReadAsStringAsync().Result
    } else {
        $returnobject.Message = $result.StatusCode
    }

    return $returnobject
}

Function Test-Connection {
    Param (
        [Parameter(Mandatory=$true)][string]$URL
    )

    $returnobject = @{
        "Status" = $false;
        "Message" = ""
    }

    # Construct the ClientHandler and add the global credential cache
    $handler = New-Object -TypeName System.Net.Http.HttpClientHandler
    $handler.Credentials = $cache

    # Create the HttpClient and get the result from the GET request
    $client = New-Object -TypeName System.Net.Http.HttpClient -ArgumentList $handler
    $result = $client.GetAsync($url).Result

    $returnobject.Status = $result.IsSuccessStatusCode
    if ($result.IsSuccessStatusCode -eq $false) {
        $returnobject.Message = $result.StatusCode
    }

    return $returnobject
}

Function New-Table {
    Param (
        [Parameter(Mandatory=$true)][string[]]$Columns
    )

    $tbl_object = New-Object -TypeName System.Data.DataTable
    foreach ($column in $Columns) {
        $tbl_object.Columns.Add($column) | Out-Null
    }
    
    return ,$tbl_object
}

Function Add-TableItem {
    Param (
        [Parameter(Mandatory=$true)][PSCustomObject]$Item,
        [Parameter(Mandatory=$true)][System.Data.DataTable][Ref]$Table,
        [Parameter(Mandatory=$false)][switch]$NoDateProcessing
    )

    # Add all item properties to the table which have a valid mapping to the column
    $hasvalue = $false
    $row = $Table.NewRow()
    foreach ($column in $Table.Columns) {
        if ($item.PSobject.Properties.name -contains $column.ColumnName) {
            if ($NoDateProcessing.ToBool() -ne $true -and $column.ColumnName -like "*Date") {
                try {
                    $row[$column.ColumnName] = [datetime]::Parse($Item.($column.ColumnName))
                } catch {
                    $row[$column.ColumnName] = $null
                }
            } else {
                $row[$column.ColumnName] = $Item.($column.ColumnName)
            }
            $hasvalue = $true
        }
    }

    if ($hasvalue) {
        $Table.Rows.Add($row)
    }
}

Function Get-AssignedMachines {
    Param (
        [Parameter(Mandatory=$true)][System.Data.DataTable][Ref]$Table,
        [Parameter(Mandatory=$true)][string]$Filter,
        [Parameter(Mandatory=$false)][switch]$Deleted
    )

    # Create the return table
    $machinetable = New-Table -Columns "Name", "Domain", "DNS Name", "IP Address", "Registration State", "Operating System", "Machine Role"

    # Construct the query
    if ($Deleted.ToBool() -eq $true) {
        $query = "$Filter AND LifecycleState = 3"
    } else {
        $query = "$Filter AND (LifecycleState = 0 OR LifecycleState = 2)"
    }

    # Retrieve the machines associated with this filter
    foreach ($item in $Table.Select($query)) {
        $row = $machinetable.NewRow()

        # Inject the data
        $row["Name"] = $item["Name"].Split("\")[1]
        $row["Domain"] = $item["Name"].Split("\")[0]
        $row["DNS Name"] = $item["DnsName"]
        $row["IP Address"] = $item["IPAddress"]
        $row["Registration State"] = $RegistrationState[[int]$item["CurrentRegistrationState"]].Name
        $row["Operating System"] = $item["OSType"]
        $row["Machine Role"] = $MachineRole[[int]$item["MachineRole"]].Name

        $machinetable.Rows.Add($row)
    }

    return ,$machinetable
}

Function Get-TableItem {
    Param (
        [Parameter(Mandatory=$true)][System.Data.DataTable][Ref]$Table,
        [Parameter(Mandatory=$true)][string]$Field,
        [Parameter(Mandatory=$true)][AllowEmptyString()][string]$Value,
        [Parameter(Mandatory=$false)][string]$Property = "Name"
    )

    if ([string]::IsNullOrEmpty($Value)) {
        return ""
    } else {
        $rows = $Table.Select("$Field = '$Value'")
        if ($rows.Count -gt 0) {
            return $rows[0][$Property]
        } else {
            return "Unknown"
        }
    }
}

Function Invoke-ReportInitialization {
    Param (
        [Parameter(Mandatory=$true)][ValidateSet("DOCX","PDF","HTML")][string]$ReportType
    )

    if ($ReportType -eq "DOCX" -or $ReportType -eq "PDF") {
        # Set default settings
        $WordObject.Visible = $false
        $Global:DocObject = $WordObject.Documents.Add()

        # Insert the first page
        $selection = $WordObject.Selection

        # Set the correct style
        $selection.Style = $Styles["DOCX"]["TitleStyle"]
        $selection.TypeText("Citrix Farm Report")
        $selection.TypeParagraph()

        # Add a page break
        Add-PageBreak -ReportType $ReportType

        # Set the footer
        $Global:DocObject.Sections.Item(1).Footers.Item(1).PageNumbers.Add([Microsoft.Office.Interop.Word.WdPageNumberAlignment]::wdAlignPageNumberRight) | Out-Null

        # Insert the table of contents
        $Global:TOCObject = $Global:DocObject.TablesOfContents.Add($WordObject.Selection.Range)
        $WordObject.Selection.TypeParagraph()

        # Add a page break
        Add-PageBreak -ReportType $ReportType
    } elseif ($ReportType -eq "HTML") {
        # Clear any HTML code currently stored
        $Global:HTMLObject = ""
        $Global:TOCObject = @()

        # Create the HTML header and style
        $Global:HTMLObject += "<html>`r`n"
        $Global:HTMLObject += "<head>`r`n"
        $Global:HTMLObject += "    <title>Citrix Farm Report</title>`r`n"
        $Global:HTMLObject += "    <style type=`"text/css`">`r`n"
        $Global:HTMLObject += "    body { padding: 0px; margin: 0px; }`r`n"
        $Global:HTMLObject += "    html, td, th { font-family: `"Segoe UI Light`",`"Segoe UI Web Light`",`"Segoe UI Web Regular`",`"Segoe UI`",`"Segoe UI Symbol`",`"HelveticaNeue-Light`",`"Helvetica Neue`",Arial,sans-serif; font-size: 10pt; }`r`n"
        $Global:HTMLObject += "    table { border-collapse: collapse; }`r`n"
        $Global:HTMLObject += "    thead { text-align: left; font-weight: bold; }`r`n"
        $Global:HTMLObject += "    td:first-child { font-weight: bold; }`r`n"
        $Global:HTMLObject += "    tr:nth-child(even) { background-color: #f8f8f8; }`r`n"
        $Global:HTMLObject += "    th { padding-top: 8px; padding-bottom: 8px; background-color: #cccccc; }`r`n"
        $Global:HTMLObject += "    table.tbl-normal { width: 100%; }`r`n"
        $Global:HTMLObject += "    table.tbl-normal td, table.tbl-normal th { text-align: left; vertical-align: top; padding: 4px; border: 1px solid #e0e0e0;  }`r`n"
        $Global:HTMLObject += "    table.tbl-list td, table.tbl-list th { text-align: left; vertical-align: top; padding: 4px; border-bottom: 1px solid #e0e0e0;  }`r`n"
        $Global:HTMLObject += "    table.tbl-list th { background-color: #ffffff; }`r`n"
        $Global:HTMLObject += "    table.tbl-list td:first-child { padding-right: 20px; }`r`n"
        $Global:HTMLObject += "    table.tbl-normal td.td-norecords { text-align: center; font-weight: bold; padding: 15px 0; }`r`n"
        $Global:HTMLObject += "    h1 { margin-top: 0; }`r`n"
        $Global:HTMLObject += "    #nav { padding: 10px; width: 200px; position: fixed; top: 0px; bottom: 0px; }`r`n"
        $Global:HTMLObject += "    #content { padding: 10px; margin-left: 200px; }`r`n"
        $Global:HTMLObject += "    #nav ul { list-style-type: none; padding: 0; margin: 0px; }`r`n"
        $Global:HTMLObject += "    #nav ul li { padding: 3px 0; font-weight: bold; }`r`n"
        $Global:HTMLObject += "    #nav ul li a, #nav ul li a:visited { text-decoration: none; color: blue; }`r`n"
        $Global:HTMLObject += "    #nav ul li a:hover { text-decoration: none; color: #000000; }`r`n"
        $Global:HTMLObject += "    </style>`r`n"
        $Global:HTMLObject += "</head>`r`n`r`n"
        $Global:HTMLObject += "<body>`r`n`r`n"

        $Global:HTMLObject += "<div id=`"nav`">`r`n"
        $Global:HTMLObject += "###TOC###"
        $Global:HTMLObject += "</div>`r`n"
        $Global:HTMLObject += "<div id=`"content`">`r`n"
        $Global:HTMLObject += " " + ($Styles["HTML"]["TitleStyle"] -f "Citrix Farm Report") + "`r`n`r`n"
    }
}

Function Invoke-ReportFinalize {
    Param (
        [Parameter(Mandatory=$true)][ValidateSet("DOCX","PDF","HTML")][string]$ReportType
    )

    if ($ReportType -eq "DOCX" -or $ReportType -eq "PDF") {
        # Update the TOC
        $Global:TOCObject.Update() | Out-Null
    } elseif ($ReportType -eq "HTML") {
        $Global:HTMLObject += "</div>`r`n"
        $Global:HTMLObject += "</body>`r`n"
        $Global:HTMLObject += "</html>`r`n"

        # Inject the TOC
        $toc = "    <ul>"
        foreach ($obj in $Global:TOCObject) {
            $toc += "       <li><a href=`"#$obj`">$obj</a></li>`r`n"
        }
        $toc += "    </ul>`r`n"
        $Global:HTMLObject = $Global:HTMLObject -replace "###TOC###",$toc
    }
}

Function Save-Report {
    Param (
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][ValidateSet("DOCX","PDF","HTML")][string]$ReportType
    )
    
    if ($ReportType -eq "DOCX") {
        $Global:DocObject.SaveAs([ref]$Path, [ref][Microsoft.Office.Interop.Word.WdSaveFormat]::wdFormatDocumentDefault)
    } elseif ($ReportType -eq "PDF") {
        $Global:DocObject.SaveAs([ref]$Path, [ref][Microsoft.Office.Interop.Word.WdSaveFormat]::wdFormatPDF)
    } elseif ($ReportType -eq "HTML") {
        $Global:HTMLObject | Set-Content -Path $Path -Force
    }
}

Function Add-PageBreak {
    Param (
        [Parameter(Mandatory=$true)][ValidateSet("DOCX","PDF","HTML")][string]$ReportType
    )

    if ($ReportType -eq "DOCX" -or $ReportType -eq "PDF") {
        $selection = $WordObject.Selection
        $selection.EndOf([Microsoft.Office.Interop.Word.WdUnits]::wdStory) | Out-Null
        $selection.InsertBreak([Microsoft.Office.Interop.Word.WdBreakType]::wdPageBreak)
    }
}

Function Set-PageOrientation {
    Param (
        [Parameter(Mandatory=$true)][ValidateSet("DOCX","PDF","HTML")][string]$ReportType,
        [Parameter(Mandatory=$true)][ValidateSet("Portrait","Landscape")][string]$Orientation
    )

    if ($ReportType -eq "DOCX" -or $ReportType -eq "PDF") {
        $selection = $WordObject.Selection
        $selection.EndOf([Microsoft.Office.Interop.Word.WdUnits]::wdStory) | Out-Null
        $selection.InsertBreak([Microsoft.Office.Interop.Word.WdBreakType]::wdSectionBreakNextPage)
        if ($Orientation -eq "Portrait") {
            $selection.PageSetup.Orientation = [Microsoft.Office.Interop.Word.WdOrientation]::wdOrientPortrait
        } elseif ($Orientation -eq "Landscape") {
            $selection.PageSetup.Orientation = [Microsoft.Office.Interop.Word.WdOrientation]::wdOrientLandscape
        }
    }
}

Function Add-ReportTable {
    Param (
        [Parameter(ParameterSetName='AsTable',Mandatory=$true)][System.Data.DataTable]$Table,
        [Parameter(ParameterSetName='AsList',Mandatory=$true)][System.Data.DataRow]$Row,
        [Parameter(ParameterSetName='AsObject',Mandatory=$true)][Object]$Object,
        [Parameter(Mandatory=$true)][ValidateSet("DOCX","PDF","HTML")][string]$ReportType,
        [Parameter(Mandatory=$false)][string]$NoRecordsText = "No records found",
        [Parameter(Mandatory=$false)][string[]]$ExcludeColumns = $null,
        [Parameter(Mandatory=$false)][string[]]$IncludeColumns = $null
    )
    
    if ($PSCmdlet.ParameterSetName -eq "AsTable") {
        # Calculate row and column count
        if ($Table.Rows.Count -gt 0) {
            $rows = $Table.Rows.Count + 1
        } else {
            $rows = 2
        }

        $columns = @()
        foreach ($col in $Table.Columns) {
            if ($null -ne $ExcludeColumns) {
                if ($ExcludeColumns -notcontains $col.ColumnName) {
                    $columns += $col.ColumnName
                }
            } elseif ($null -ne $IncludeColumns) {
                if ($IncludeColumns -contains $col.ColumnName) {
                    $columns += $col.ColumnName
                }
            } else {
                $columns += $col.ColumnName
            }
        }

        if ($ReportType -eq "DOCX" -or $ReportType -eq "PDF") {
            # Get the object selection
            $selection = $WordObject.Selection

            # Add the table with the correct number of rows and columns
            $tableobject = $selection.Tables.Add($selection.Range, $rows, $columns.Length, [Microsoft.Office.Interop.Word.WdDefaultTableBehavior]::wdWord9TableBehavior, [Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitWindow)
            if (-not [string]::IsNullOrEmpty($Styles["DOCX"]["TableStyle"])) {
                $tableobject.Style = $Styles["DOCX"]["TableStyle"]
            }

            # Fill the headers
            for ($i = 0; $i -lt $columns.Length; $i++) {
                $tableobject.Cell(1, $i + 1).Range.Bold = $true
                $tableobject.Cell(1, $i + 1).Range.Text = $columns[$i]
            }

            # Fill all rows
            if ($Table.Rows.Count -gt 0) {
                for ($i = 0; $i -lt $Table.Rows.Count; $i++) {
                    for ($c = 0; $c -lt $columns.Length; $c++) {
                        if ($Table.Rows[$i][$columns[$c]] -ne [System.DBNull]::Value) {
                            $tableobject.Cell($i + 2, $c + 1).Range.Text = $Table.Rows[$i][$columns[$c]]
                        }
                    }
                }
            } else {
                # No rows found, merge cells and display "not found" text
                for ($t = 1; $t -lt $columns.Length; $t++) {
                    $tableobject.Cell(2,1).Merge($tableobject.Cell(2,2))
                }
                $tableobject.Cell(2,1).Range.Bold = $true
                $tableobject.Cell(2,1).Range.Text = $NoRecordsText
                @($tableobject.Cell(2,1).Range.Paragraphs)[-1].Alignment = [Microsoft.Office.Interop.Word.WdParagraphAlignment]::wdAlignParagraphCenter
                @($tableobject.Cell(2,1).Range.Paragraphs)[-1].SpaceBefore = 25
                @($tableobject.Cell(2,1).Range.Paragraphs)[-1].SpaceAfter = 25
            }

            # Move to the end of the table and finish the paragraph
            $selection.EndOf([Microsoft.Office.Interop.Word.WdUnits]::wdStory) | Out-Null
            $selection.TypeParagraph()
        } elseif ($ReportType -eq "HTML") {
            $Global:HTMLObject += " <p>`r`n"
            $Global:HTMLObject += " <table class=`"$($Styles["HTML"]["TableStyle"])`">`r`n"

            # Create the table head
            $Global:HTMLObject += "     <thead>`r`n"
            $Global:HTMLObject += "         <tr>`r`n"
            foreach ($col in $columns) {
                $Global:HTMLObject += "             <th>$col</th>`r`n"
            }
            $Global:HTMLObject += "         </tr>`r`n"
            $Global:HTMLObject += "     </thead>`r`n"

            # Fill the table body
            $Global:HTMLObject += "     <tbody>`r`n"
            if ($Table.Rows.Count -gt 0) {
                foreach ($row in $Table.Rows) {
                    $Global:HTMLObject += "         <tr>`r`n"
                    foreach ($col in $columns) {
                        if ($rows[$col] -ne [System.DBNull]::Value) {
                            $Global:HTMLObject += "             <td>$($row[$col])</td>`r`n"
                        } else {
                            $Global:HTMLObject += "             <td>&nbsp;</td>`r`n"
                        }
                    }
                    $Global:HTMLObject += "         </tr>`r`n"
                }
            } else {
                $Global:HTMLObject += "         <tr>`r`n"
                $Global:HTMLObject += "             <td colspan=`"$($columns.Length)`" class=`"td-norecords`">$NoRecordsText</td>`r`n"
                $Global:HTMLObject += "         </tr>`r`n"
            }
            $Global:HTMLObject += "     </tbody>`r`n"

            $Global:HTMLObject += " </table>`r`n"
            $Global:HTMLObject += " </p>`r`n"
        }
    } elseif ($PSCmdlet.ParameterSetName -eq "AsList" -or $PSCmdlet.ParameterSetName -eq "AsObject") {
        # Get the columns from the row
        $columns = @()

        if ($PSCmdlet.ParameterSetName -eq "AsList") {
            $columnlist = ($Row.PSBase.Table.Columns | Select-Object -ExpandProperty ColumnName)
        } elseif ($PSCmdlet.ParameterSetName -eq "AsObject") {
            $columnlist = ($Object.PSObject.Properties | Select-Object -ExpandProperty Name)
        }

        foreach ($col in $columnlist) {
            if ($null -ne $ExcludeColumns) {
                if ($ExcludeColumns -notcontains $col) {
                    $columns += $col
                }
            } elseif ($null -ne $IncludeColumns) {
                if ($IncludeColumns -contains $col) {
                    $columns += $col
                }
            } else {
                $columns += $col
            }
        }

        if ($ReportType -eq "DOCX" -or $ReportType -eq "PDF") {
            # Get the object selection
            $selection = $WordObject.Selection

            # Add the table with the correct number of rows and columns
            $tableobject = $selection.Tables.Add($selection.Range, $columns.Length + 1, 2, [Microsoft.Office.Interop.Word.WdDefaultTableBehavior]::wdWord9TableBehavior, [Microsoft.Office.Interop.Word.WdAutoFitBehavior]::wdAutoFitWindow)
            if (-not [string]::IsNullOrEmpty($Styles["DOCX"]["ListTableStyle"])) {
                $tableobject.Style = $Styles["DOCX"]["ListTableStyle"]
            }

            # Add the header
            $tableobject.Cell(1, 1).Range.Bold = $true
            $tableobject.Cell(1, 1).Range.Text = "Name"
            $tableobject.Cell(1, 2).Range.Bold = $true
            $tableobject.Cell(1, 2).Range.Text = "Value"

            # Fill the cells
            for ($i = 0; $i -lt $columns.Length; $i++) {
                $tableobject.Cell($i + 2, 1).Range.Text = $columns[$i]
                if ($PSCmdlet.ParameterSetName -eq "AsList") {
                    if ($Row[$columns[$i]] -ne [System.DBNull]::Value) {
                        $tableobject.Cell($i + 2, 2).Range.Text = $Row[$columns[$i]]
                    }
                } elseif ($PSCmdlet.ParameterSetName -eq "AsObject") {
                    $tableobject.Cell($i + 2, 2).Range.Text = $Object.($columns[$i]).ToString()
                }
            }

            # Move to the end of the table and finish the paragraph
            $selection.EndOf([Microsoft.Office.Interop.Word.WdUnits]::wdStory) | Out-Null
            $selection.TypeParagraph()
        } elseif ($ReportType -eq "HTML") {
            $Global:HTMLObject += " <p>`r`n"
            $Global:HTMLObject += " <table class=`"$($Styles["HTML"]["ListTableStyle"])`">`r`n"

            # Create the table head
            $Global:HTMLObject += "     <thead>`r`n"
            $Global:HTMLObject += "         <tr>`r`n"
            $Global:HTMLObject += "             <th>Name</th>`r`n"
            $Global:HTMLObject += "             <th>Value</th>`r`n"
            $Global:HTMLObject += "         </tr>`r`n"
            $Global:HTMLObject += "     </thead>`r`n"

            # Fill the cells
            $Global:HTMLObject += "     <tbody>`r`n"
            foreach ($col in $columns) {
                $Global:HTMLObject += "         <tr>`r`n"
                $Global:HTMLObject += "             <td>$col</td>`r`n"
                if ($PSCmdlet.ParameterSetName -eq "AsList") {
                    if ($Row[$col] -ne [System.DBNull]::Value) {
                        $Global:HTMLObject += "             <td>$($Row[$col])</td>`r`n"
                    } else {
                        $Global:HTMLObject += "             <td>&nbsp;</td>`r`n"
                    }
                } elseif ($PSCmdlet.ParameterSetName -eq "AsObject") {
                    $Global:HTMLObject += ("             <td>{0}</td>`r`n" -f $Object.($col).ToString())
                }
                $Global:HTMLObject += "         </tr>`r`n"
            }
            $Global:HTMLObject += "     </tbody>`r`n"

            $Global:HTMLObject += " </table>`r`n"
            $Global:HTMLObject += " </p>`r`n"
        }
    }
}

Function Add-ReportHeader {
    Param (
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][ValidateSet("DOCX","PDF","HTML")][string]$ReportType,
        [Parameter(Mandatory=$false)][string]$Style = "Heading 1"
    )

    if ($ReportType -eq "DOCX" -or $ReportType -eq "PDF") {
        # Get the object selection
        $selection = $WordObject.Selection

        # Set the correct style
        $selection.Style = $Style
        $selection.TypeText($Name)
        $selection.TypeParagraph()
    } elseif ($ReportType -eq "HTML") {
        $Global:HTMLObject += " "
        $Global:HTMLObject += ($Style -f $Name)
        $Global:HTMLObject += "`r`n`r`n"

        if ($Style -eq $Global:Styles["HTML"]["HeaderStyle"]) {
            # If this is a header object, add it to the TOC
            $Global:TOCObject += $Name
        }
    }
}

Function Sort-Table {
    Param (
        [Parameter(Mandatory=$true)][System.Data.DataTable]$Table,
        [Parameter(Mandatory=$true)][string]$SortColumn,
        [Parameter(Mandatory=$false)][ValidateSet("ASC","DESC")][string]$Direction = "ASC"
    )

    $_tmp = $Table.DefaultView
    $_tmp.Sort = "[$SortColumn] $Direction"

    return ,$_tmp.ToTable()
}

<# Main script #>
Write-Log -Value "**** Starting Farm Enumeration ****" -Color Yellow

# Save start time
$start = (Get-Date)

# Check extension
$extension = [System.IO.Path]::GetExtension($Path).Replace(".","").ToLower()
$formattingextension = ""
$exportextension = ""
if ($extension -eq "docx" -or $extension -eq "doc") {
    $exportextension = "DOCX"
    $formattingextension = "DOCX"
} elseif ($extension -eq "pdf") {
    $exportextension = "PDF"
    $formattingextension = "DOCX"
} elseif ($extension -eq "html" -or $extension -eq "htm") {
    $exportextension = "HTML"
    $formattingextension = "HTML"
} else {
    Write-Log -Value "Could not export report: unknown extension $extension" -Color Red
    return
}

# Check if the Word Application is available when exporting DOCX or PDF
Write-Log -Value "Using export method: $exportextension" -Color Yellow
if ($exportextension -eq "DOCX" -or $exportextension -eq "PDF") {
    Write-Log -Value "Checking availability of Microsoft Word" -Color Yellow
    try {
        $WordObject = New-Object -ComObject Word.Application
        $WordObject.Visible = $false

        Write-Log -Value "Microsoft Word availability check OK" -Color Green
    } catch {
        Write-Log -Value "Could not export report using export method $($exportextension): Microsoft Word can't be started" -Color Red
        return
    }
}

# Add mandatory .Net types
Add-Type -Assembly System.Web | Out-Null
Add-Type -Assembly System.Net.Http | Out-Null

# Construct the base URL
$url = ("{0}://{1}{2}" -f $Protocol.ToLower(),$DeliveryController,$URLSuffix)

# Check if the credentials need to be stored
if ($Credential -ne [PSCredential]::Empty -and $Credential -ne $null) {
    # Store the credentials in the global Credential Cache
    $cache.Add([Uri]($url), "Negotiate", $Credential.GetNetworkCredential())
}

# Check if the connection works
Write-Log -Value "Checking connection to delivery controller $DeliveryController" -Color Yellow
$connection = Test-Connection -URL $url
if ($connection.Status -eq $true) {
    # Connection OK, enumerate the farm
    Write-Log -Value "Connection delivery controller $DeliveryController successful" -Color Green

    # Retrieve the Machine Catalogs
    Write-Log -Value "Retrieving Machine Catalogs"

    # Create the catalogs table
    $catalogs = New-Table -Columns "Id","Name","LifecycleState","ProvisioningType","PersistentUserChanges","IsMachinePhysical","AllocationType","SessionSupport","ProvisioningSchemeId","CreatedDate","ModifiedDate"
    $odata = Invoke-ODataRequest -URL $url -Table "Catalogs"
    if ($odata.Status -eq $true) {
        # Add all catalogs to the catalogs table
        foreach ($item in $odata.Data.value) {
            Add-TableItem -Item $item -Table ([ref]$catalogs)
        }
    } else {
        # Cannot retrieve machine catalogs
        Write-Log -Value "WARNING: Could not retrieve machine catalogs (return value: $($odata.Message))" -Color Red
    }

    # Retrieve Delivery Groups
    Write-Log -Value "Retrieving Delivery Groups"

    # Create the delivery groups table
    $groups = New-Table -Columns "Id","Name","IsRemotePC","DesktopKind","LifecycleState","SessionSupport","CreatedDate","ModifiedDate"
    $odata = Invoke-ODataRequest -URL $url -Table "DesktopGroups" -ArgumentList @{"filter" = "Id ne guid'00000000-0000-0000-0000-000000000000'"}
    if ($odata.Status -eq $true) {
        # Add all delivery groups to the groups table
        foreach ($item in $odata.Data.value) {
            Add-TableItem -Item $item -Table ([ref]$groups)
        }
    } else {
        # Cannot retrieve desktop groups
        Write-Log -Value "WARNING: Could not retrieve machine catalogs (return value: $($odata.Message))" -Color Red
    }

    # Retrieve Machines
    Write-Log -Value "Retrieving Machines"

    # Create the machines table
    $machines = New-Table -Columns "Id","Sid","Name","DnsName","LifecycleState","IPAddress","HostedMachineId","HostingServerName","HostedMachineName","IsAssigned","IsInMaintenanceMode","IsPendingUpdate","AgentVersion","AssociatedUserFullNames","AssociatedUserNames","AssociatedUserUPNs","CurrentRegistrationState","RegistrationStateChangeDate","LastDeregisteredCode","LastDeregisteredDate","CurrentPowerState","CurrentSessionCount","ControllerDnsName","PoweredOnDate","PowerStateChangeDate","FunctionalLevel","FailureDate","WindowsConnectionSetting","IsPreparing","FaultState","OSType","CurrentLoadIndex","CatalogId","DesktopGroupId","HypervisorId","Hash","MachineRole","CreatedDate","ModifiedDate"
    $odata = Invoke-ODataRequest -URL $url -Table "Machines"
    if ($odata.Status -eq $true) {
        # Add all machines to the machines table
        foreach ($item in $odata.Data.value) {
            Add-TableItem -Item $item -Table ([ref]$machines)
        }
    } else {
        # Cannot retrieve machines
        Write-Log -Value "WARNING: Could not retrieve machine catalogs (return value: $($odata.Message))" -Color Red
    }

    # Retrieve Hypervisors
    Write-Log -Value "Retrieving Hypervisors"

    # Create the hypervisors table
    $hypervisors = New-Table -Columns "Id","Name","LifecycleState","CreatedDate","ModifiedDate"
    $odata = Invoke-ODataRequest -URL $url -Table "Hypervisors"
    if ($odata.Status -eq $true) {
        # Add all hypervisors to the hypervisors table
        foreach ($item in $odata.Data.value) {
            Add-TableItem -Item $item -Table ([ref]$hypervisors)
        }
    } else {
        # Cannot hypervisors machines
        Write-Log -Value "WARNING: Could not retrieve hypervisors (return value: $($odata.Message))" -Color Red
    }

    # Retrieve Applications
    Write-Log -Value "Retrieving Applications"

    # Create the applications table
    $applications = New-Table -Columns "Id","Name","PublishedName","ApplicationType","Enabled","AdminFolder","LifecycleState","CreatedDate","ModifiedDate","DesktopGroups"
    $odata = Invoke-ODataRequest -URL $url -Table "Applications"
    if ($odata.Status -eq $true) {
        # Add all applications to the applications table
        foreach ($item in $odata.Data.value) {
            Add-TableItem -Item $item -Table ([ref]$applications)
        }
    } else {
        # Cannot retrieve applications
        Write-Log -Value "WARNING: Could not retrieve applications (return value: $($odata.Message))" -Color Red
    }

    # Process each application (retrieve assigned desktopgroups)
    $progressid = Get-Random
    Write-Log -Value "Retrieving Application Assignments"
    for ($i = 0; $i -lt $applications.Rows.Count; $i++) {
        Write-Progress -Id $progressid -Activity "Retrieving Application Assignments ($($i + 1) / $($applications.Rows.Count))" -Status "Retrieving assignments for: $($applications.Rows[$i]["Name"])" -PercentComplete ((($i + 1) / $applications.Rows.Count) * 100)
        $odata = Invoke-ODataRequest -URL $url -Table "Applications" -TableFilter "guid'$($applications.Rows[$i]["Id"])'" -SubObject "DesktopGroups"
        if ($odata.Status -eq $true) {
            # Merge the desktop groups seperated by comma
            $appdesktopgroups = ""
            foreach ($item in $odata.Data.value) {
                $appdesktopgroups = ",$($item.Id)"
            }

            # Inject the desktop groups into the row
            if ($appdesktopgroups -ne "") {
                $applications.Rows[$i]["DesktopGroups"] = $appdesktopgroups.Substring(1)
            }
        }
    }

    # Finish progress window
    Write-Progress -Id $progressid -Completed -Activity "Retrieving Application Assignments done"

    # Retrieve Hotfixes
    Write-Log -Value "Retrieving Hotfixes"

    # Create the hotfixes table
    $hotfixes = New-Table -Columns "Id","Name","Article","ArticleName","FileName","FileFormat","Version","ComponentName","ComponentVersion","CreatedDate","ModifiedDate"
    $odata = Invoke-ODataRequest -URL $url -Table "Hotfixes"
    if ($odata.Status -eq $true) {
        # Add all hotfixes to the hotfixes table
        foreach ($item in $odata.Data.value) {
            Add-TableItem -Item $item -Table ([ref]$hotfixes)
        }
    } else {
        # Cannot retrieve hotfixes
        Write-Log -Value "WARNING: Could not retrieve hotfixes (return value: $($odata.Message))" -Color Red
    }

    # Retrieve Hotfixes
    Write-Log -Value "Retrieving Machine Hotfixes"

    # Create the hotfix installation table
    $hotfixlogs = New-Table -Columns "Id","MachineId","HotfixId","ChangeType","CurrentState","CreatedDate","ModifiedDate"
    $odata = Invoke-ODataRequest -URL $url -Table "MachineHotfixLogs"
    if ($odata.Status -eq $true) {
        # Add all hotfixes to the hotfixes table
        foreach ($item in $odata.Data.value) {
            Add-TableItem -Item $item -Table ([ref]$hotfixlogs)
        }
    } else {
        # Cannot retrieve hotfixes
        Write-Log -Value "WARNING: Could not retrieve machine hotfixes (return value: $($odata.Message))" -Color Red
    }

    # Save end time
    $end = (Get-Date)

    ##############################################################################
    # Process data and generate report
    ##############################################################################
    Write-Log -Value "**** Processing data ****" -Color Yellow

    # Create the default report data
    Invoke-ReportInitialization -ReportType $exportextension

    ##############################################################################
    # Basic Information
    ##############################################################################
    Write-Log -Value "Processing Basic Information"

    # Insert the header
    Add-ReportHeader -Name "Farm Information" -ReportType $exportextension -Style $Styles[$formattingextension]["HeaderStyle"]

    Add-ReportHeader -Name "Report Information" -ReportType $exportextension -Style $Styles[$formattingextension]["SubHeaderStyle"]

    # Construct the object to use in the report
    if ($Credential -ne [PSCredential]::Empty -and $Credential -ne $null) {
        $reportuser = $Credential.UserName
    } else {
        $reportuser = "Passthrough"
    }

    $reportobject = New-Object -TypeName PSCustomObject
    $reportobject | Add-Member -MemberType NoteProperty -Name "Delivery Controller" -Value $DeliveryController
    $reportobject | Add-Member -MemberType NoteProperty -Name "Username" -Value $reportuser
    $reportobject | Add-Member -MemberType NoteProperty -Name "Scan started" -Value $start.ToString()
    $reportobject | Add-Member -MemberType NoteProperty -Name "Scan finished" -Value $end.ToString()

    Add-ReportTable -Object $reportobject -ReportType $exportextension

    Add-ReportHeader -Name "Delivery Controllers" -ReportType $exportextension -Style $Styles[$formattingextension]["SubHeaderStyle"]

    # Retrieve the delivery controllers
    Add-ReportTable -Table (Get-AssignedMachines -Table ([ref]$machines) -Filter "(MachineRole = 1 OR MachineRole = 2)") -ReportType $exportextension -ExcludeColumns "IP Address","Registration State","Operating System" -NoRecordsText "No Delivery Controllers found"
    Add-PageBreak -ReportType $exportextension

    ##############################################################################
    # Machine Catalogs
    ##############################################################################
    Write-Log -Value "Processing Machine Catalogs"

    # Insert the header
    Add-ReportHeader -Name "Machine Catalogs" -ReportType $exportextension -Style $Styles[$formattingextension]["HeaderStyle"]

    # Select the machine catalogs that are not deleted and are not stub
    $catalogsreport = New-Table -Columns "Id","Name","Allocation Type","Physical Machines","Provisioning Type","Machine Count","Created","Last Modified"
    $catalogmachines = @{}
    foreach ($item in $catalogs.Select("LifecycleState = 0 OR LifecycleState = 2")) {
        $row = $catalogsreport.NewRow()
        $row["Id"] = $item["Id"]
        $row["Name"] = $item["Name"]
        $row["Allocation Type"] = $AllocationType[[int]$item["AllocationType"]].Name
        $row["Physical Machines"] = $item["IsMachinePhysical"]
        $row["Provisioning Type"] = $ProvisioningType[[int]$item["ProvisioningType"]].Name
        $row["Created"] = $item["CreatedDate"]
        $row["Last Modified"] = $item["ModifiedDate"]

        # Retrieve the machine count in this catalog
        $_machines = Get-AssignedMachines -Table ([ref]$machines) -Filter "CatalogId = '$($item["Id"])'"
        $catalogmachines.Add($item["Id"], $_machines)

        # Save the machine count
        $row["Machine Count"] = $_machines.Rows.Count

        # Save the data
        $catalogsreport.Rows.Add($row)
    }

    # Sort the table
    $catalogsreport = Sort-Table -Table $catalogsreport -SortColumn "Name"

    Add-ReportTable -Table $catalogsreport -ReportType $exportextension -IncludeColumns "Name","Machine Count","Allocation Type","Provisioning Type" -NoRecordsText "No Machine Catalogs found"
    foreach ($row in $catalogsreport.Rows) {
        # Add the header
        Add-ReportHeader -Name $row["Name"] -ReportType $exportextension -Style $Styles[$formattingextension]["SubHeaderStyle"]

        # Add the machine catalog basic info
        Add-ReportTable -Row $row -ReportType $exportextension -ExcludeColumns "Id"

        # Add the list of machines
        Add-ReportHeader -Name "Assigned Machines" -ReportType $exportextension -Style $Styles[$formattingextension]["SubtitleStyle"]
        Add-ReportTable -Table $catalogmachines[$row["Id"]] -ReportType $exportextension -IncludeColumns "Name","Domain","Registration State","Operating System"
    }

    Add-PageBreak -ReportType $exportextension

    ##############################################################################
    # Delivery Groups
    ##############################################################################
    Write-Log -Value "Processing Delivery Groups"

    # Insert the header
    Add-ReportHeader -Name "Delivery Groups" -ReportType $exportextension -Style $Styles[$formattingextension]["HeaderStyle"]

    # Process the applications
    $applicationsreport = New-Table -Columns "Id","Name","Display Name","Application Type","Enabled","Admin Folder","Created","Last Modified","DesktopGroups"
    foreach ($item in $applications.Select("LifecycleState = 0 OR LifecycleState = 2")) {
        $row = $applicationsreport.NewRow()
        $row["Id"] = $item["Id"]
        $row["Name"] = $item["Name"]
        $row["Display Name"] = $item["PublishedName"]
        $row["Application Type"] = $ApplicationType[[int]$item["ApplicationType"]].Name
        $row["Enabled"] = $item["Enabled"]
        $row["Admin Folder"] = $item["AdminFolder"]
        $row["Created"] = $item["CreatedDate"]
        $row["Last Modified"] = $item["ModifiedDate"]
        $row["DesktopGroups"] = $item["DesktopGroups"]

        # Save the data
        $applicationsreport.Rows.Add($row)
    }

    $groupsreport = New-Table -Columns "Id","Name","Remote PC","Desktop Kind","Delivery Type","Session Support","Machine Count","Application Count","Created","Last Modified"
    $groupsmachines = @{}
    $groupsapps = @{}
    foreach ($item in $groups.Select("LifecycleState = 0 OR LifecycleState = 2")) {
        $row = $groupsreport.NewRow()
        $row["Id"] = $item["Id"]
        $row["Name"] = $item["Name"]
        $row["Remote PC"] = $item["IsRemotePC"]
        $row["Desktop Kind"] = $DesktopKind[[int]$item["DesktopKind"]].Name
        $row["Delivery Type"] = $DeliveryType[[int]$item["DeliveryType"]].Name
        $row["Created"] = $item["CreatedDate"]
        $row["Last Modified"] = $item["ModifiedDate"]

        # Retrieve the machine count in this delivery group
        $_machines = Get-AssignedMachines -Table ([ref]$machines) -Filter "DesktopGroupId = '$($item["Id"])'"
        $groupsmachines.Add($item["Id"], $_machines)

        # Retrieve the application count for this delivery group
        $_applications = New-Table -Columns ($applicationsreport.Columns | Select-Object -ExpandProperty ColumnName)
        foreach ($approw in $applicationsreport.Select("DesktopGroups LIKE '%$($item["Id"])%'")) {
            $_applications.Rows.Add($approw.ItemArray) | Out-Null
        }
        $groupsapps.Add($item["Id"], $_applications)

        # Save the machine count
        $row["Machine Count"] = $_machines.Rows.Count
        $row["Application Count"] = $_applications.Rows.Count

        # Save the data
        $groupsreport.Rows.Add($row)
    }

    # Sort the table
    $groupsreport = Sort-Table -Table $groupsreport -SortColumn "Name"

    # Add the delivery group list to the report
    Add-ReportTable -Table $groupsreport -ReportType $exportextension -IncludeColumns "Name","Machine Count","Application Count","Desktop Kind","Delivery Type" -NoRecordsText "No Delivery Groups found"
    foreach ($row in $groupsreport.Rows) {
        # Add the header
        Add-ReportHeader -Name $row["Name"] -ReportType $exportextension -Style $Styles[$formattingextension]["SubHeaderStyle"]

        # Add the machine catalog basic info
        Add-ReportTable -Row $row -ReportType $exportextension -ExcludeColumns "Id"

        # Add the list of machines
        Add-ReportHeader -Name "Assigned Machines" -ReportType $exportextension -Style $Styles[$formattingextension]["SubtitleStyle"]
        Add-ReportTable -Table $groupsmachines[$row["Id"]] -ReportType $exportextension -IncludeColumns "Name","Domain","Registration State","Operating System"

        # Add the list of applications
        Add-ReportHeader -Name "Assigned Applications" -ReportType $exportextension -Style $Styles[$formattingextension]["SubtitleStyle"]
        Add-ReportTable -Table $groupsapps[$row["Id"]] -ReportType $exportextension -IncludeColumns "Name","Display Name","Enabled" -NoRecordsText "No assigned applications found"
    }

    Add-PageBreak -ReportType $exportextension

    ##############################################################################
    # Hypervisors
    ##############################################################################
    Write-Log -Value "Processing Hypervisors"

    # Insert the header
    Add-ReportHeader -Name "Hypervisors" -ReportType $exportextension -Style $Styles[$formattingextension]["HeaderStyle"]

    $hypervisorreport = New-Table -Columns "Id","Name","Machine Count","Created","Last Modified"
    $hypervisormachines = @{}
    foreach ($item in $hypervisors.Select("LifecycleState = 0 OR LifecycleState = 2")) {
        $row = $hypervisorreport.NewRow()
        $row["Id"] = $item["Id"]
        $row["Name"] = $item["Name"]
        $row["Created"] = $item["CreatedDate"]
        $row["Last Modified"] = $item["ModifiedDate"]

        # Retrieve the machine count in this catalog
        $_machines = Get-AssignedMachines -Table ([ref]$machines) -Filter "HypervisorId = '$($item["Id"])'"
        $hypervisormachines.Add($item["Id"], $_machines)

        # Save the machine count
        $row["Machine Count"] = $_machines.Rows.Count

        # Save the data
        $hypervisorreport.Rows.Add($row)
    }

    # Sort the table
    $hypervisorreport = Sort-Table -Table $hypervisorreport -SortColumn "Name"

    Add-ReportTable -Table $hypervisorreport -ReportType $exportextension -ExcludeColumns "Id"  -NoRecordsText "No Hypervisors found"

    foreach ($row in $hypervisorreport.Rows) {
        # Add the header
        Add-ReportHeader -Name $row["Name"] -ReportType $exportextension -Style $Styles[$formattingextension]["SubHeaderStyle"]

        # Add the list of machines
        Add-ReportTable -Table $hypervisormachines[$row["Id"]] -ReportType $exportextension -IncludeColumns "Name","Domain","Registration State","Operating System"
    }

    Add-PageBreak -ReportType $exportextension

    ##############################################################################
    # Machines
    ##############################################################################
    Write-Log -Value "Processing Machines"

    # Create a machine name cache (based on GUID)
    $machinecache = @{}

    # Set the page orientation to landscape
    Set-PageOrientation -ReportType $exportextension -Orientation Landscape

    # Insert the header
    Add-ReportHeader -Name "Machines" -ReportType $exportextension -Style $Styles[$formattingextension]["HeaderStyle"]
    
    $machinesreport = New-Table -Columns "Id","Sid","Name","Domain","DNS Name","IP Address","HostedMachineId","Hosting Server Name","Hosted Machine Name","Assigned","Maintenance Mode Enabled","Pending Update","Agent Version","Associated User Fullnames","Associated Usernames","Associated User UPNs","Registration State","Registration State Last Changed","Last Deregistered Code","Last Deregistered","Current Powerstate","Controller DNS Name","Powered On","Powerstate Last Changed","Functional Level","Last Failure","Windows Connection Setting","Preparing","Fault State","Operating System","Current Load Index","Machine Catalog","Desktop Group","Hypervisor","Machine Role","Created","Last Modified"
    foreach ($item in $machines.Select("LifecycleState = 0 OR LifecycleState = 2")) {
        $row = $machinesreport.NewRow()
        $row["Id"] = $item["Id"]
        $row["Sid"] = $item["Sid"]
        $row["Name"] = $item["Name"].Split("\")[1]
        $row["Domain"] = $item["Name"].Split("\")[0]
        $row["DNS Name"] = $item["DnsName"]
        $row["IP Address"] = $item["IPAddress"]
        $row["HostedMachineId"] = $item["HostedMachineId"]
        $row["Hosting Server Name"] = $item["HostingServerName"]
        $row["Hosted Machine Name"] = $item["HostedMachineName"]
        $row["Assigned"] = $item["IsAssigned"]
        $row["Maintenance Mode Enabled"] = $item["IsInMaintenanceMode"]
        $row["Pending Update"] = $item["IsPendingUpdate"]
        $row["Agent Version"] = $item["AgentVersion"]
        $row["Associated User Fullnames"] = $item["AssociatedUserFullNames"]
        $row["Associated Usernames"] = $item["AssociatedUserNames"]
        $row["Associated User UPNs"] = $item["AssociatedUserUPNs"]
        $row["Registration State"] = $RegistrationState[[int]$item["CurrentRegistrationState"]].Name
        $row["Registration State Last Changed"] = $item["RegistrationStateChangeDate"]
        $row["Last Deregistered Code"] = $item["LastDeregisteredCode"]
        $row["Last Deregistered"] = $item["LastDeregisteredDate"]
        $row["Current Powerstate"] = $item["CurrentPowerState"]
        $row["Controller DNS Name"] = $item["ControllerDnsName"]
        $row["Powered On"] = $item["PoweredOnDate"]
        $row["Powerstate Last Changed"] = $item["PowerStateChangeDate"]
        $row["Functional Level"] = $item["FunctionalLevel"]
        $row["Last Failure"] = $item["FailureDate"]
        $row["Windows Connection Setting"] = $item["WindowsConnectionSetting"]
        $row["Preparing"] = $item["IsPreparing"]
        $row["Fault State"] = $item["FaultState"]
        $row["Operating System"] = $item["OSType"]
        $row["Current Load Index"] = $item["CurrentLoadIndex"]
        $row["Machine Catalog"] = Get-TableItem -Table ([ref]$catalogs) -Field "Id" -Value $item["CatalogId"]
        $row["Desktop Group"] = Get-TableItem -Table ([ref]$groups) -Field "Id" -Value $item["DesktopGroupId"]
        $row["Hypervisor"] = Get-TableItem -Table ([ref]$hypervisors) -Field "Id" -Value $item["HypervisorId"]
        $row["Machine Role"] = $MachineRole[[int]$item["MachineRole"]].Name
        $row["Created"] = $item["CreatedDate"]
        $row["Last Modified"] = $item["ModifiedDate"]

        # Save the data
        $machinesreport.Rows.Add($row)

        # Add the name of the machine to the cache file
        if ($machinecache.Keys -notcontains $item["Id"].ToString()) {
            $machinecache.Add($item["Id"].ToString(), $item["Name"])
        }
    }

    # Add basic information
    $machinecountobject = New-Object -TypeName PSCustomObject
    $machinecountobject | Add-Member -MemberType NoteProperty -Name "Total number of machines" -Value $machinesreport.Rows.Count
    $machinecountobject | Add-Member -MemberType NoteProperty -Name "Number of machines in Registered state" -Value $machinesreport.Select("[Registration State] = 'Registered'").Count
    $machinecountobject | Add-Member -MemberType NoteProperty -Name "Number of machines in Unregistered state" -Value $machinesreport.Select("[Registration State] = 'Unregistered'").Count
    $machinecountobject | Add-Member -MemberType NoteProperty -Name "Number of machines in Unknown state" -Value $machinesreport.Select("[Registration State] = 'Unknown'").Count

    Add-ReportTable -Object $machinecountobject -ReportType $exportextension

    # Sort the table
    $machinesreport = Sort-Table -Table $machinesreport -SortColumn "Name"

    # Add list of machines
    Add-ReportTable -Table $machinesreport -ReportType $exportextension -IncludeColumns "Name","DNS Name","IP Address","Registration State","Machine Catalog","Desktop Group","Agent Version","Operating System"  -NoRecordsText "No Machines found"

    Add-PageBreak -ReportType $exportextension
    
    # Set the page orientation to portrait
    Set-PageOrientation -ReportType $exportextension -Orientation Portrait

    ##############################################################################
    # Applications
    ##############################################################################
    Write-Log -Value "Processing Applications"

    # Insert the header
    Add-ReportHeader -Name "Applications" -ReportType $exportextension -Style $Styles[$formattingextension]["HeaderStyle"]
    
    $applicationsreport = New-Table -Columns "Id","Folder","Browser Name","Display Name","Application Type","Enabled","Date Created","Date Modified","Desktop Groups"
    foreach ($item in $applications.Select("LifecycleState = 0 OR LifecycleState = 2")) {
        $row = $applicationsreport.NewRow()
        $row["Id"] = $item["Id"]
        $row["Browser Name"] = $item["Name"]
        $row["Display Name"] = $item["PublishedName"]
        $row["Application Type"] = $ApplicationType[[int]$item["ApplicationType"]].Name
        $row["Enabled"] = $item["Enabled"]
        $row["Folder"] = $item["AdminFolder"]
        $row["Date Created"] = $item["CreatedDate"]
        $row["Date Modified"] = $item["ModifiedDate"]

        # Construct the list of desktop groups
        $dglist = @()
        if ($item["DesktopGroups"] -ne [System.DBNull]::Value) {
            foreach ($dg in $item["DesktopGroups"].Split(",")) {
                $dglist += Get-TableItem -Table ([ref]$groups) -Field "Id" -Value $dg
            }
        }
        $row["Desktop Groups"] = $dglist -join ","

        # Save the data
        $applicationsreport.Rows.Add($row)
    }

    # Add basic application information
    $applicationcountobject = New-Object -TypeName PSCustomObject
    $applicationcountobject | Add-Member -MemberType NoteProperty -Name "Total number of applications" -Value $applicationsreport.Rows.Count
    $applicationcountobject | Add-Member -MemberType NoteProperty -Name "Number of applications enabled" -Value $applicationsreport.Select("[Enabled] = 'True'").Count
    $applicationcountobject | Add-Member -MemberType NoteProperty -Name "Number of applications disabled" -Value $applicationsreport.Select("[Enabled] = 'False'").Count

    Add-ReportTable -Object $applicationcountobject -ReportType $exportextension

    # Sort the table
    $applicationsreport = Sort-Table -Table $applicationsreport -SortColumn "Folder"
    
    # Add list of applications
    Add-ReportTable -Table $applicationsreport -ReportType $exportextension -IncludeColumns "Folder","Display Name","Enabled" -NoRecordsText "No Applications found"

    # Add each application details
    Add-ReportHeader -Name "Application Details" -ReportType $exportextension -Style $Styles[$formattingextension]["SubHeaderStyle"]
    
    # Sort the applications based on name
    $applicationsreport = Sort-Table -Table $applicationsreport -SortColumn "Display Name"
    foreach ($item in $applicationsreport.Rows) {
        Add-ReportHeader -Name $item["Display Name"] -ReportType $exportextension -Style $Styles[$formattingextension]["SubtitleStyle"]

        Add-ReportTable -Row $item -ReportType $exportextension -ExcludeColumns "Id"
    }

    Add-PageBreak -ReportType $exportextension

    ##############################################################################
    # Hotfixes
    ##############################################################################
    Write-Log -Value "Processing Hotfixes"

    # Insert the header
    Add-ReportHeader -Name "Hotfixes" -ReportType $exportextension -Style $Styles[$formattingextension]["HeaderStyle"]
    
    $hotfixesreport = New-Table -Columns "Id","Name","Article URL","Article Name","File Name","File Format","Version","Component Name","Component Version","Date Created","Date Modified"
    foreach ($item in $hotfixes.Rows) {
        $row = $hotfixesreport.NewRow()
        $row["Id"] = $item["Id"]
        $row["Name"] = $item["Name"]
        $row["Article URL"] = $item["Article"]
        $row["Article Name"] = $item["ArticleName"]
        $row["File Name"] = $item["FileName"]
        $row["File Format"] = $item["FileFormat"]
        $row["Version"] = $item["Version"]
        $row["Component Name"] = $item["ComponentName"]
        $row["Component Version"] = $item["ComponentVersion"]
        $row["Date Created"] = $item["CreatedDate"]
        $row["Date Modified"] = $item["ModifiedDate"]

        # Save the data
        $hotfixesreport.Rows.Add($row)
    }

    if ($hotfixesreport.Rows.Count -gt 0) {
        # Sort the table
        $hotfixesreport = Sort-Table -Table $hotfixesreport -SortColumn "Name"

        # Report each hotfix
        foreach ($item in $hotfixesreport.Rows) {
            Add-ReportHeader -Name $item["Name"] -ReportType $exportextension -Style $Styles[$formattingextension]["SubHeaderStyle"]

            Add-ReportTable -Row $item -ReportType $exportextension -ExcludeColumns "Id"

            # Retrieve all installs / uninstalls for machines
            $hotfixlogsreport = New-Table -Columns "Id","Machine Name","Change Type","Currently Installed","Date Created","Date Modified"
            foreach ($log in $hotfixlogs.Select("HotfixId = '$($item["Id"])'")) {
                # Retrieve the machine name
                if ($machinecache.Keys -contains $log["MachineId"].ToString()) {
                    $machinename = $machinecache[$log["MachineId"].ToString()]
                } else {
                    $machinename = "Unknown"
                }

                # Create the row data
                $row = $hotfixlogsreport.NewRow()
                $row["Id"] = $log["Id"]
                $row["Machine Name"] = $machinename
                $row["Change Type"] = $HotfixChangeType[[int]$log["ChangeType"]].Name
                $row["Currently Installed"] = $log["CurrentState"]
                $row["Date Created"] = $log["CreatedDate"]
                $row["Date Modified"] = $log["ModifiedDate"]

                # Add the row
                $hotfixlogsreport.Rows.Add($row)
            }

            # Report the installations
            Add-ReportHeader -Name "Installed on Machines" -ReportType $exportextension -Style $Styles[$formattingextension]["SubtitleStyle"]
            Add-ReportTable -Table $hotfixlogsreport -ReportType $exportextension -ExcludeColumns "Id"
        }
    } else {
        Add-ReportTable -Table $hotfixesreport -ReportType $exportextension -IncludeColumns "Name","Article URL","Article Name","Version" -NoRecordsText "No Hotfixes found"
    }

    Add-PageBreak -ReportType $exportextension

    ##############################################################################
    # Additional Information
    ##############################################################################
    Write-Log -Value "Writing additional information"

    # Insert the header
    Add-ReportHeader -Name "Appendix" -ReportType $exportextension -Style $Styles[$formattingextension]["HeaderStyle"]
    
    $appendix = @{
        "Allocation Types" = $AllocationType;
        "Application Types" = $ApplicationType;
        "Catalog Types" = $CatalogType;
        "Delivery Types" = $DeliveryType;
        "Desktop Kinds" = $DesktopKind;
        "Machine Roles" = $MachineRole;
        "Persistent User Changes" = $PersistentUserChanges;
        "Provisioning Types" = $ProvisioningType;
        "Registration States" = $RegistrationState
    }

    # Process each appendix
    foreach ($key in $appendix.Keys) {
        $_table = New-Table -Columns "Name","Description"
        foreach ($item in $appendix[$key]) {
            # Process each key in the hashtable
            foreach ($entry in $item.Keys) {
                $row = $_table.NewRow()
                $row["Name"] = $item[$entry].Name
                $row["Description"] = $item[$entry].Description

                $_table.Rows.Add($row)
            }
        }

        Add-ReportHeader -Name $key -ReportType $exportextension -Style $Styles[$formattingextension]["SubHeaderStyle"]

        Add-ReportTable -Table $_table -ReportType $exportextension
    }

    # Finalize the report
    Invoke-ReportFinalize -ReportType $exportextension

    # Save the report
    Write-Log -Value "Saving report to $Path" -Color Green
    Save-Report -Path $Path -ReportType $exportextension    

    # Cleanup
    Write-Log -Value "Cleaning up environment" -Color Yellow

    if ($exportextension -eq "DOCX" -or $exportextension -eq "PDF") {
        # Quit word 
        $WordObject.Quit()
    }

    # Collect garbage
    [System.GC]::Collect()

    Write-Log -Value "**** Farm Enumeration Finished ****" -Color Yellow
} else {
    # Error connecting to the DDC
    Write-Log -Value "Could not connect to delivery controller $DeliveryController" -Color Red
    Write-Log -Value "Connection attempt returned: $($connection.Message)" -Color Red

    # Close the Word object if it's started
    if ($exportextension -eq "DOCX" -or $exportextension -eq "PDF") {
        $WordObject.Quit()
    }
}
}