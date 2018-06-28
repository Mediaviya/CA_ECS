'******************************************************************
'	IIS VB Script File
'
'This file accesses WMI classes and get metrics for the IIS Server
'of the machine in which it is running and puts it in a HTML file
'
' CA (tm) Introscope(R) PowerPack(tm) for Web Servers                    	
'																					 
'																					 
' CA Wily Introscope(R) Version 99.99.top_store Build 289									 
' Copyright (c) 2016 CA. All Rights Reserved.									 
' Introscope(R) is a registered trademark of CA.		
'******************************************************************

Main

Sub Main()
	Dim refreshFrequencyInSeconds
	Dim strFileName
	With Wscript.Arguments
		If .Named("output") = "" Then Usage
		If .Named("frequency") = ""  Then Usage
		strFileName = .Named("output")
		refreshFrequencyInSeconds = .Named("frequency")
	End With

	WScript.Echo "Publishing IIS performance statistics to " & strFileName & " every " & refreshFrequencyInSeconds & " seconds..."
	Do While True			
		Set objFS = CreateObject("Scripting.FileSystemObject")
		If objFS.FileExists("wilyIISTempFile") Then
			Set output = objFS.OpenTextFile("wilyIISTempFile", 2)
		Else
			Set output = objFS.CreateTextFile("wilyIISTempFile")
		End If		
		output.WriteLine "<pre>"
		PrintWMICounters "SELECT * FROM Win32_PerfFormattedData_InetInfo_InternetInformationServicesGlobal", output
		PrintWMICounters "SELECT * FROM Win32_PerfFormattedData_W3SVC_WebService WHERE Name='_Total'", output
		output.WriteLine "</pre>"
		output.Close	
		Set output=objFS.GetFile("wilyIISTempFile")
		output.Copy strFileName, TRUE	
		Wscript.Sleep refreshFrequencyInSeconds * 1000
	Loop
End Sub

Sub Usage()
	Wscript.Echo _
	"Usage: /output:<output file name> /frequency:<frequency in seconds>" & vbNewLine _
	& "Example: cscript /nologo PublishIISStats.vbs /output:iis-stats.html /frequency:15"
	Wscript.Quit 0
End Sub

Function PrintWMICounters(ByVal strQuery, ByRef output)
	strComputer = "."
	strNamespace = "\root\cimv2"

	Set objSWbemServices = GetObject("winmgmts:\\" & strComputer & strNamespace)
	Set colSWbemObjectSet = objSWbemServices.ExecQuery(strQuery)

	output.WriteLine "Query=" & strQuery & vbCrLf
	intInstance = 1
	For Each objSWbemObject In colSWbemObjectSet
		' output.WriteLine "Instance=" & intInstance & vbCrLf
	    	For Each objSWbemProperty In objSWbemObject.Properties_
			strPropertyValue = ConvertPropertyValueToString(objSWbemProperty.Value)
			output.WriteLine objSWbemProperty.Name & "=" & strPropertyValue
	    	Next
	    	output.WriteLine
	    	intInstance = intInstance + 1
	Next
End Function

Function ConvertPropertyValueToString(ByVal PropertyValue)
	If IsObject(PropertyValue) Then
		ConvertPropertyValueToString = "<CIM_OBJECT (embedded SWbemObject)>"
	ElseIf IsNull(PropertyValue) Then
		ConvertPropertyValueToString = "<NULL>"
	ElseIf IsArray(PropertyValue) Then
		ConvertPropertyValueToString = Join(PropertyValue, ",")
	Else
		ConvertPropertyValueToString = CStr(PropertyValue)
	End If
End Function
