---
external help file: XDHealthCheck-help.xml
Module Name: XDHealthCheck
online version:
schema: 2.0.0
---

# Set-XDHealthReportColors

## SYNOPSIS
Set the color and logo for HTML Reports

## SYNTAX

```
Set-XDHealthReportColors [[-Color1] <String>] [[-Color2] <String>] [[-LogoURL] <String>] [<CommonParameters>]
```

## DESCRIPTION
Set the color and logo for HTML Reports.
It updates the registry keys in HKCU:\Software\XDHealth with the new details and display a test report.

## EXAMPLES

### EXAMPLE 1
```
Set-XDHealthReportColors -Color1 '#d22c26' -Color2 '#2bb74e' -LogoURL 'https://gist.githubusercontent.com/default-monochrome.png'
```

## PARAMETERS

### -Color1
New Background Color # code

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: #061820
Accept pipeline input: False
Accept wildcard characters: False
```

### -Color2
New foreground Color # code

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: #FFD400
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogoURL
URL to the new Logo

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Https://gist.githubusercontent.com/smitpi/ecdaae80dd79ad585e571b1ba16ce272/raw/6d0645968c7ba4553e7ab762c55270ebcc054f04/default-monochrome.png
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
