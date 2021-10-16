---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Get-RDSLicenseInformation

## SYNOPSIS
Report on RDS Licenses

## SYNTAX

```
Get-RDSLicenseInformation [-LicenseServer] <String> [-RemoteCredentials] <PSCredential> [<CommonParameters>]
```

## DESCRIPTION
Report on RDS Licenses

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-RDSLicenseInformation -LicenseServer $RDSLicenseServer  -RemoteCredentials $CTXAdmin
```

## PARAMETERS

### -LicenseServer
Name of RDS License server

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

### -RemoteCredentials

Credentials if running remote

```yaml
Type: PSCredential
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
