---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixServerPerformance

## SYNOPSIS
Collects perform data for the core servers.

## SYNTAX

```
Get-CitrixServerPerformance [-ComputerName] <String[]> [-Export <String>] [-ReportPath <DirectoryInfo>]
 [<CommonParameters>]
```

## DESCRIPTION
Collects perform data for the core servers.

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixServerPerformance -ComputerName $CTXCore
```

## PARAMETERS

### -ComputerName
List of Computers to query.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Export
Export the result to a report file.
(Excel, html or Screen)

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

## NOTES

## RELATED LINKS
