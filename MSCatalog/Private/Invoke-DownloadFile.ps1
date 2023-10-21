function Invoke-DownloadFile {
    [CmdLetBinding()]
    param (
        [uri] $Uri,
        [string] $Path,
        [switch] $UseBits
    )
    
    try {
        # Check to see if file is already downloaded and the signature is valid, if it is, we do not need to re-download
        if (Test-Path $Path) {
            $Signature = (Get-AuthenticodeSignature $Path).Status
            if ($Signature -eq "Valid") {
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

        $Signature = (Get-AuthenticodeSignature $Path).Status
        if ($Signature -ne "Valid") {
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