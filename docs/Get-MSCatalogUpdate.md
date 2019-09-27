---
external help file: MSCatalog-help.xml
Module Name: MSCatalog
online version:
schema: 2.0.0
---

# Get-MSCatalogUpdate

## SYNOPSIS
Search the catalog and return available updates.

## SYNTAX

```
Get-MSCatalogUpdate [-Search] <String> [-AllPages] [-Method <String>] [-EventArgument <String>]
 [-EventTarget <String>] [-EventValidation <String>] [-ViewState <String>] [-ViewStateGenerator <String>]
 [<CommonParameters>]
```

## DESCRIPTION
The **Get-MSCatalogUpdate** command returns one or more *pages* of available updates from the Microsoft
Update Catalog based on the provided search string. By default the command returns the first *page*
of results, with a *page* being a maximum of 25 updates, depending on the specified search string.

## EXAMPLES

### EXAMPLE 1
```
Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903"
```

### EXAMPLE 2
```
Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -AllPages
```

## PARAMETERS

### -Search
Specify a string to search for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllPages
This switch will return all available *pages* of updates matching the specified search string.
This can result in a significant increase in the number of HTTP requests to the
catalog.update.micrsosoft.com site.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
