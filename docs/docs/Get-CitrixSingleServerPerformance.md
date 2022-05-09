---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixSingleServerPerformance

## SYNOPSIS
Get perfmon statistics

## SYNTAX

```
Get-CitrixSingleServerPerformance [-Server] <String> [-RemoteCredentials] <PSCredential> [<CommonParameters>]
```

## DESCRIPTION
Get perfmon statistics

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixSingleServerPerformance -Server ddc01 -RemoteCredentials $CTXAdmin
```

## PARAMETERS

### -Server
Server to get the permon details

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
