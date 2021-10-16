---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-CitrixWebsiteStatus

## SYNOPSIS
Report on Website Status

## SYNTAX

```
Get-CitrixWebsiteStatus [-Websitelist] <Array> [<CommonParameters>]
```

## DESCRIPTION
Report on Website Status

## EXAMPLES

### Example 1
```powershell
PS C:\>  Get-CitrixWebsiteStatus -Websitelist 'https://store.example.com'
```

## PARAMETERS

### -Websitelist

List of URLs

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Array

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
