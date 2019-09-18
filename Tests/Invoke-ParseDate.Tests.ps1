InModuleScope MSCatalog {
    Describe "Invoke-ParseDate" {
        It "Should return an object of type DateTime from an American date string." {
            $Date = Invoke-ParseDate -DateString "09/20/2019"
            $Date | Should -BeOfType "DateTime"
        }
    }
}