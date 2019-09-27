---
external help file: MSCatalog-help.xml
Module Name: MSCatalog
online version:
schema: 2.0.0
---

# Save-MSCatalogUpdate

## SYNOPSIS
Download an update file from catalog.update.micrsosoft.com.

## SYNTAX

### ByObject
```
Save-MSCatalogUpdate [-Update] <Object> [-Destination] <String> [[-Language] <String>] [<CommonParameters>]
```

### ByGuid
```
Save-MSCatalogUpdate [-Guid] <String> [-Destination] <String> [[-Language] <String>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
$Update = Get-MSCatalogUpdate -Search "KB4515384"
```

Save-MSCatalogUpdate -Update $Update -Destination C:\Windows\Temp\

### EXAMPLE 2
```
Save-MSCatalogUpdate -Guid "5570183b-a0b7-4478-b0af-47a6e65417ca" -Destination C:\Windows\Temp\
```

### EXAMPLE 3
```
$Update = Get-MSCatalogUpdate -Search "KB4515384"
```

Save-MSCatalogUpdate -Update $Update -Destination C:\Windows\Temp\ -Language "en-us"

## PARAMETERS

### -Update
Specify the update to be downloaded.
The update object is retrieved using the Get-MSCatalogUpdate function.

```yaml
Type: Object
Parameter Sets: ByObject
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Guid
Specify the Guid for the update to be downloaded.
The Guid is retrieved using the Get-MSCatalogUpdate function.

```yaml
Type: String
Parameter Sets: ByGuid
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Destination
Specify the destination directory to download the update to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Language
Some updates are available in multiple languages.
By default this function will list all available
files for a specific update and prompt you to select the one to download.
If you wish to remove
this prompt you can specify a language-country code combination e.g.
"en-us".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
