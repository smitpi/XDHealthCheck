---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Install-BasePSModules

## SYNOPSIS
Makes sure the needed modules are available.

## SYNTAX

```
Install-BasePSModules [[-ModuleList] <String>] [-ForceInstall] [-UpdateModules] [-RemoveAll]
 [<CommonParameters>]
```

## DESCRIPTION
Makes sure the needed modules are available.

## EXAMPLES

### Example 1
```powershell
PS C:\> Install-BasePSModules -ModuleList 'c:\temp\\modulelist.json'
```

## PARAMETERS

### -ForceInstall
Force Install / Reinstall of the modules

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleList
Path to json file with the needed module list.

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

### -RemoveAll
Force remove the modules in the list.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateModules
Run an module update

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
