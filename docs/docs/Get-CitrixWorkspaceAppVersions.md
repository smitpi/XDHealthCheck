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

```
Get-CitrixWorkspaceAppVersions [-AdminServer] <String> [-hours] <Int32> [[-Export] <String>]
 [[-ReportPath] <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Reports on the versions of workspace app your users are using to connect

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixWorkspaceAppVersions
```

## PARAMETERS

### -AdminServer
{{ Fill AdminServer Description }}

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
{{ Fill hours Description }}

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

### -Export
{{ Fill Export Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
{{ Fill ReportPath Description }}

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
