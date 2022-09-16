function Invoke-DownloadFile {
<#
.SYNOPSIS
	Downloads a file as per URI and check its SHA1 hash embedded in $Path.
	With v0.28.2, now able to handle .msu and .cab files (for MSEdge Updates)
.NOTES
	Private Function
.LINK
	https://github.com/ryan-jan/MSCatalog
#>
	[CmdLetBinding()]
    param (
        [uri] $Uri,
        [string] $Path,
        [switch] $UseBits
    )
    
    try {
		[String]$FileExt = [System.IO.Path]::GetExtension($Path) #extract extension
		
        # Check to see if file is already downloaded and the hash matches, if it does, we do not need to re-download
        if (Test-Path $Path) {
            $Hash = Get-FileHash -Path $Path -Algorithm SHA1
			#now able to handle .msu and .cab files
            if ( (($Path -match "$($Hash.Hash)\.msu$") -and ($FileExt -eq '.msu')) -or (($Path -match "$($Hash.Hash)\.cab$") -and ($FileExt -eq '.cab')) ) {
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
		#now able to handle .msu and .cab files
        if ( (($Path -notmatch "$($Hash.Hash)\.msu$") -and ($FileExt -eq '.msu')) -or (($Path -notmatch "$($Hash.Hash)\.cab$") -and ($FileExt -eq '.cab')) ) {
            throw "The hash of the downloaded file [$Path] does not match the expected value [$($Hash.Hash)]."
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