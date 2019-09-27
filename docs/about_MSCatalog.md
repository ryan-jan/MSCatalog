# MSCatalog
## about_MSCatalog

# SHORT DESCRIPTION

MSCatalog is a PowerShell module which can search and download update files from
the catalog.update.microsoft.com website.

# LONG DESCRIPTION

There is not currently a public API for retrieving update files from the
catalog.update.microsoft.com website. This PowerShell module seeks to enable
administrators to automate this process by instead parsing the raw HTML returned
by standard HTTP requests.

## HtmlAgilityPack

In order to stay cross-platform, MSCatalog uses the HtmlAgilityPack
HTML parser library. This is instead of relying on the common IE based `ParsedHtml`
property of the `Invoke-WebRequest` CmdLet, which would only work on Windows based systems,
and even then would not work in certain scenarios e.g. when run in the context of the `SYSTEM` user.
