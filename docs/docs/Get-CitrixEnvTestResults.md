---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixEnvTestResults

## SYNOPSIS
Perform and report on tests on catalogs, delivery groups, hypervisor and Infrastructure

## SYNTAX

```
Get-CitrixEnvTestResults [-AdminServer] <String> [-Catalogs] [-DesktopGroups] [-Hypervisor] [-Infrastructure]
 [-Export <String>] [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Perform and report on tests on catalogs, delivery groups, hypervisor and Infrastructure

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixEnvTestResults -AdminServer vulcan.internal.lab -Catalogs -DesktopGroups -Hypervisor -Infrastructure -Export HTML -ReportPath C:\temp -Verbose
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

### -Catalogs
Report on Catalogs

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

### -DesktopGroups
Report on Desktop Groups

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

### -Hypervisor
Report on  hypervisor

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

### -Infrastructure
Report Infrastructure

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
