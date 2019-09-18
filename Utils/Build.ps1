param (
    [Switch] $Test,
    [Switch] $CodeCov,
    [Switch] $Deploy
)

Write-Host "Running on PowerShell $($PSVersionTable.PSEdition) $($PSVersionTable.PSVersion.ToString())"
Import-Module $PSScriptRoot\..\MSCatalog\MSCatalog.psd1

if ($Test) {
    if ($CodeCov) {
        & $PSScriptRoot\Invoke-Tests.ps1 -CodeCov
    } else {
        & $PSScriptRoot\Invoke-Tests.ps1
    }
}

if ($Deploy) {
    & "$PSScriptRoot\Deploy.ps1"
}
