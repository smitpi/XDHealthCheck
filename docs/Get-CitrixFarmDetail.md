---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixFarmDetail

## SYNOPSIS
Get needed Farm details.

## SYNTAX

```
Get-CitrixFarmDetail [-AdminServer] <String> [-RunAsPSRemote] [[-RemoteCredentials] <PSCredential>]
 [<CommonParameters>]
```

## DESCRIPTION
Get needed Farm details.

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixFarmDetail -AdminServer $CTXDDC -RemoteCredentials $CTXAdmin -RunAsPSRemote
```

## PARAMETERS

### -AdminServer
Name of a data collector

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

### -RunAsPSRemote
Credentials if running psremote

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoteCredentials
Enable function to run remotely, if the CItrix cmdlets are not available

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
