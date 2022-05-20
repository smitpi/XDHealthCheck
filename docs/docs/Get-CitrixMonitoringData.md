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
Get-CitrixMonitoringData [-AdminServer] <String> [-SessionCount] <Int32> [-AllowUnencryptedAuthentication]
 [<CommonParameters>]
```

## DESCRIPTION
Connects and collects data from the monitoring OData feed.

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixMonitoringData -AdminServer $AdminServer -SessionCount 50
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

### -SessionCount
Will collect data for the last x amount of sessions.

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

### -AllowUnencryptedAuthentication
{{ Fill AllowUnencryptedAuthentication Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
