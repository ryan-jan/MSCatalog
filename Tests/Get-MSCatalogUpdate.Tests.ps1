InModuleScope MSCatalog {
    Describe "Get-MSCatalogUpdate" {
        # A sample Search response with more pages available in the pagination.
        #$RawResMore = Import-Clixml "$PSScriptRoot\Assets\Get-MSCatalogUpdate\RawResponseMorePages.xml"
        # A sample Search response conatining the last page available in the pagination.
        #$RawResLast = Import-Clixml "$PSScriptRoot\Assets\Get-MSCatalogUpdate\RawResponseLastPage.xml"
        #Mock Invoke-WebRequest {return $RawResMore} -ParameterFilter {$Method -eq "Get"}
        #Mock Invoke-WebRequest {return $RawResLast} -ParameterFilter {$Method -eq "Post"}

        $ParamCases = @(
            @{
                "ParamName" = "Search"
                "Type" = "String"
                "Mandatory" = $true
            },
            @{
                "ParamName" = "SortBy"
                "Type" = "String"
                "Mandatory" = $false
            },
            @{
                "ParamName" = "Descending"
                "Type" = "Switch"
                "Mandatory" = $false
            },
            @{
                "ParamName" = "Strict"
                "Type" = "Switch"
                "Mandatory" = $false
            },
            @{
                "ParamName" = "AllPages"
                "Type" = "Switch"
                "Mandatory" = $false
            }
        )
        It "Should allow the '<ParamName>' paramater." -TestCases $ParamCases {
            param (
                [String] $ParamName,
                [String] $Type,
                [Boolean] $Mandatory,
                [Boolean] $DontShow
            )
            $Cmd = Get-Command -Name Get-MSCatalogUpdate
            $Cmd | Should -HaveParameter $ParamName -Type $Type -Mandatory:$($Mandatory)
        }

        $ResultCases = @(
            @{"KeyName" = "Title"; "Type" = "String"},
            @{"KeyName" = "Products"; "Type" = "String"},
            @{"KeyName" = "Classification"; "Type" = "String"},
            @{"KeyName" = "LastUpdated"; "Type" = "DateTime"},
            @{"KeyName" = "Version"; "Type" = "String"},
            @{"KeyName" = "Size"; "Type" = "String"},
            @{"KeyName" = "SizeInBytes"; "Type" = "Int"},
            @{"KeyName" = "Guid"; "Type" = "String"}
        )

        It "Should contain 25 or fewer results when running a search without the AllPages parameter." {
            $RawResMore = Import-Clixml "$PSScriptRoot\Assets\Get-MSCatalogUpdate\RawResponseMorePages.xml"
            $HtmlDoc = [HtmlAgilityPack.HtmlDocument]::new()
            $HtmlDoc.LoadHtml($RawResMore.RawContent.ToString())
            $Response = [MSCatalogResponse]::new($HtmlDoc)
            Mock Invoke-CatalogRequest {return $Response}
            $Results = Get-MSCatalogUpdate -Search "Office 2013"
            $Results | Should -HaveCount 25
        }
    }
}