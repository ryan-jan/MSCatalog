function Save-MSCatalogUpdate {    
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ParameterSetName = "ByObject"
        )]
        [Object] $Update,

        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = "ByGuid"
        )]
        [String] $Guid,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = "ByObject"
        )]
        [Parameter(
            Mandatory = $true,
            Position = 1,
            ParameterSetName = "ByGuid"
        )]
        [String] $Destination,

        [Parameter(
            Mandatory = $false,
            Position = 2,
            ParameterSetName = "ByObject"
        )]
        [Parameter(
            Mandatory = $false,
            Position = 2,
            ParameterSetName = "ByGuid"
        )]
        [String] $Language
    )

    if ($Update) {
        $Guid = $Update.Guid
    }
    
    $Post = @{size = 0; updateID = $Guid; uidInfo = $Guid} | ConvertTo-Json -Compress
    $Body = @{updateIDs = "[$Post]"}

    $Params = @{
        Uri = "https://www.catalog.update.microsoft.com/DownloadDialog.aspx"
        Method = "Post"
        Body = $Body
        ContentType = "application/x-www-form-urlencoded"
        UseBasicParsing = $true
    }
    $DownloadDialog = Invoke-WebRequest @Params
    $Links = $DownloadDialog.Content.Replace("www.download.windowsupdate", "download.windowsupdate")
    $Links = $Links | Select-String -AllMatches -Pattern "(http[s]?\://download\.windowsupdate\.com\/[^\'\""]*)"
    if ($Links.Matches.Count -eq 1) {
        $Link = $Links.Matches[0]
        $Params = @{
            Uri = $Link.Value
            OutFile = (Join-Path -Path $Destination -ChildPath $Link.Value.Split('/')[-1])
        }
        Invoke-WebRequest @Params
    } elseif ($Language) {
        $Link = $Links.Matches.Where({$_.Value -match $Language})[0]
        $Params = @{
            Uri = $Link.Value
            OutFile = (Join-Path -Path $Destination -ChildPath $Link.Value.Split('/')[-1])
        }
        Invoke-WebRequest @Params
    } else {
        Write-Host "Id  FileName`r"
        Write-Host "--  --------"
        foreach ($Link in $Links.Matches) {
            $Id = $Links.Matches.IndexOf($Link)
            $FileName = $Link.Value.Split('/')[-1]
            if ($Id -lt 10) {
                Write-Host " $Id  $FileName`r"
            } else {
                Write-Host "$Id  $FileName`r"
            }
        }
        $Selected = Read-Host "Multiple files exist for this update. Enter the Id of the file to download"
        $Params = @{
            Uri = $Links.Matches[$Selected].Value
            OutFile = (Join-Path -Path $Destination -ChildPath $FileName)
        }
        Invoke-WebRequest @Params
    }
}
