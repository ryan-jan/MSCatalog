param (
    [Switch] $Test,
    [Switch] $CodeCov,
    [Switch] $Deploy
)

Import-Module $PSScriptRoot\..\src\MSCatalog.psd1
Import-Module platyPS
Import-Module Pester
Write-Host "Running on PowerShell $($PSVersionTable.PSEdition) $($PSVersionTable.PSVersion.ToString())"

if ($Test -and $CodeCov) {
    & $PSScriptRoot\Invoke-Tests.ps1 -CodeCov
} elseif ($Test) {
    & $PSScriptRoot\Invoke-Tests.ps1
}

if ($Deploy) {
    & $PSScriptRoot\Deploy.ps1
}
