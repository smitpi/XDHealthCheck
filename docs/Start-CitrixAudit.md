---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Start-CitrixAudit

## SYNOPSIS
Creates and distributes  a report on catalog, groups and published app config.

## SYNTAX

```
Start-CitrixAudit [[-JSONParameterFilePath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates and distributes  a report on catalog, groups and published app config.

HTML Reports
- When creating a HTML report:
- The logo can be changed by replacing the variable 
	- $Global:Logourl =''
- The colors of the report can be changed, by replacing:
	- $global:colour1 = '#061820'
	- $global:colour2 = '#FFD400'
- Or permanently replace it by editing the following file
- \<Module base\>\Private\Reports-Variables.ps1

## EXAMPLES

### EXAMPLE 1
```
Start-CitrixAudit -JSONParameterFilePath 'C:\temp\Parameters.json'
```

## PARAMETERS

### -JSONParameterFilePath
Path to the json config file, created by Install-ParametersFile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-Item $profile).DirectoryName + "\Parameters.json"
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
