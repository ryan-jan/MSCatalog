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
        Specify the destination directory to download the update to. If left unset, update will be downloaded to the default temporary directory.

        .PARAMETER Language
        Some updates are available in multiple languages. By default this function will list all available
        files for a specific update and prompt you to select the one to download. If you wish to remove
        this prompt you can specify a language-country code combination e.g. "en-us".

        .PARAMETER UseBits
        If using a Windows system you can use this parameter to download the update using BITS.

        .PARAMETER AcceptMultiFileUpdates
        If specified, updates containing multiple files will not prompt the user to select which
        file to download. Instead all files will be downloaded.

        .EXAMPLE
        $Update = Get-MSCatalogUpdate -Search "KB4515384"
        Save-MSCatalogUpdate -Update $Update -Destination C:\Windows\Temp\

        .EXAMPLE
        Save-MSCatalogUpdate -Guid "5570183b-a0b7-4478-b0af-47a6e65417ca" -Destination C:\Windows\Temp\

        .EXAMPLE
        $Update = Get-MSCatalogUpdate -Search "KB4515384"
        Save-MSCatalogUpdate -Update $Update -Destination C:\Windows\Temp\ -Language "en-us"

        .EXAMPLE
        $Update = Get-MSCatalogUpdate -Search "KB4515384"
        Save-MSCatalogUpdate -Update $Update -Destination C:\Windows\Temp\ -UseBits
    #>
    
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = "ByObject"
        )]
        [Object] $Update,

        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = "Guid",
            ParameterSetName = "ByGuid"
        )]
        [String] $Guid,

        [Parameter(
            Mandatory = $false,
            Position = 1,
            ParameterSetName = "ByObject"
        )]
        [Parameter(
            Mandatory = $false,
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
        [String] $Language,

        [Parameter(
            Mandatory = $false,
            Position = 3,
            ParameterSetName = "ByObject"
        )]
        [Parameter(
            Mandatory = $false,
            Position = 3,
            ParameterSetName = "ByGuid"
        )]
        [Switch] $UseBits,

        [Parameter(Mandatory = $false)]
        [switch] $AcceptMultiFileUpdates
    )

    if ($null -eq $Destination) {
        $Destination = $env:TEMP
    }

    if ($Update) {
        $Guid = $Update.Guid
    }
    
    $Links = Get-UpdateLinks -Guid $Guid
    if ($Links.Matches.Count -eq 1) {
        $Link = $Links.Matches[0]
        $OutFile = Join-Path -Path (Get-Item -Path $Destination) -ChildPath $Link.Value.Split('/')[-1]
        Invoke-DownloadFile -Uri $Link.Value -Path $OutFile -UseBits:$UseBits
    } elseif ($Language) {
        $Link = $Links.Matches.Where({$_.Value -match $Language})[0]
        $OutFile = Join-Path -Path (Get-Item -Path $Destination) -ChildPath $Link.Value.Split('/')[-1]
        Invoke-DownloadFile -Uri $Link.Value -Path $OutFile -UseBits:$UseBits
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
        if ($AcceptMultiFileUpdates) {
            $SelectedId = "A"
        } else {
            $SelectedId = Read-Host "Multiple files exist for this update. Enter the Id of the file to download or 'A' to download all files."
        }
        $ToDownload = @()
        if ($SelectedId -like "A") {
            foreach ($Link in $Links.Matches) {
                $ToDownload += $Link.Value
            }
        } else {
            $ToDownload += $Links.Matches[$SelectedId].Value
        }

        foreach ($Item in $ToDownload) {
            $OutFile = Join-Path -Path (Get-Item -Path $Destination) -ChildPath $Item.Split('/')[-1]
            Invoke-DownloadFile -Uri $Item -Path $OutFile -UseBits:$UseBits
        }
    }
}
