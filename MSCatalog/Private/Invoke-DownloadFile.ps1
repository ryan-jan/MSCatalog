function Invoke-DownloadFile {
    [CmdLetBinding()]
    param (
        [uri] $Uri,
        [string] $Path,
        [switch] $UseBits
    )
    
    try {
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