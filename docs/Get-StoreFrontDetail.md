---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-StoreFrontDetail

## SYNOPSIS
Report on StoreFront Status

## SYNTAX

```
Get-StoreFrontDetail [-StoreFrontServer] <String> [-RemoteCredentials] <PSCredential> [-RunAsPSRemote]
 [<CommonParameters>]
```

## DESCRIPTION
Report on StoreFront Status

## EXAMPLES

### Example 1
```
PS C:\> Get-StoreFrontDetail -StoreFrontServer $CTXStoreFront -RemoteCredentials $CTXAdmin -RunAsPSRemote
```

## PARAMETERS

### -RemoteCredentials
Credentials if running remote

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

### -RunAsPSRemote
Enable function to run remotely, if the CItrix cmdlets are not available

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -StoreFrontServer
Name of one of the StoreFront servers in the farm

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
