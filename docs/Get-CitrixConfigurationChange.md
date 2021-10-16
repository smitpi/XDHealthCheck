---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixConfigurationChange

## SYNOPSIS

Show the changes that was made to the farm

## SYNTAX

```
Get-CitrixConfigurationChange [-DDC] <String> [-Indays] <Int32> [<CommonParameters>]
```

## DESCRIPTION
Show the changes that was made to the farm

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-CitrixConfigurationChange -DDC $CTXDDC -Indays 7 -RemoteCredentials $CTXAdmin
```

{{ Add example description here }}

## PARAMETERS

### -DDC
Name of data collector

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Indays
Limit the search, to only show changes from the last couple of days

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS