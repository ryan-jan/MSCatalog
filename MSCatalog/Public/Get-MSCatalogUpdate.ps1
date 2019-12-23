function Get-MSCatalogUpdate {
    <#
        .SYNOPSIS
        Query catalog.update.micrsosoft.com for available updates.

        .DESCRIPTION
        Given that there is currently no public API available for the catalog.update.micrsosoft.com site, this
        command makes HTTP requests to the site and parses the returned HTML for the required data.

        .PARAMETER Search
        Specify a string to search for.

        .PARAMETER Strict
        Force a Search paramater with multiple words to be treated as a single string. 

        .PARAMETER AllPages
        By default this command returns the first page of results from catalog.update.micrsosoft.com, which is
        the latest 25 updates matching the search term. If you specify this switch the command will instead
        return all pages of results. This can result in a significant increase in the number of HTTP requests 
        to the catalog.update.micrsosoft.com endpoint.

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903"

        .EXAMPLE
        Get-MSCatalogUpdate -Search "Cumulative for Windows Server, version 1903" -AllPages
    #>
    
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
        [Switch] $Strict,

        [Parameter(
            Mandatory = $false,
            Position = 2
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

    try {

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
            $Title = $Cells[1].innerText.Trim()
            if ($Strict) {
                if ($Title -like "*$Search*") {
                    [PSCustomObject] @{
                        PSTypeName = "MSCatalogUpdate"
                        Title = $Title
                        Products = $Cells[2].innerText.Trim()
                        Classification = $Cells[3].innerText.Trim()
                        LastUpdated = (Invoke-ParseDate -DateString $Cells[4].innerText.Trim())
                        Version = $Cells[5].innerText.Trim()
                        Size = $Cells[6].SelectNodes("span")[0].InnerText
                        SizeInBytes = [Int] $Cells[6].SelectNodes("span")[1].InnerText 
                        Guid = $Cells[7].SelectNodes("input")[0].Id
                    }
                }
            } else {
                [PSCustomObject] @{
                    PSTypeName = "MSCatalogUpdate"
                    Title = $Title
                    Products = $Cells[2].innerText.Trim()
                    Classification = $Cells[3].innerText.Trim()
                    LastUpdated = (Invoke-ParseDate -DateString $Cells[4].innerText.Trim())
                    Version = $Cells[5].innerText.Trim()
                    Size = $Cells[6].SelectNodes("span")[0].InnerText
                    SizeInBytes = [Int] $Cells[6].SelectNodes("span")[1].InnerText 
                    Guid = $Cells[7].SelectNodes("input")[0].Id
                }
            }
        }
        $Output | Sort-Object -Property LastUpdated -Descending

        # If $NextPage is $null then there are more pages to collect.
        if ($null -eq $NextPage) {
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
    } catch {
        $NoResults = $HtmlDoc.GetElementbyId("ctl00_catalogBody_noResultText")
        if (-not ($null -eq $NoResults)) {
            Write-Warning "$($NoResults.InnerText)'$Search'"
        } else {
            throw $_
        }
    }
}
