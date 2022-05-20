---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixConnectionFailures

## SYNOPSIS
Creates a report from monitoring data about machine and connection failures

## SYNTAX

### Fetch odata (Default)
```
Get-CitrixConnectionFailures -AdminServer <String> -SessionCount <Int32> [-Export <String>]
 [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

### Got odata
```
Get-CitrixConnectionFailures [-MonitorData <Object>] [-Export <String>] [-ReportPath <DirectoryInfo>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a report from monitoring data about machine and connection failures

## EXAMPLES

### EXAMPLE 1
```
$monitor = Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount 50
```

Get-CitrixConnectionFailures -MonitorData $monitor

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

### -SessionCount
Will collect data for the last x amount of sessions.

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
