---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixServerEventLog

## SYNOPSIS
Get windows event log details

## SYNTAX

```
Get-CitrixServerEventLog [-Serverlist] <Array> [-Days] <Int32> [-RemoteCredentials] <PSCredential>
 [<CommonParameters>]
```

## DESCRIPTION
Get windows event log details

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixServerEventLog -Serverlist $CTXCore -Days 1 -RemoteCredentials $CTXAdmin
```

## PARAMETERS

### -Days
Limit the search for only do many days.

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

### -RemoteCredentials
Credentials used to connect to server remotely.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Serverlist
List of server names.

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
