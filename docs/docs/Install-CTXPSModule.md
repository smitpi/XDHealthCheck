---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version: https://smitpi.github.io/XDHealthCheck/#Install-CTXPSModule
schema: 2.0.0
---

# Install-CTXPSModule

## SYNOPSIS
Checks and installs needed modules

## SYNTAX

```
Install-CTXPSModule [[-ModuleList] <String>] [-ForceInstall] [-UpdateModules] [-RemoveAll] [<CommonParameters>]
```

## DESCRIPTION
Checks and installs needed modules

## EXAMPLES

### EXAMPLE 1
```
Install-CTXPSModule -ModuleList 'C:\Temp\modules.json'
```

## PARAMETERS

### -ModuleList
Path to json file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Join-Path -Path ((Get-Module XDHealthCheck).ModuleBase).ToString() -ChildPath Private\modulelist.json)
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceInstall
Force reinstall of modules

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateModules
Check for updates for the modules

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveAll
Remove the modules

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
