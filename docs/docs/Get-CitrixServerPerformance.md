---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixServerPerformance

## SYNOPSIS
Combine perfmon of multiple servers for reporting.

## SYNTAX

```
Get-CitrixServerPerformance [-Serverlist] <Array> [-RemoteCredentials] <PSCredential> [<CommonParameters>]
```

## DESCRIPTION
Combine perfmon of multiple servers for reporting.

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixServerPerformance -Serverlist $CTXCore -RemoteCredentials $CTXAdmin
```

## PARAMETERS

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

### -Serverlist
List of servers to get the permon details

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
