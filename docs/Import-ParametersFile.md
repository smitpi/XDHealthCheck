---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Import-ParametersFile

## SYNOPSIS
Import the config file and creates the needed variables

## SYNTAX

```
Import-ParametersFile [[-JSONParameterFilePath] <String>] [-RedoCredentials] [<CommonParameters>]
```

## DESCRIPTION
Import the config file and creates the needed variables

## EXAMPLES

### Example 1
```powershell
PS C:\> Import-ParametersFile -JSONParameterFilePath $JSONParameterFilePath
```

## PARAMETERS

### -JSONParameterFilePath
Path to the config file

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

### -RedoCredentials
Deletes the saved credentials, and allow you to recreate them.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
