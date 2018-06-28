
1. Set values for the following properties in the F5LTMExtension/bundle.properties file:
	* Mention IP address of the machine on which F5 is running
	> introscope.agent.f5. host= {IP address of the machine on which F5 is running}
	* Mention port number through which F5 instance is reachable on above IP
	> introscope.agent.f5. port= {port number through which F5 instance is reachable on above IP}
	* Mention F5 user name, this user should have access to the F5 REST API
	> introscope.agent.f5. user= {F5 user name, this user should have access to the F5 REST API)
	* Mention Password of above user
	> introscope.agent.f5. password={Password of above user}
	* Mention time interval in seconds for invoking the F5 API
	> introscope.agent.f5. update.interval={time interval in seconds for invoking the F5 API}
	
	* Mention IP addresses of virtual servers created in F5 LTM instance. Use comma as delimiter for entering multiple virtual servers
	> introscope.agent.f5. virtualServer.hosts={IP addresses of virtual servers created in F5 LTM instance} 
	
	* Set this property with the components (if any) to avoid monitoring. The list of components are HTTP,TCP,Network Interfaces,Pools,Pool Members,Logical Disks,Hosts,PER CPU,Virtual Servers,Rules,Server SSL,Client SSL 
	> introscope.agent.f5. skipMonitorOn= {any of the above components}
	
	* This is used to avoid the metric explosion due to large number of iRules present. Rules (rule name) mentioned here will only be monitored/reported.
	> introscope.agent.f5. monitoredRules=_sys_auth_ldap,_sys_auth_radius 
	
2. Create iRule in F5
	* On the Main tab, expand Local Traffic, and click iRules. The iRules screen opens.
	* In the upper right corner, click Create.
	* In Name, type a 1- to 31-character name.
	* In Definition, type the syntax mentioned below for the iRule.
	>	when HTTP\_REQUEST {
	>		HTTP::header insert x-forwarded-For "[IP::client\_addr],\Replace with
	>		Virtual server hostname\"
	>	}
	* For example:
	>	when HTTP\_REQUEST {
	>		HTTP::header insert x-forwarded-For "[IP::client\_addr],abc04-k1234.abc.com"
	>	}
	* Click Finish.

3. Adding iRule to Virtual Server:
	* Go to Local Traffic > Virtual Servers > 'Name' > iRules and select the iRule you've created above
	
4. Stop & Start APM IA server