function Save-MSCatalogUpdate {
    <#
        .SYNOPSIS
        Download an update file from catalog.update.micrsosoft.com.

        .PARAMETER Update
        Specify the update to be downloaded.
        The update object is retrieved using the Get-MSCatalogUpdate function.

        .PARAMETER Guid
        Specify the Guid for the update to be downloaded.
        The Guid is retrieved using the Get-MSCatalogUpdate function.

        .PARAMETER Destination
        Specify the destination directory to download the update to.

        .PARAMETER Language
        Some updates are available in multiple languages. By default this function will list all available
        files for a specific update and prompt you to select the one to download. If you wish to remove
        this prompt you can specify a language-country code combination e.g. "en-us".

        .EXAMPLE
        $Update = Get-MSCatalogUpdate -Search "KB4515384"
        Save-MSCatalogUpdate -Update $Update -Destination C:\Windows\Temp\

        .EXAMPLE
        Save-MSCatalogUpdate -Guid "5570183b-a0b7-4478-b0af-47a6e65417ca" -Destination C:\Windows\Temp\

        .EXAMPLE
        $Update = Get-MSCatalogUpdate -Search "KB4515384"
        Save-MSCatalogUpdate -Update $Update -Destination C:\Windows\Temp\ -Language "en-us"
    #>
    
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
    
    $Links = Get-UpdateLinks -Guid $Guid
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
