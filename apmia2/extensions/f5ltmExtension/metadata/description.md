## Description
* A monitoring Extension for reporting the F5 LTM (Local Traffic Manager) related metrics.
* The REST API exposed by F5 is invoked to collect the metrics and returned data is used to display on the Webview / ATC. 
* Below are the components on which metrics are collected.
> HTTP,TCP,Network Interfaces,Pools,Pool Members,Logical Disks,Hosts,PER CPU,Virtual Servers,Rules,Server SSL,Cline SSL

## Supported third party versions
* Tested with F5 BIG-IP v13.0.0 (Build 0.0.1645), should work with F5 versions which supports REST API invocation.

