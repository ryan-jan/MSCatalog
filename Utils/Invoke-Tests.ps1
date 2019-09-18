param (
    [Switch] $CodeCov
)

$CodeFiles = (Get-ChildItem "$PSScriptRoot\..\MSCatalog" -Recurse -Include "*.ps1").FullName
$PesterParams = @{
    Script = "$PSScriptRoot\..\Tests"
    CodeCoverage = $CodeFiles
    PassThru = $true
}
$PesterResults = Invoke-Pester @PesterParams

if ($CodeCov) {
    # Analyse results using PSCodeCovIO and send results to codecov.io
    Export-CodeCovIoJson -CodeCoverage $PesterResults.CodeCoverage -RepoRoot $PWD -Path "coverage.json"
    Invoke-WebRequest -Uri 'https://codecov.io/bash' -OutFile "codecov.sh"
    bash codecov.sh -f coverage.json
    $Coverage = (Get-Content .\coverage.json -Raw | ConvertFrom-Json).coverage
    $Hit = @()
    $Missed = @()
    $Coverage.PSObject.Properties.Where({$_.MemberType -eq "NoteProperty"}).ForEach({
        $Lines = $_.Value.Where({$_ -ne $null})
        $Hit += $Lines.Where({$_ -gt 0})
        $Missed += $Lines.Where({$_ -eq 0})
    })
    $CovPercent = [math]::Round((100 - (($Missed.Count / ($Hit.Count + $Missed.Count) )) * 100), 2)
    Write-Host "CodeCoverage: $CovPercent%"
} else {
    # Analyse results straight from Pester and print CodeCoverage percentage.
    $CmdMissed = $PesterResults.CodeCoverage.NumberOfCommandsMissed
    $CmdAnalyzed = $PesterResults.CodeCoverage.NumberOfCommandsAnalyzed
    $CovPercent = [math]::Round((100 - (($CmdMissed / $CmdAnalyzed )) * 100), 2)
    Write-Host "CodeCoverage: $CovPercent%"
}