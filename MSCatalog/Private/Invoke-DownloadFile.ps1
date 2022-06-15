function Invoke-DownloadFile {
    [CmdLetBinding()]
    param (
        [uri] $Uri,
        [string] $Path,
        [switch] $UseBits
    )
    
    try {
        # Check to see if file is already downloaded and the hash matches, if it does, we do not need to re-download
        if (Test-Path $Path) {
            $Hash = Get-FileHash -Path $Path -Algorithm SHA1
            if ($Path -match "$($Hash.Hash)\.msu$") {
                return
            }
        }

        Set-TempSecurityProtocol

        if ($UseBits) {
            Start-BitsTransfer -Source $Uri -Destination $Path
        } else {
            $WebClient = [System.Net.WebClient]::new()
            $WebClient.DownloadFile($Uri, $Path)
            $WebClient.Dispose()
        }

        $Hash = Get-FileHash -Path $Path -Algorithm SHA1
        if ($Path -notmatch "$($Hash.Hash)\.msu$") {
            throw "The hash of the downloaded file does not match the expected value."
        }

        Set-TempSecurityProtocol -ResetToDefault
    } catch {
        $Err = $_
        if ($WebClient) {
            $WebClient.Dispose()
        }
        throw $Err
    }
}