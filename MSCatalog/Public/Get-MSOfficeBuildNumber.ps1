function Get-MSOfficeBuildNumber {
    <#
        .SYNOPSIS
        Query https://docs.microsoft.com/en-us/officeupdates/update-history-microsoft365-apps-by-date for *Valid* Office 365 build numbers

        .DESCRIPTION
        Given that there is currently no public API available for optaining the Office 365 build numbers, this
		command makes HTTP requests to the site and parses the returned HTML for the required data.
		
		NOTE: Unlike the Get-MSCatalogUpdate function, this function is currently limited to return ONE BuildNumber or none at all.

        .PARAMETER PTYear
        Patch Tuesday year - Defaults to current year

        .PARAMETER PTMonthDay
        Patch Tuesday Month and Day (the second Tuesday of each month)

        .PARAMETER ExcludePreview
        Exclude preview updates from the search results.
		
		.PARAMETER UpdateChannel
        Must be "Current Channel", "Monthly Enterprise Channel", "Semi-Annual Enterprise Channel (Preview)"
		This should match your current Channel of your Office products (Unless you are changing channels...)
		

		.EXAMPLE
		Get-MSOfficeBuildNumber -PTMonthDay 'July 12' -UpdateChannel "Monthly Enterprise Channel"
		#Once a *VALID* Office 365 build number is obtained, OfficeC2RClient.exe can be used to force the existing Office 365 installation to a specified BuildNumber.
	    $arguments = "/update user displaylevel=False forceappshutdown=True updatetoversion=$M365UpdateFullBuildNumber"
	    Start-Process -FilePath "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" $arguments -Wait

		CAVEAT: For this to work, CDNBaseUrl and UpdateChannel must be set in the registry before you run OfficeC2RClient.exe
		[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\ClickToRun\Configuration]
		"CDNBaseUrl"="http://officecdn.microsoft.com/pr/ABCDEF00-0000-0000-0000-CHANGE00ME00"
		"UpdateChannel"="http://officecdn.microsoft.com/pr/ABCDEF00-0000-0000-0000-CHANGE00ME00"


		.NOTES
		This is the initial version of Get-MSOfficeBuildNumber.
		It can only return ONE Build number (not a whole array) due to *MY* lack of skills with HtmlAgilityPack + HTML.
		Any help/updates is greatly encouraged/appreciated.
		
		CAVEAT: If MS changes the structure of the web page, This script and/or PS modules might have to be updated.
		Based on Original concept from Mark Garcia, Toronto, Canada
		
		.LINK
		https://github.com/ryan-jan/MSCatalog
    #>
    
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory = $false)]
		[string]$PTYear = $(Get-Date -Format yyyy),
		
		[Parameter(Mandatory = $true)] #Release Date
		[string]$PTMonthDay = $(Get-Date -Format 'MMMM dd'),
		
		[Parameter(Mandatory = $false)]
        [ValidateSet("Current Channel", "Monthly Enterprise Channel", "Semi-Annual Enterprise Channel (Preview)")]
        [string]$UpdateChannel = "Monthly Enterprise Channel"
    )

    try {
#[String]$MSCatalogPsmPath = "$scriptDirectory\mscatalog.0.28.2\MSCatalog.psm1"
#[String]$MSCatalogPsmPath = "C:\Admutils\ScriptDevSandbox\mscatalog.0.28.2\MSCatalog.psm1"
#Import-Module -Name $MSCatalogPsmPath #dev only!!!
#."C:\Admutils\ScriptDevSandbox\MSCatalog.0.28.2\Private\Invoke-CatalogRequest.ps1"
#."C:\Admutils\ScriptDevSandbox\MSCatalog.0.28.2\Private\Set-TempSecurityProtocol.ps1"
#."C:\Admutils\ScriptDevSandbox\MSCatalog.0.28.2\Private\Invoke-ParseDate.ps1"
#."C:\Admutils\ScriptDevSandbox\MSCatalog.0.28.2\Private\Sort-CatalogResults.ps1"
#."C:\Admutils\ScriptDevSandbox\MSCatalog.0.28.2\Private\Get-UpdateLinks.ps1"


#		$ProgPref = $ProgressPreference
#       $ProgressPreference = "SilentlyContinue"

		# Query M365 Update History site to get M365 build numbers
		$Uri = "https://docs.microsoft.com/en-us/officeupdates/update-history-microsoft365-apps-by-date"
        #$Res = Invoke-CatalogRequest -Uri $Uri	#Fails with "Unable to find type [MSCatalogResponse]" so we have to do it differently

		try {
		    $HtmlDoc = [HtmlAgilityPack.HtmlDocument]::new()
			$Web = [HtmlAgilityPack.HtmlWeb]::new()
			$doc = $Web.Load($Uri) #Scrape the web page
			
			$HTMLTableTRList = $doc.DocumentNode.SelectNodes("//table") ##Select ALL tables on the page

			#Select the second table (index 1) - aka History Table. Extract the Text only
			#Note: Each Cell becomes a row in the table 
			$M365RawTableData = $HTMLTableTRList[1] | Select-Object -ExpandProperty InnerText
			#$M365RawTableData | Set-Content c:\Temp\O365UpdatesInnerText.txt -Force #For DEV. Export the table we captured
		} catch {
		    throw $_
		}

		[Array]$M365QualityUpdateInfo = @()
		#Loop through each line of the Version History table on the page (as text in $M365RawTableArray)
		[Array]$M365RawTableArray = $M365RawTableData.split("`r`n")
		for ($index = 0; $index -lt $M365RawTableArray.count; $index++) {
			$entry = $M365RawTableArray[$index]
			if($entry -eq "2021") {
				break #out of foreach loop, we went too far
			}
			
			#in the Original version we could detect "2022July 12" all in one line, but MS changed IE or the web page.
			#With the HTMLAgilityPack, we need to detect "2022<New line>July 12" but we can only compare ONE line at a time so...
		    if($entry -ne "") {
				#If the current row matches the $PTYear and the next row(s) matches $PTMonthDay
		        if(($entry -like "$PTYear*") -and ($M365RawTableArray[$index+1] -like "$PTMonthDay*")) {
				    $M365RawTableArray[$index+1] | Out-File "$env:systemdrive\Temp\Logs\M365AppsUpdate_InstallTS.log" -Append -Encoding UTF8     
					#grab current row and the next four
		            $M365QualityUpdateInfo += $entry						#Year
					$M365QualityUpdateInfo += $M365RawTableArray[$index+1]	#Release Date [MonthDay]
					$M365QualityUpdateInfo += $M365RawTableArray[$index+2]	#Current Channel
					$M365QualityUpdateInfo += $M365RawTableArray[$index+3]	#Monthly Enterprise Channel
					$M365QualityUpdateInfo += $M365RawTableArray[$index+4]	#Semi-Annual Enterprise Channel (Preview)
		            break #out of foreach loop
		        }
		    }
		}
		
		Write-host "`r`nThis is the row we have scraped from table:"
		Write-host  "[$($M365QualityUpdateInfo| out-string)]`r`n"

		If ($M365QualityUpdateInfo.Count -lt 1) {
			Write-Warning "No build numbers found for date: $PTyear $PTMonthDay"
			return $null
		}
		
		switch ($UpdateChannel) {
			"Current Channel" {
				[Int]$UpdateChannelIndex = 2
				break
			}
			"Monthly Enterprise Channel" {
				[Int]$UpdateChannelIndex = 3
				break
			}
			"Semi-Annual Enterprise Channel (Preview)" {
				[Int]$UpdateChannelIndex = 4
				break
			}
			default {
				Write-Error "ERROR: -UpdateChannel [$UpdateChannel] is not supported"
				Throw "-UpdateChannel [$UpdateChannel] is not supported"
			}
		}


		Write-Host "$UpdateChannel build number [$($M365QualityUpdateInfo[$UpdateChannelIndex])]"
		[String]$M365UpdateBuildNumber = $($M365QualityUpdateInfo[$UpdateChannelIndex]).trim().replace(')','')
		#grab the last build number of the line in-case we have multiple updates 
		$M365UpdateBuildNumber = $M365UpdateBuildNumber.Substring($M365UpdateBuildNumber.Length - 11)
		 
		#Add 16.0. to the Build number so that OfficeC2RClient.exe can use it.
		Write-host "Selected Microsoft 365 Apps Build Number: [$M365UpdateBuildNumber]"
		[String]$M365UpdateFullBuildNumber = "16.0." + $M365UpdateBuildNumber

		return $M365UpdateFullBuildNumber
    } catch {
        if ($_.Exception.Message -like "We did not find*") {
            Write-Warning $_.Exception.Message
        } else {
            throw $_
        }
    }
}


#Get-MSOfficeBuildNumber -PTMonthDay 'July 12' -UpdateChannel "Monthly Enterprise Channel"
Get-MSOfficeBuildNumber -PTMonthDay 'July 12' -UpdateChannel "Current Channel"
#Get-MSOfficeBuildNumber -PTMonthDay 'July 13' -UpdateChannel "Current Channel"