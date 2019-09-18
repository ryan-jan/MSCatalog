# MSCatalog

MSCatalog is a PowerShell module for searching and downloading updates from https://www.catalog.update.microsoft.com.
It is cross-platform and runs on both Desktop and Core versions of PowerShell.

[![appveyor](https://ci.appveyor.com/api/projects/status/es35kl0uq8ldaty6?svg=true)](https://ci.appveyor.com/project/ryan-jan/mscatalog)
[![psgallery](https://img.shields.io/powershellgallery/v/mscatalog.svg)](https://www.powershellgallery.com/packages/MSCatalog)
[![codecov](https://codecov.io/gh/ryan-jan/MSCatalog/branch/master/graph/badge.svg)](https://codecov.io/gh/ryan-jan/MSCatalog)

## Getting Started

MSCatalog can be installed from the PowerShell Gallery in the usual way.

``` powershell
Install-Module -Name MSCatalog -Scope CurrentUser
```

## Get-MSCatalogUpdate

This command is used to retrieve updates from the [https://www.catalog.update.microsoft.com](https://www.catalog.update.microsoft.com)
website. By default it returns the first 25 items from the search.

```powershell
Get-MSCatalogUpdate -Search "Cumulative Update for Windows Server 2016 (1803)"

Title                                                                                               Products            Classification   LastUpdated Size    
-----                                                                                               --------            --------------   ----------- ----    
2019-08 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4512509)          Windows Server 2016 Updates          2019/08/19  930.7 MB
2019-08 Cumulative Update for .NET Framework 4.8 for Windows Server 2016 (1803) for x64 (KB4511521) Windows Server 2016 Updates          2019/08/16  46.7 MB 
2019-07 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4507466)          Windows Server 2016 Updates          2019/07/16  915.5 MB
2019-06 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4509478)          Windows Server 2016 Updates          2019/06/26  895.7 MB
2019-06 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4503288)          Windows Server 2016 Updates          2019/06/18  895.3 MB
2019-06 Cumulative Update for .NET Framework 4.8 for Windows Server 2016 (1803) for x64 (KB4502563) Windows Server 2016 Updates          2019/06/17  45.5 MB 
2019-05 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4499183)          Windows Server 2016 Updates          2019/05/20  891.4 MB
2019-05 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4505064)          Windows Server 2016 Updates          2019/05/19  887.5 MB
2019-04 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4493437)          Windows Server 2016 Updates          2019/04/24  883.9 MB
2019-03 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4489894)          Windows Server 2016 Updates          2019/03/19  846.1 MB
2019-02 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4487029)          Windows Server 2016 Updates          2019/02/19  835.8 MB
2019-01 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4480976)          Windows Server 2016 Updates          2019/01/14  808.2 MB
2018-10 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4462933)          Windows Server 2016 Updates          2018/10/23  782.3 MB
2018-09 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4458469)          Windows Server 2016 Updates          2018/09/26  767.3 MB
2018-09 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4464218)          Windows Server 2016 Updates          2018/09/17  756.5 MB
2018-08 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4346783)          Windows Server 2016 Updates          2018/08/30  748.8 MB
2018-07 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4340917)          Windows Server 2016 Updates          2018/07/20  713.1 MB
2018-07 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4345421)          Windows Server 2016 Updates          2018/07/16  678.2 MB
2018-06 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4284848)          Windows Server 2016 Updates          2018/06/22  633.4 MB
2018-06 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4338548)          Windows Server 2016 Updates          2018/06/05  431.4 MB
2018-05 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4100403)          Windows Server 2016 Updates          2018/05/24  426.7 MB
2018-05 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4103721)          Windows Server 2016 Security Updates 2018/05/04  326.5 MB
2019-09 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4516058)          Windows Server 2016 Security Updates 2019/09/09  933.8 MB
2019-09 Cumulative Update for .NET Framework 4.8 for Windows Server 2016 (1803) for x64 (KB4514357) Windows Server 2016 Security Updates 2019/09/06  46.7 MB
2019-08 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4512501)          Windows Server 2016 Security Updates 2019/08/09  919.3 MB
```

However, if you would like to return all available results you can specify the `AllPages` parameter.

```powershell
Get-MSCatalogUpdate -Search "Cumulative Update for Windows Server 2016 (1803)" -AllPages
```

**NOTE: This could cause a significant number of web requests. The catalog website will only provide 25 results at a time
and this would just keep looping over all available results until it reaches the maximum of 1000.**

## Save-MSCatalogUpdate

This command is used to download update files from the [https://www.catalog.update.microsoft.com](https://www.catalog.update.microsoft.com)
website.

There are two options for specifying which update to download. Firstly, you can use the `Update` parameter
to specify an object returned from `Get-MSCatalogUpdate`. For example, first run `Get-MSCatalogUpdate` and
store the results in a variable.

```powershell
$Updates = Get-MSCatalogUpdate -Search "Cumulative Update for Windows Server 2016 (1803)"
```

Then specify the update that you wish to download by its index in the `$Updates` array, `0` being the first,
and by default often the latest, update in the list.

```powershell
Save-MSCatalogUpdate -Update $Updates[0] -Destination ".\"
```

You can also pipe from one command to the other, so a one-liner to get the latest update might look like this.

```powershell
(Get-MSCatalogUpdate -Search "Cumulative Update for Windows Server 2016 (1803)")[0] | Save-MSCatalogUpdate -Destination ".\"
```

Secondly, you can specify the `Guid` parameter. For example, first select the Title and Guid fields from our
`$Updates` variable.

```powershell
$Updates | Select-Object Title, Guid

Title                                                                                               Guid
-----                                                                                               ----
2019-08 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4512509)          58b95dca-41aa-44e3-8293-eccd607481d5
2019-08 Cumulative Update for .NET Framework 4.8 for Windows Server 2016 (1803) for x64 (KB4511521) 4734d13d-5e5a-4b64-9e93-225674ec811c
2019-07 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4507466)          2a85b739-449e-4654-b527-0236c36eb975
2019-06 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4509478)          79d238a5-3bd4-43cb-a254-bfd57b2423b0
2019-06 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4503288)          e48ba8d6-a18f-4d4b-baa0-3f2d9383c5ec
2019-06 Cumulative Update for .NET Framework 4.8 for Windows Server 2016 (1803) for x64 (KB4502563) c34b0ed7-539f-40b2-bbd5-b39efec52e61
2019-05 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4499183)          ab66c1d1-7e05-49eb-aa1f-b0b4e79943ba
2019-05 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4505064)          5dc96624-4501-4d4c-9f93-22afaf806790
2019-04 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4493437)          bfe757b7-6572-47be-a9b0-cb7e8708e67b
2019-03 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4489894)          153a50a5-a358-4c33-a027-af9d8b4e2114
2019-02 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4487029)          638ef53d-cec0-4c6e-bc35-e37abb3ee044
2019-01 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4480976)          d1dcf2fe-f549-48cd-be3a-e3b22d34853f
2018-10 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4462933)          f7333e00-7774-443b-ac39-b24dea578451
2018-09 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4458469)          7a97d557-1d5c-4482-b6e7-20aeb4c26ce7
2018-09 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4464218)          cc61ea03-c78d-4e13-8e89-13aea84ecf48
2018-08 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4346783)          f5eca68a-8efa-45cb-a1da-12e23cf42f79
2018-07 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4340917)          f272ab6b-3bab-483b-8ae7-9509c7f6bbb9
2018-07 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4345421)          19a5b8b7-63d0-45d5-895b-3d3be7303c1e
2018-06 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4284848)          e298416e-5814-44d3-8075-cd89ec691369
2018-06 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4338548)          3519225a-e20a-4a8e-8e42-7a9a429484d7
2018-05 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4100403)          940927c3-9d3d-4303-833c-113567373d6b
2018-05 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4103721)          fdd62b2a-0e40-4c06-b153-7d2f5e45f613
2019-09 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4516058)          aa4b167d-e6b6-4206-aa84-b9c135353b77
2019-09 Cumulative Update for .NET Framework 4.8 for Windows Server 2016 (1803) for x64 (KB4514357) 909203a9-3703-41b7-af63-efc31496314a
2019-08 Cumulative Update for Windows Server 2016 (1803) for x64-based Systems (KB4512501)          5570183b-a0b7-4478-b0af-47a6e65417ca
```

Then download a specific update as follows.

```powershell
Save-MSCatalogUpdate -Guid "4734d13d-5e5a-4b64-9e93-225674ec811c" -Destination ".\"
```

Some updates on the [https://www.catalog.update.microsoft.com](https://www.catalog.update.microsoft.com) website
are provided as multiple separate files, usually separating different languages. If this is the case you will
be prompted to select the file you wish to download.

```powershell
$Update = Get-MSCatalogUpdate -Search "Update for Microsoft Office 2013 (KB4011677) 32-Bit Edition"
Save-MSCatalogUpdate -Update $Update -Destination ".\"

Id  FileName
--  --------
 0  proof-ar-sa_d140d14d65cf35bf269443bedf33a91ce25ced17.cab
 1  proof-sl-si_7779ffad03046159c9fe46ea8b51cef2359ed043.cab
 2  proof-ru-ru_ad51c3015fef4ec84c7bf1bd7ecea3ae50513001.cab
 3  proof-fr-fr_cbaeb8d70abf4bdcdeab71b4e49a398ab683712c.cab
 4  proof-ko-kr_8b46b86d03f85b4d086ca4d1660a7a21ac42f578.cab
 5  proof-de-de_6b6827e86e0dc683245928c6b79dd4ac30347025.cab
 6  proof-eu-es_545179291145aef04a5d52fa1a099b9d75fd9579.cab
 7  proof-da-dk_ce1216eeb6613c13c05aef035d975244a30104c0.cab
 8  proof-hu-hu_2836b2b61c069f8044fadff8da95a7fe863c8ac1.cab
 9  proof-cs-cz_e770f507e123ad7041e0bebff98a56c52371ee9e.cab
10  proof-he-il_2f9d6065513e8b16f071b2cde122fa58af8dcfcf.cab
11  proof-en-us_1ae4178394992158748a482513090b4b34a4f14b.cab
12  proof-sk-sk_7deb8a95620b29d6ea18da89280f78a0d27f8483.cab
13  proof-ja-jp_3b98bb08afebd3008eb35b57a8ad6cfd8d7a3d3f.cab
14  proof-nl-nl_17cae97668c7823db00841fa29f21c2e7dd3d2f7.cab
15  proof-gl-es_06ad65e6d87f03024b134bfd1738fb1e5c0dbf73.cab
16  proof-pt-pt_9b20088d5ecc7b5667ee50ce62c05691f69f6b7b.cab
17  proof-zh-tw_85ba14c9118dbd2f8f45994bc2be9dd43bea0835.cab
18  proof-uk-ua_fa2c211f0338f05a7246c5f964dee232d1324c2d.cab
19  proof-tr-tr_4cebbef622cbc4ba57c4dbee0d599f43517c81ea.cab
20  proof-sv-se_a76dd4e3f8cd6cd3c78dda6f790e96288e1d342b.cab
21  proof-lt-lt_555e3ae1896c64e0bf4d090967441c84144f5fc0.cab
22  proof-it-it_1d501afe89d70168f85ea3ba4abf0f56530d5a07.cab
23  proof-nb-no_912c5a241d0cc0bdcb1558e80c5c2da43c364ed5.cab
24  proof-hr-hr_121779d22ece7a765d903506d73e0ac20753b5e8.cab
25  proof-pt-br_4881529c0171ea6208ce18b5de6c71684bad8976.cab
26  proof-et-ee_bd4fe166c78101ff937564677cac47a222be34d0.cab
27  proof-lv-lv_e7b24d89a2a72b1d8f3becef347ec49af736bbb0.cab
28  proof-th-th_57215ae8456dc0426c9a0a7b30c5c93c53fb93a7.cab
29  proof-el-gr_2f1ba04c2b0fb19ea1155c3d64a789e9a73b3684.cab
30  proof-ro-ro_62e712365bcb41cfb64417b228ee44d0a14b1a56.cab
31  proof-bg-bg_eaba8da224491f79802b27eceed9acfef68b56a4.cab
32  proof-sr-cyrl-cs_6f091498ad5b32e43838b6993cba9e32785aee61.cab
33  proof-zh-cn_de159b2b81701d56d070455fb63d062a8c84c31f.cab
34  proof-nn-no_5554397a926949767d64803f19296b18ca952c50.cab
35  proof-pl-pl_f911fda3832d574bd077a68b574565d8cd739f33.cab
36  proof-hi-in_0628542b025c310c8ccef630627acb6f33648909.cab
37  proof-ca-es_f6e24c8abd81d16ee14e4094e98419fccf19d224.cab
38  proof-sr-latn-cs_551d05fa7b113d467d36f394976992f95bd192b5.cab
39  proof-es-es_56697686e635a996b06b216fc3f0b4f7a49686f3.cab
40  proof-fi-fi_100b6b21d102186192a860630007c06026106b0e.cab
Multiple files exist for this update. Enter the Id of the file to download:
```

However, if you do not wish to be prompted, you can use the `Language` parameter to specify the `language-country`
code of the update to download.

```powershell
$Update = Get-MSCatalogUpdate -Search "Update for Microsoft Office 2013 (KB4011677) 32-Bit Edition"
Save-MSCatalogUpdate -Update $Update -Destination ".\" -Language "en-us"
```

## HtmlAgilityPack

In order to stay cross-platform, MSCatalog uses the [HtmlAgilityPack](https://html-agility-pack.net) HTML parser library.
This is instead of relying on the common IE based `ParsedHtml` property of the `Invoke-WebRequest` CmdLet, which would only work
on Windows based systems, and even then would not work in certain scenarios e.g. when run in the context of the
`SYSTEM` user.

The PowerShell gallery package includes the `Net45` and `netstandard2.0` `.dll` files and will attempt to add these
to your session via the `Add-Type` CmdLet when you import the module (`Net45` if using the Desktop version of PowerShell
and `netstandard2.0` if using PowerShell Core). If this fails, or you require a different version of the
HtmlAgilityPack library, all you need to do is ensure that you manually load the required `.dll`
before you run `Import-Module MSCatalog` and your version will be honoured.
