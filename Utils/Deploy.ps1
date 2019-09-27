Start-Sleep -Seconds 5
$CurModuleVersion = (Import-PowerShellDataFile ".\src\MSCatalog.psd1").ModuleVersion
$PrevCommit = (git log --pretty=tformat:"%H")[1]
git checkout -b buildtemp $PrevCommit --quiet
$PrevModuleVersion = (Import-PowerShellDataFile ".\src\MSCatalog.psd1").ModuleVersion
git checkout master --quiet
git branch -D buildtemp --quiet

if ($CurModuleVersion -gt $PrevModuleVersion) {
    Write-Output ("Module version increased from $PrevModuleVersion to $CurModuleVersion.`n" +
                  "Publishing new version to PSGallery.")
    New-Item -ItemType "Directory" -Path ".\out"
    Copy-Item -Path ".\src\" -Destination ".\out\MSCatalog\" -Recurse
    New-ExternalHelp -Path ".\docs\" -OutputPath ".\out\MSCatalog\en-US\"
    Publish-Module -Path ".\out\MSCatalog" -NuGetApiKey $env:PSGALLERY_KEY
}