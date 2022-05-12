---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixWorkspaceAppVersions

## SYNOPSIS
Reports on the versions of workspace app your users are using to connect

## SYNTAX

### Got odata
```
Get-CitrixWorkspaceAppVersions [-MonitorData <Object>] [-Export <String>] [-ReportPath <DirectoryInfo>]
 [<CommonParameters>]
```

### Fetch odata
```
Get-CitrixWorkspaceAppVersions -AdminServer <String> -hours <Int32> [-Export <String>]
 [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Reports on the versions of workspace app your users are using to connect

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixWorkspaceAppVersions
```

### EXAMPLE 2
```
$mon = Get-CitrixMonitoringData -AdminServer $AdminServer -hours $hours
```

Get-CitrixWorkspaceAppVersions -MonitorData $Mon

## PARAMETERS

### -MonitorData
Use Get-CitrixMonitoringData to create OData, and use that variable in this parameter.

```yaml
Type: Object
Parameter Sets: Got odata
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdminServer
FQDN of the Citrix Data Collector

```yaml
Type: String
Parameter Sets: Fetch odata
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -hours
Limit the report to this time fame

```yaml
Type: Int32
Parameter Sets: Fetch odata
Aliases:

Required: True
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Export the result to a report file.
(Excel or html)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Where to save the report.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
