---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version: https://smitpi.github.io/XDHealthCheck/#Get-CitrixWebsiteStatus
schema: 2.0.0
---

# Get-CitrixWebsiteStatus

## SYNOPSIS
Get the status of a website

## SYNTAX

```
Get-CitrixWebsiteStatus [-Websitelist] <Array> [<CommonParameters>]
```

## DESCRIPTION
Get the status of a website

## EXAMPLES

### EXAMPLE 1
```
Get-CitrixWebsiteStatus -Websitelist 'https://store.example.com'
```

## PARAMETERS

### -Websitelist
List of websites to check

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
