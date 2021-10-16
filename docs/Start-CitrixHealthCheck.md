---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Start-CitrixHealthCheck

## SYNOPSIS
Creates and distributes  a report on citrix farm health.

## SYNTAX

```
Start-CitrixHealthCheck [[-JSONParameterFilePath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates and distributes  a report on citrix farm health.

## EXAMPLES

### Example 1
```powershell
PS C:\> Start-CitrixHealthCheck -JSONParameterFilePath = (Get-Item $profile).DirectoryName + "\Parameters.json"
```

## PARAMETERS

### -JSONParameterFilePath
Path to json config file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
