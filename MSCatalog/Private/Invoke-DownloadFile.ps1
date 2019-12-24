function Invoke-DownloadFile {
    [CmdLetBinding()]
    param (
        [uri] $Uri,
        [string] $Path
    )
    
    try {
        $WebClient = [System.Net.WebClient]::new()
        $WebClient.DownloadFile($Uri, $Path)
        $WebClient.Dispose()
    } catch {
        $Err = $_
        $WebClient.Dispose()
        throw $Err
    }
}