---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-RDSLicenseInformation

## SYNOPSIS
Report on RDS License Useage

## SYNTAX

```
Get-RDSLicenseInformation [-LicenseServer] <String> [<CommonParameters>]
```

## DESCRIPTION
Report on RDS License Useage

## EXAMPLES

### EXAMPLE 1
```
Get-RDSLicenseInformation -LicenseServer $RDSLicenseServer  -RemoteCredentials $CTXAdmin
```

## PARAMETERS

### -LicenseServer
Name of a RDS License Server

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
