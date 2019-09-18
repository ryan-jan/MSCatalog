InModuleScope MSCatalog {
    Describe "Get-MSCatalogUpdate" {
        $TestData = Import-Clixml "$PSScriptRoot\Assets\Get-MSCatalogUpdate.xml"
        Mock Invoke-WebRequest {return $TestData[0]} -ParameterFilter {$Method -eq "Get"}
        Mock Invoke-WebRequest {return $TestData[1]} -ParameterFilter {$Method -eq "Post"}

        $ParamCases = @(
            @{
                "ParamName" = "Search"
                "Type" = "String"
                "Mandatory" = $true
                "DontShow" = $false
            },
            @{
                "ParamName" = "AllPages"
                "Type" = "Switch"
                "Mandatory" = $false
                "DontShow" = $false
            },
            @{
                "ParamName" = "Method"
                "Type" = "String"
                "Mandatory" = $false
                "DontShow" = $true
            },
            @{
                "ParamName" = "EventArgument"
                "Type" = "String"
                "Mandatory" = $false
                "DontShow" = $true
            },
            @{
                "ParamName" = "EventTarget"
                "Type" = "String"
                "Mandatory" = $false
                "DontShow" = $true
            },
            @{
                "ParamName" = "EventValidation"
                "Type" = "String"
                "Mandatory" = $false
                "DontShow" = $true
            },
            @{
                "ParamName" = "ViewState"
                "Type" = "String"
                "Mandatory" = $false
                "DontShow" = $true
            },
            @{
                "ParamName" = "ViewStateGenerator"
                "Type" = "String"
                "Mandatory" = $false
                "DontShow" = $true
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
        It "Parameter <ParamName> should have the 'DontShow' attribute set to '<DontShow>'." -TestCases $ParamCases {
            param (
                [String] $ParamName,
                [String] $Type,
                [Boolean] $Mandatory,
                [Boolean] $DontShow
            )
            $Cmd = Get-Command -Name Get-MSCatalogUpdate
            $Cmd.Parameters.$($ParamName).Attributes.DontShow | Should -Be $DontShow
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
            $Results = Get-MSCatalogUpdate -Search "Office 2013"
            $Results | Should -HaveCount 25
        }
        It "Should contain more than 25 results when running a search with the AllPages parameter." {
            $Results = Get-MSCatalogUpdate -Search "Office 2013" -AllPages
            $Results | Should -HaveCount 27
        }
        It ("Should return an object containing a key named '<KeyName>' of type '<Type>'.") -TestCases $ResultCases {
            param (
                [String] $KeyName,
                [String] $Type
            )
            $Result = (Get-MSCatalogUpdate -Search "Office 2013")[0]
            $Result.$($KeyName) | Should -BeOfType $Type
        }
    }
}