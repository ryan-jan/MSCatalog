InModuleScope MSCatalog {
    Describe "Save-MSCatalogUpdate" {
        # A sample DownloadDialog response containing multiple files to select from
        $RawResMulti = Import-Clixml "$PSScriptRoot\Assets\Save-MSCatalogUpdate\RawResponseMulti.xml"
        # A sample DownloadDialog response containing a single file
        $RawResSingle = Import-Clixml "$PSScriptRoot\Assets\Save-MSCatalogUpdate\RawResponseSingle.xml"
        # A sample object returned from the Get-MSCatalogUpdate command containing a single update object.
        $UpdateSingle = Import-Clixml "$PSScriptRoot\Assets\Save-MSCatalogUpdate\UpdateObjectSingle.xml"
        Mock Write-Host {return $true}
        Mock Read-Host {return $true}
        Mock Invoke-WebRequest {return $RawResMulti}
        Mock Invoke-DownloadFile {return $true}

        $ParamCases = @(
            @{
                "ParamName" = "Update"
                "Type" = "Object"
                "Mandatory" = $true
            },
            @{
                "ParamName" = "Guid"
                "Type" = "String"
                "Mandatory" = $true
            },
            @{
                "ParamName" = "Destination"
                "Type" = "String"
                "Mandatory" = $true
            },
            @{
                "ParamName" = "Language"
                "Type" = "String"
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
            $Cmd = Get-Command -Name Save-MSCatalogUpdate
            $Cmd | Should -HaveParameter $ParamName -Type $Type -Mandatory:$($Mandatory)
        }
        It "Should prompt to select a file to download if there are more than one option." {
            $Test = Save-MSCatalogUpdate -Guid "601956e3-f2f0-469a-a7fe-cad6c0b4f665" -Destination ".\"
            $Test.Count | Should -BeGreaterThan 1
        }
        It "Should not prompt to select a file to download if the Language parameter is specified." {
            $Test = Save-MSCatalogUpdate -Guid "601956e3-f2f0-469a-a7fe-cad6c0b4f665" -Destination ".\" -Language "en-us"
            $Test.Count | Should -HaveCount 1
        }
        It "Should not throw an error when called using the Update parameter to download a single file." {
            Mock Invoke-WebRequest {return $RawResSingle}
            $Test = Save-MSCatalogUpdate -Update $UpdateSingle -Destination ".\"
            $Test.Count | Should -HaveCount 1
        }
    }
}