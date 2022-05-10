---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixVDAUptime

## SYNOPSIS
Calculate the uptime of VDA Servers.

## SYNTAX

```
Get-CitrixVDAUptime [-AdminServer] <String> [-Export <String>] [-ReportPath <DirectoryInfo>]
 [<CommonParameters>]
```

## DESCRIPTION
Calculate the uptime of VDA Servers.
The script will filter out desktop machines and only report on severs. 
If the script cant remotely connect to the vda server, then the last registration date will be used.

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixVDAUptime -AdminServer $CTXDDC
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
