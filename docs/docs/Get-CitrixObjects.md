---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixObjects

## SYNOPSIS
Get details of citrix objects

## SYNTAX

```
Get-CitrixObjects [-AdminServer] <String> [<CommonParameters>]
```

## DESCRIPTION
Get details of citrix objects.
(Catalog, Delivery group and published apps)

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixObjects -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
