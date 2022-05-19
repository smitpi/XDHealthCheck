---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixResourceUtilizationSummary

## SYNOPSIS
Resource Utilization Summary for machines

## SYNTAX

### Set1 (Default)
```
Get-CitrixResourceUtilizationSummary [<CommonParameters>]
```

### Fetch odata
```
Get-CitrixResourceUtilizationSummary -AdminServer <String> -hours <Int32> [-Export <String>]
 [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

### Got odata
```
Get-CitrixResourceUtilizationSummary [-Export <String>] [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Resource Utilization Summary for machines

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixResourceUtilizationSummary -AdminServer $CTXDDC -hours 24 -Export Excel -ReportPath C:\temp
```

## PARAMETERS

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
Limit the report to this time frame

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
Parameter Sets: Fetch odata, Got odata
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
Parameter Sets: Fetch odata, Got odata
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
