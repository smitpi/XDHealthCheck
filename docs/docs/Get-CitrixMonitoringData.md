---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixMonitoringData

## SYNOPSIS
Connects and collects data from the monitoring OData feed.

## SYNTAX

```
Get-CitrixMonitoringData [-AdminServer] <String> [-hours] <Int32> [<CommonParameters>]
```

## DESCRIPTION
Connects and collects data from the monitoring OData feed.

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixMonitoringData -AdminServer $AdminServer -hours $hours
```

## PARAMETERS

### -AdminServer
FQDN of the Citrix Data Collector

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -hours
Limit the report to this time frame

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: 0
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
