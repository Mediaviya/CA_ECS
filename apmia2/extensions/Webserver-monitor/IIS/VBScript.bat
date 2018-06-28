@echo off
REM	IIS VB Script Run utility
REM
REM	This file launches the PublishIISStats.vbs from the given absolute path location 
REM	and publishes IIS Metrics to the statistics page given in the output absolute
REM	path location.
REM
REM CA APM for Web Servers
REM				 
REM CA Wily Introscope(R) Version 99.99.top_store Build 289									 
REM Copyright (c) 2016 CA. All Rights Reserved.									 
REM Introscope(R) is a registered trademark of CA.	


REM 	Please provide the absolute path to the VBScript and publish stats page including file names
REM	The path to stats page should be an absolute path to a HTML file (*.htm/*.html)

title CA APM for Web Servers
cscript /nologo "<path to VBScript>" /output:"<path to publish stats page>" /frequency:15