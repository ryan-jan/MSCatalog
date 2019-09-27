function Get-MSCatalogUpdate {
    [CmdLetBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [String] $Search,

        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [Switch] $AllPages,

        [Parameter(DontShow)]
        [String] $Method = "Get",

        [Parameter(DontShow)]
        [String] $EventArgument,

        [Parameter(DontShow)]
        [String] $EventTarget,

        [Parameter(DontShow)]
        [String] $EventValidation,

        [Parameter(DontShow)]
        [String] $ViewState,

        [Parameter(DontShow)]
        [String] $ViewStateGenerator
    )

    if ($Method -eq "Post") {
        $ReqBody = @{
            "__EVENTARGUMENT" = $EventArgument
            "__EVENTTARGET" = $EventTarget
            "__EVENTVALIDATION" = $EventValidation
            "__VIEWSTATE" = $ViewState
            "__VIEWSTATEGENERATOR" = $ViewStateGenerator
        }
    }
    $UriSearch = [Uri]::EscapeUriString($Search)
    $Params = @{
        Uri = "https://www.catalog.update.microsoft.com/Search.aspx?q=$UriSearch"
        Method = $Method
        Body = $ReqBody
        ContentType = "application/x-www-form-urlencoded"
        UseBasicParsing = $true
    }
    $Results = Invoke-WebRequest @Params

    $HtmlDoc = [HtmlAgilityPack.HtmlDocument]::new()
    $HtmlDoc.LoadHtml($Results.RawContent.ToString())
    $NextPage = $HtmlDoc.GetElementbyId("ctl00_catalogBody_nextPage")
    $EventArgument = $HtmlDoc.GetElementbyId("__EVENTARGUMENT")[0].Attributes["value"].Value
    $EventValidation = $HtmlDoc.GetElementbyId("__EVENTVALIDATION")[0].Attributes["value"].Value
    $ViewState = $HtmlDoc.GetElementbyId("__VIEWSTATE")[0].Attributes["value"].Value
    $ViewStateGenerator = $HtmlDoc.GetElementbyId("__VIEWSTATEGENERATOR")[0].Attributes["value"].Value
    $Table = $HtmlDoc.GetElementbyId("ctl00_catalogBody_updateMatches")
    $Rows = $Table.SelectNodes("tr")

    $Output = foreach ($Row in $Rows[1..($Rows.Count - 1)]) {
        $Cells = $Row.SelectNodes("td")
        [PSCustomObject] @{
            PSTypeName = "MSCatalogUpdate"
            Title = $Cells[1].innerText.Trim()
            Products = $Cells[2].innerText.Trim()
            Classification = $Cells[3].innerText.Trim()
            LastUpdated = (Invoke-ParseDate -DateString $Cells[4].innerText.Trim())
            Version = $Cells[5].innerText.Trim()
            Size = $Cells[6].SelectNodes("span")[0].InnerText
            SizeInBytes = [Int] $Cells[6].SelectNodes("span")[1].InnerText 
            Guid = $Cells[7].SelectNodes("input")[0].Id
        }
    }
    $Output | Sort-Object -Property LastUpdated -Descending

    # If $NextPage is $null then there are more pages to collect.
    if (!$NextPage) {
        if ($AllPages) {
            $NextParams = @{
                Search = $Search
                AllPages = $true
                EventArgument = $EventArgument
                EventTarget = 'ctl00$catalogBody$nextPageLinkText'
                EventValidation = $EventValidation
                ViewState = $ViewState
                ViewStateGenerator = $ViewStateGenerator
                Method = "Post"
            }
            Get-MSCatalogUpdate @NextParams
        }
    }
}
