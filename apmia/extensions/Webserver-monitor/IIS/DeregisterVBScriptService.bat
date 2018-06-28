@echo off
REM	De-registers the VBScript.bat file as a Service in Windows.
REM	Should be deployed in an IIS Web Server Machine
REM
REM CA APM for Web Servers
REM				 
REM CA Wily Introscope(R) Version 99.99.top_store Build 289									 
REM Copyright (c) 2016 CA. All Rights Reserved.									 
REM Introscope(R) is a registered trademark of CA.	

title CA APM for Web Servers
WinService REMOVE
