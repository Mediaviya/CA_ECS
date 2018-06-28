
1. Configure webservers in WebServerMonitor/config/WebServerConfig.xml file:

    	<WebServer Type="Apache:Oracle-HTTP-Server" Enabled="true" Protocol="SSL" Mode="Non-Permissive" ServerURL="https://xyzabc:443" DisplayName="xyzabc-Apache" RefreshFrequencyInSeconds="30"/>
    
	WebServerConfig.xml automatically detects changes and monitors new webservers configured.
	
2. (Optional)  Enable autodiscovery of webservers in WebServerMonitor/bundle.profile, this is not a hot property.
	`agent.webserver.discovery=false`
	
	Configure subnets in WebServerMonitor/config/DiscoveryConfig.xml 
             
            <SubNet>155.35.88.56-155.35.88.80</SubNet> 
            <Port Number="80" Type="TCP">
            		<FingerPrintMatcher>Apache</FingerPrintMatcher>
                        <FingerPrintMatcher>Apache:IBM_HTTP_SERVER</FingerPrintMatcher>
	                <FingerPrintMatcher>Apache:Oracle-HTTP-Server </FingerPrintMatcher>
			<FingerPrintMatcher>Microsoft-IIS</FingerPrintMatcher>
	    </Port>
		
3. APM Map: For displaying Webserver in APM Map, Webserver should enable HTTP headers X-Forwarded-For and X-Forwarded-Host as mentioned below.

	a. Apache Web server and it's derivatives.  
   	Apache enables HTTP headers X-Forwarded-For and X-Forwarded-Host headers with default configuration.Ensure that ProxyAddHeaders 
    is enabled in the  &lt;Apache_HOME&gt;/conf/httpd.conf file.   
	
    		ProxyAddHeaders On
	 
    Ensure that transactions are going through Web server For example: 

			ProxyPass /brtmtestapp http://applicationserver:80/brtmtestapp 
			PoxyPassReverse /brtmtestapp http://applicationserver:80/brtmtestapp
			
	Another example is:
   
			<Location "/brtmtestapp/">
				ProxyPass "http://applicationserver:80/brtmtestapp/"
				ProxyPassReverse  "http://applicationserver:80/brtmtestapp/"	
			</Location>

  	b. IIS Web server.  
  	IIS needs to use the URL_rewrite module and Application Request Routing to display the Web servers on CA APM map. Hence,
    URL rewrite and Application Request Routing must be installed manually, and additional configuration is need at IIS  adding  X-
    Forwarded-Host server variable. Server variable name as `HTTP_X-Forwarded-Host` and value as `{HTTP_X-Forwarded-Host},iishost:80`
