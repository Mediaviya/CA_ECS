########################################################################
#                                                                      
# Introscope AutoProbe and Agent Configuration                         
#                                                                      
# CA Wily Introscope(R) Version 10.7.0 Release 10.7.0.45
# Copyright &copy; 2018 CA. All Rights Reserved.
# Introscope(R) is a registered trademark of CA.
########################################################################

########################
# AutoProbe Properties #
########################

#######################
# On/Off Switch
#
# ================
# This boolean property gives you the ability to disable
# Introscope AutoProbe by settings the property value
# to false.
# You must restart the collector agent before changes to this property take effect.

introscope.autoprobe.enable=true

#######################
# Custom Log File Location
#
# ================
# Introscope AutoProbe will always attempt to log the changes
# it makes.  Set this property to move the location of the
# log file to something other than the default.  Non-absolute
# names are resolved relative to the location of this
# properties file.
# You must restart the collector agent before changes to this property take effect.

introscope.autoprobe.logfile=../../logs/AutoProbe.log


#######################
# Directives Files
#
# ================
# This property specifies all the directives files that determine
# how Introscope AutoProbe performs the instrumentation.  Specify
# a single entry, or a comma-delimited list of entries. The list 
# may include any combination of:
#    - directives (.pbd) files
#    - directives list (.pbl) files 
#    - directories that will be scanned about once per minute for  
#      .pbd files. Directives files placed in a listed directory
#      will be loaded automatically, without any need to edit this 
#      Agent profile. If dynamic instrumentation is enabled, the 
#      directives will take effect immediately without an app reboot.    
# Non-absolute names will be resolved relative to the location of 
# this properties file.
# IMPORTANT NOTE: This is a required parameter and it MUST be set
# to a valid value.  
#    - If the property is not specified or the values are invalid, 
#      the Introscope Agent will not run!  
#    - If the property is set to include a directory, and invalid 
#      directives files are placed in the directory, AutoProbe  
#      metrics will no longer be reported!
#    - If the property is set to include a directory, and loaded 
#      directives files are removed from the directory, AutoProbe  
#      metrics will no longer be reported!
# You must restart the collector agent before changes to this property 
# take effect. However, if the property includes one or more directories, 
# and dynamic instrumentation is enabled, the Introscope Agent will load 
# directives files from the specified directories without an app restart, 
# as noted above.

introscope.autoprobe.directivesFile=hotdeploy


#######################
# Agent Properties    #
#######################

#######################
# Remote Probe Collector Port
#
# ================
# Introscope will listen to connections from probes on this port to
# collect events.
# You must restart agent before the changes to this property take effect.

introscope.remoteagent.collector.tcp.port=5005
introscope.remoteagent.collector.tcp.local.only=false

# Each probe instance connection to collector is mapped to the virtual agent at EM
# Following two properties will govern how this agent will be named.
#
# There are three replacementvariables that allowed in the configured name:
#
#	{type} - Probe type. Currently supported types are php and nodejs
#	{program} - Name of the program that probe is attached to (e.g. /usr/bin/httpd)
#	{collector} - Name of collector agent. See agent naming properties below.
#
# These properties are not hot and require collector re-start to take effect.
# Default value for probe process name is {type}
introscope.remoteagent.probe.process.name = {type}-probes
# Default value for probe agent name is {program}
introscope.remoteagent.probe.agent.name = {program} Agent

#################################
# EPAgent Configuration
#-----------------

# Network port on which to receive simple or XML formatted data. If commented
# out or left unconfigured then EPAgent will not listen for data.
#
#introscope.epagent.config.networkDataPort=8000

# Network port on which to listen for HTTP GET commands. If commented out or
# left unconfigured then EPAgent will not listen for HTTP commands
#
#introscope.epagent.config.httpServerPort=8080

# Time period in seconds that a stateless plugin is allowed to run before it
# is considered stalled and forcefully killed. If commented out or left unconfigured
# the default is 60 seconds. A value of zero will prevent stalled plugins from
# being detected and killed.
#
introscope.epagent.config.stalledStatelessPluginTimeoutInSeconds=60

#################################
# Logging Configuration
#
# ================
# Changes to this property take effect immediately and do not require the collector agent to be restarted.
# This property controls both the logging level and the output location.
# To increase the logging level, set the property to:
# log4j.logger.IntroscopeAgent=VERBOSE#com.wily.util.feedback.Log4JSeverityLevel, console, logfile
# To send output to the console only, set the property to:
# log4j.logger.IntroscopeAgent=INFO, console
# To send output to the logfile only, set the property to:
# log4j.logger.IntroscopeAgent=INFO, logfile

log4j.logger.IntroscopeAgent=INFO, logfile

#log4j.logger.IntroscopeAgent.ProbeCollector=TRACE#com.wily.util.feedback.Log4JSeverityLevel, console, logfile

# If "logfile" is specified in "log4j.logger.IntroscopeAgent",
# the location of the log file is configured using the
# "log4j.appender.logfile.File" property.
# System properties (Java command line -D options)
# are expanded as part of the file name.  For example,
# if Java is started with "-Dmy.property=Server1", then
# "log4j.appender.logfile.File=../../logs/Introscope-${my.property}.log"
# is expanded to:
# "log4j.appender.logfile.File=../../logs/Introscope-Server1.log".

log4j.appender.logfile.File=../../logs/IntroscopeAgent.log
 
########## See Warning below ##########
# Warning: The following properties should not be modified for normal use.
# You must restart the collector agent before changes to this property take effect.
log4j.additivity.IntroscopeAgent=false
log4j.appender.console=com.wily.org.apache.log4j.ConsoleAppender
log4j.appender.console.layout=com.wily.org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{M/dd/yy hh:mm:ss a z} [%-3p] [%c] %m%n
log4j.appender.console.target=System.err
log4j.appender.logfile=com.wily.introscope.agent.AutoNamingRollingFileAppender
log4j.appender.logfile.layout=com.wily.org.apache.log4j.PatternLayout
log4j.appender.logfile.layout.ConversionPattern=%d{M/dd/yy hh:mm:ss a z} [%-3p] [%c] %m%n
log4j.appender.logfile.MaxBackupIndex=4
log4j.appender.logfile.MaxFileSize=2MB
#########################################

#################################
# DNS lookup configuration
# 
# Agent has following DNS lookup implementations: direct and separateThread.  Implementation to use is specified 
# by value of introscope.agent.dns.lookup.type property.
# direct performs DNS lookups in application thread. Application thread will be delayed by length of time the 
# underlying DNS mechanism takes to perform a specific lookup.
# separateThread performs DNS lookups in a separate thread. The application thread is delayed at most by 
# introscope.agent.dns.lookup.max.wait.in.milliseconds milliseconds.
# When using separateThread implementation, if lookup of host name by IP address times out, IP address will be returned
# in place of name and if lookup of IP address by host name times out, empty IP address will be returned.  
# Default DNS lookup implementation is separateThread
#
# You must restart the collector agent before change to this property takes effect.
#introscope.agent.dns.lookup.type=direct
introscope.agent.dns.lookup.type=separateThread
#
# Maximum time in milliseconds separateThread implementation waits to lookup a host name or IP address. 
# It is ignored by direct implementation.  Default value is 200.
# Change to this property takes effect immediately and does not require the collector agent to be restarted.
introscope.agent.dns.lookup.max.wait.in.milliseconds=200


#################################
# Enterprise Manager Locations and Names 
#
# The Enterprise Manager 'connection order' list the Agent uses if it 
# is disconnected from its Enterprise Manager is determined automatically
# based on the numeric suffix provided to "agentManager.url" property.
#
# For example if "agentManager.url.1" , "agentManager.url.2" and 
# "agentManager.url.3" are defined and enabled then connection order 
# will be "1,2,3" with "1" getting the highest precedence and so on.
#
# Default channel is "1". All the related properties of default channel 
# are suffixed with "1".
# Similarly if channel "2" is defined and enabled , then all of the
# properties related to it must be suffixed with "2".
#
# ================
# Settings the Introscope Agent uses to find the Enterprise Manager 
# and names given to host and port combinations.
#
# You must restart the managed application before changes to this property take effect.

agentManager.url.1=localhost:5001

# The following connection properties enable the Agent to tunnel communication 
# to the Enterprise Manager over HTTP.
#
# WARNING: This type of connection will impact Agent and Enterprise Manager 
# performance so it should only be used if a direct socket connection to the 
# the Enterprise Manager is not feasible. This may be the case if the Agent 
# is isolated from the Enterprise Manager with a firewall blocking all but 
# HTTP traffic.
# 
# When enabling the HTTP tunneling Agent, uncomment the following host and port
# properties, setting the host name and port for the Enterprise Manager Web Server. 
# Comment out any other connection properties assigned to the default channel "1"
# (i.e. properties having "1" as suffix)
#
# "http" in the value of the below property states the agent to use HTTP tunneling
# for connecting to EM.
#
# You must restart the managed application before changes to this property take effect.
#agentManager.url.1=http://localhost:8081


# The following properties are used only when the Agent is tunneling over HTTP 
# and the Agent must connect to the Enterprise Manager through a proxy server 
# (forward proxy). Uncomment and set the appropriate proxy host and port values. 
# If the proxy server cannot be reached at the specified host and port, the 
# Agent will try a direct HTTP tunneled connection to the Enterprise Manager 
# before failing the connection attempt.
# You must restart the managed application before changes to this property take effect.
#agentManager.httpProxy.host=
#agentManager.httpProxy.port=

# The following properties are used only when the proxy server requires 
# authentication. Uncomment and set the user name and password properties.
# You must restart the managed application before changes to this property take effect.
# For NTLM credentials you must separate domain name from user name by escaped backslash
# e.g. mydomain.com\\jack01
#agentManager.httpProxy.username=
#agentManager.httpProxy.password=

# To connect to the Enterprise Manager using HTTPS (HTTP over SSL),
# uncomment the below property and set the host and port to the EM's secure https listener host and port.
# "https" in the value of the below property states the agent to use HTTPS tunneling for connecting to EM.
#agentManager.url.1=https://localhost:8444

# To connect to the Enterprise Manager using SSL,
# uncomment the below property and set the host and port to the EM's SSL server socket host and port.
# "ssl" in the value of the below property states the agent to use SSL socket for connecting to EM.
#agentManager.url.1=ssl://localhost:5443


# Additional properties for connecting to the Enterprise Manager using SSL.
#
# Location of a truststore containing trusted EM certificates.
# If no truststore is specified, the agent trusts all certificates.
# Either an absolute path or a path relative to the agent's working directory.
# On Windows, backslashes must be escaped.  For example: C:\\keystore
#agentManager.trustStore.1=
# The password for the truststore
#agentManager.trustStorePassword.1=
# Location of a keystore containing the agent's certificate.
# A keystore is needed if the EM requires client authentication.
# Either an absolute path or a path relative to the agent's working directory.
# On Windows, backslashes must be escaped.  For example: C:\\keystore
#agentManager.keyStore.1=
# The password for the keystore
#agentManager.keyStorePassword.1=
# Set the enabled cipher suites.
# A comma-separated list of cipher suites.
# If not specified, use the default enabled cipher suites.
#agentManager.cipherSuites.1=


#################################
# Enterprise Manager Failback Retry Interval
#
# ================
# When the Agent is configured to have multiple Enterprise Managers
# in its connection order and this property is enabled, the Introscope 
# Agent will automatically attempt to connect to the Enterprise Manager
# in its connection order to which it can connect in allowed mode.
# In case no such Enterprise Manager is found, the reconnection attempt 
# will occur on a regular interval as specified.
# Agent will not connect to any Enterprise Manager in disallowed mode,  
# when this property is enabled.
# You must restart the collector agent before changes to this property take effect.

#introscope.agent.enterprisemanager.failbackRetryIntervalInSeconds=120


#######################
# Custom Process Name
#
# ================
# Specify the process name as it should appear in the
# Introscope Enterprise Manager and Workstation.
# You must restart the collector agent before changes to this property take effect.

#introscope.agent.customProcessName=CustomProcessName


#######################
# Default Process Name
#
# ================
# If no custom process name is provided and the
# agent is unable to determine the name of the
# main application class, this value will be
# used for the process name.
# You must restart the collector agent before changes to this property take effect.

introscope.agent.defaultProcessName=Infrastructure


#######################
# Agent Name
#
# ================
# Specify the name of this agent as it appears in the
# Introscope Enterprise Manager and Workstation.

# Use this property if you want to specify the Agent
# Name using the value of a Java System Property.
# You must restart the collector agent before changes to this property take effect.
introscope.agent.agentNameSystemPropertyKey=

# This enables/disables auto naming of the agent using
# an Application Server custom service.
# You must restart the collector agent before changes to this property take effect.
introscope.agent.agentAutoNamingEnabled=false

# Uncomment this property to provide a default Agent Name 
# if the other methods fail.
# You must restart the collector agent before changes to this property take effect.
introscope.agent.agentName=Agent

# Fully Qualified Domain Name (FQDN) can be enabled by setting this property  
# value to 'true'. By Default (false) it will display HostName.
# Set to 'true' when integrating with Catalyst.
# You must restart the collector agent before changes to this property take effect.
introscope.agent.display.hostName.as.fqdn=false


#######################
# Agent Extensions Directory
#
# ================
# This property specifies the location of all extensions to be loaded
# by the Introscope Agent.  Non-absolute names are resolved relative 
# to the location of this properties file.
# You must restart the collector agent before changes to this property take effect.

introscope.agent.extensions.directory=../../core/ext

# This property specifies the location of extension bundles
# to be loaded by the Introscope Agent from the extensions 
# directory. You must restart the managed application before
# changes to this property take effect.

introscope.agent.extensions.bundles.directory=../../extensions

# Extensions deployment has three modes: controlled, dynamic, and off.
# In dynamic mode extensions can be added/removed from the agent's
# extensions/deploy directory without requiring an agent restart.
#
# In controlled mode, adding or removing extensions requires 
# an agent restart and the agent will only load extensions 
# from the extensions/deploy directory during the agent startup.
#
# In off mode, extensions deployment is disabled and no extensions
# will be loaded from the extensions\deploy directory of the agent.

# You must restart the managed application before
# changes to this property take effect.

introscope.agent.extensions.bundles.mode=dynamic

#######################
# Agent Common Directory
#
# ================
# This property specifies the location of common directory to be loaded
# by the Introscope Agent.  Non-absolute names are resolved relative 
# to the location of this properties file.
# You must restart the collector agent before changes to this property take effect.

introscope.agent.common.directory=../../common 

#######################
# SQL Agent Configuration
#
# You must restart the collector agent before changes to these properties take effect.
# Configuration settings for Introscope SQL Agent
# ================

# Turns off metrics for individual SQL statements. The default value is false.
#introscope.agent.sqlagent.sql.turnoffmetrics=false

# Report only Average Response Time metric for individual SQL statements. The default value is false.
#introscope.agent.sqlagent.sql.artonly=false

# Turn off transaction tracing for individual sql statements. The default value is false.
#introscope.agent.sqlagent.sql.turnofftrace=false

# Unnormalized sql will appear as parameter for Sql components in Transaction Trace 
# Caution: enabling this property may result in passwords and sensitive information to be presented in Transaction Trace
# The default value is false.
#introscope.agent.sqlagent.sql.rawsql=false

######################################
# SQL Agent Normalizer extension
#
# ================
# Configuration settings for SQL Agent normalizer extension


# Specifies the name of the sql normalizer extension that will be used 
# to override the preconfigured normalization scheme. To make custom 
# normalization extension work, the value of its manifest attribute 
# com-wily-Extension-Plugin-{pluginName}-Name should match with the 
# value given to this property. If you specify a comma separated list 
# of names, only the first name will be used. Example, 
# introscope.agent.sqlagent.normalizer.extension=ext1, ext2
# Only ext1 will be used for normalization. By default we now ship the  
# RegexSqlNormalizer extension
# Changes to this property take effect immediately and do not 
# require the collector agent to be restarted.

#introscope.agent.sqlagent.normalizer.extension=RegexSqlNormalizer

##############################
# RegexSqlNormalizer extension
#
# ==================
# The following properties pertain to RegexSqlNormalizer which 
# uses regex patterns and replace formats to normalize the sql in 
# a user defined way. 


# This property if set to true will make sql strings to be
# evaluated against all the regex key groups. The implementation
# is chained. Hence, if the sql matches multiple key groups, the
# normalized sql output from group1 is fed as input to group2 and 
# so on. If the property is set to 'false', as soon as a key group  
# matches, the normalized sql output from that group is returned
# Changes to this property take effect immediately and do not require 
# the collector agent to be restarted.
# Default value is 'false'
#introscope.agent.sqlagent.normalizer.regex.matchFallThrough=true

# This property specifies the regex group keys. They are evaluated in order
# Changes to this property take effect immediately and do not 
# require the collector agent to be restarted.
#introscope.agent.sqlagent.normalizer.regex.keys=key1

# This property specifies the regex pattern that will be used
# to match against the sql. All valid regex alowed by java.util.Regex
# package can be used here.
# Changes to this property take effect immediately and do not 
# require the collector agent to be restarted.
# eg: (\\b[0-9,.]+\\b) will filter all number values, ('.*?') will filter
# anything between single quotes, ((?i)\\bTRUE\\b|\\bFALSE\\b) will filter
# boolean values from the query.
#introscope.agent.sqlagent.normalizer.regex.key1.pattern=(".*?")|('.*?')|(\\b[0-9,.]+\\b)|((?i)\\bTRUE\\b|\\bFALSE\\b)

# This property if set to 'false' will replace the first occurrence of the
# matching pattern in the sql with the replacement string. If set to 'true'
# it will replace all occurrences of the matching pattern in the sql with
# replacement string
# Changes to this property take effect immediately and do not 
# require the collector agent to be restarted.
# Default value is 'false'
#introscope.agent.sqlagent.normalizer.regex.key1.replaceAll=true

# This property specifies the replacement string format. All valid 
# regex allowed by java.util.Regex package java.util.regex.Matcher class
# can be used here.
# eg: The default normalizer replaces the values with a question mark (?)
# Changes to this property take effect immediately and do not 
# require the collector agent to be restarted.
#introscope.agent.sqlagent.normalizer.regex.key1.replaceFormat=?

# This property specifies whether the pattern match is sensitive to case
# Changes to this property take effect immediately and do not 
# require the collector agent to be restarted.
#introscope.agent.sqlagent.normalizer.regex.key1.caseSensitive=false



#######################
# Agent Metric Clamp Configuration
#
# ================
# The following setting configures the Agent to approximately clamp the number of metrics sent to the EM  
# If the number of metrics pass this metric clamp value then no new metrics will be created.  Old metrics will still report values.
# The value must be equal to or larger than 1000 to take effect. Lower value will be rejected.
# The default value is 50000. 
# You must restart the collector agent before changes to this property take effect.
#introscope.agent.metricClamp=50000


#######################
# Transaction Tracer Configuration
#
# ================
# Configuration settings for Introscope Transaction Tracer

# Uncomment the following property to specify the maximum number of components allowed in a Transaction 
# Trace.  By default, the clamp is set at 5000.   
# Note that any Transaction Trace exceeding the clamp will be discarded at the agent, 
# and a warning message will be logged in the Agent log file.
# Warning: If this clamp size is increased, the requirement on the memory will be higher and
# as such, the max heap size for the JVM may need to be adjusted accordingly, or else the 
# collector agent may run out of memory.
# Changes to this property take effect immediately and do not require the managed 
# application to be restarted.
#introscope.agent.transactiontrace.componentCountClamp=5000

# Uncomment the following property to specify the maximum depth of components allowed in
# head filtering, which is the process of examining the start of a transaction for
# the purpose of potentially collecting the entire transaction.  Head filtering will
# check until the first blamed component exits, which can be a problem on very deep
# call stacks when no clamping is done.  The clamp value will limit the memory and
# CPU utilization impact of this behavior by forcing the agent to only look up to a
# fixed depth.  By default, the clamp is set at 30.   
# Note that any Transaction Trace whose depth exceeds the clamp will no longer be examined
# for possible collection UNLESS some other mechanism, such as sampling or user-initiated
# transaction tracing, is active to select the transaction for collection.
# Warning: If this clamp size is increased, the requirement on the memory will be higher and
# as such, garbage collection behavior may be affected, which will have an application-wide
# performance impact.
# Changes to this property take effect immediately and do not require the collector agent to be restarted.
#introscope.agent.transactiontrace.headFilterClamp=30

# Uncomment the following property to disable Transaction Tracer Sampling
# Changes to this property take effect immediately and do not require the collector agent to be restarted.
#introscope.agent.transactiontracer.sampling.enabled=false

# The following property limits the number of transactions that are reported by the agent 
# per reporting cycle. The default value if the property is not set is 50.
# You must restart the collector agent before changes to this property take effect.
introscope.agent.ttClamp=50


########################
# TT Sampling
# ================
# These are normally configured in the EM. Configuring in the Agent disables configuring
# them in the EM
# You must restart the collector agent before changes to this property take effect.
#
#introscope.agent.transactiontracer.sampling.perinterval.count=1
#introscope.agent.transactiontracer.sampling.interval.seconds=120

#############################
#	Application Naming
# ===========================
# This property allows to configure a Custom Application name for all the applications
# connected to this agent.  Change to this property takes effect immediately and does not
# require the managed application to be restarted.
# This property is not configured by default. 
#
#introscope.agent.application.name=Default

#######################
# URL Grouping Configuration
#
# ================
# Configuration settings for Frontend naming.  By default, frontends
# go into the group with two segments after url port 
# For example, frontend with a url http://localhost:80/abc/def/index.jsp goes to /abc/def/,
# until the number of url groups created across all apps reach a value defined in the property 
# "introscope.agent.urlgroup.frontend.url.clamp" below.
# After the clamp is reached, all frontends go into the "Default" group.
# To get customized metrics out of the Frontends|Apps|URLs tree, set up URL groups that
# are relevant to the deployment
# Changes to this property take effect immediately and do not require the collector agent to be restarted.
introscope.agent.urlgroup.keys=default
introscope.agent.urlgroup.group.default.pathprefix=*
introscope.agent.urlgroup.group.default.format={path_delimited:/:0:5}
introscope.agent.urlgroup.frontend.url.clamp=5

# Frontends containing the resources listed below would go into a URL group called "Resources" by default.  
# This is done so that invalid URLs (i.e.those that would generate a 404 error) and  Resource URLs do not 
# create unique, one-time metrics -- this can bloat the EM's memory. 
introscope.agent.urlgroup.frontend.url.resources.list=tif,tiff,jpg,jpeg,gif,png,bmp,bmpf,ico,cur,xbm,svg,img,css,woff,nil,js

# Configuration settings for Backend URL Path naming.  By default, frontends
# go into the group with two segments after url port , until the number of url
# groups created across all apps reach a value defined in the property 
# "introscope.agent.urlgroup.backend.url.clamp" below. This is hot property.
# After the clamp is reached, all backend urls go into the "Default" group.
# It is applicable for metric path Backends|WebService at {protocol}_//{host}_{port}|Paths tree.

introscope.agent.backendpathgroup.keys=default
introscope.agent.backendpathgroup.group.default.pathprefix=*
introscope.agent.backendpathgroup.group.default.format={path_delimited:/:0:5}
introscope.agent.urlgroup.backend.url.clamp=5

#######################
# Error Detector Configuration
#
# ================
# Configuration settings for Error Detector

# Please include errors.pbd in your pbl (or in introscope.autoprobe.directivesFile)

# The error snapshot feature captures transaction details about serious errors
# and enables recording of error count metrics.
# Changes to this property take effect immediately and do not require the collector agent to be restarted.
introscope.agent.errorsnapshots.enable=true

# The following series of properties lets you specify error messages 
# to ignore. For errors with messages matching these filters,
# error snapshots and error metrics will not be generated or sent.  
# You may specify as many as you like (using .0, .1, .2 ...). You may use wildcards (*).  
# The following are examples only.
# Changes to this property take effect immediately and do not require the managed application to be restarted.
#introscope.agent.errorsnapshots.ignore.0=*com.company.HarmlessException*
#introscope.agent.errorsnapshots.ignore.1=*HTTP Error Code: 404*

# The following setting configures the maximum number of error snapshots
# that the Agent can send in a 15-second period.
# Changes to this property take effect immediately and do not require the collector agent to be restarted.
introscope.agent.errorsnapshots.throttle=10

# Minimum threshold for stall event duration
# Changes to this property take effect immediately and do not require the collector agent to be restarted.
introscope.agent.stalls.thresholdseconds=30

# Frequency that the agent checks for stall events
# Changes to this property take effect immediately and do not require the collector agent to be restarted.
introscope.agent.stalls.resolutionseconds=10

#######################
# Dynamic Instrumentation Settings 
# ================================= 
# This feature enables changes to PBDs to take effect without restarting the application server or the agent process.  
# This is a very CPU intensive operation, and it is highly recommended to use configuration to minimize the classes that are 
# being redefined.PBD editing is all that is required to trigger this process. 
  
# Enable/disable the dynamic instrumentation feature. 
# You must restart the collector agent before changes to this property take effect.
#introscope.autoprobe.dynamicinstrument.enabled=true 
 
# The polling interval in minutes to poll for PBD changes 
# You must restart the collector agent before changes to this property take effect.
#introscope.autoprobe.dynamicinstrument.pollIntervalMinutes=1 
    
################################
# Agent Metric Aging
# ==============================
# Detects metrics that are not being updated consistently with new data and removes these metrics.
# By removing these metrics you can avoid metric explosion.    
# Metrics that are in a group will be removed only if all metrics under this group are considered candidates for removal.
# BlamePointTracer metrics are considered a group.  
#
# Enable/disable the metric agent aging feature. 
# Changes to this property take effect immediately and do not require the collector agent to be restarted.
introscope.agent.metricAging.turnOn=true
#
# You can choose to ignore metrics from removal by adding the metric name or metric filter to the list below.  
# Changes to this property take effect immediately and do not require the collector agent to be restarted.
introscope.agent.metricAging.metricExclude.ignore.0=Threads*

# To ignore ChangeDetector.AgentID  metric from metric aging.
introscope.agent.metricAging.metricExclude.ignore.1=ChangeDetector.AgentID

#######################
# Garbage collection and Memory Monitoring 
#
# ================
# Enable/disable Garbage Collection monitor
# Changes to following property take effect immediately and do not require the collector agent to be restarted.

introscope.agent.gcmonitor.enable=true

######################################################
# Thread Dump Collection
######################################################

# Enable/disable Thread Dump Feature support.
introscope.agent.threaddump.enable=true

# Configure the maximum stack elements the Thread dump can have,
# If the user configures the max stack elements beyond 25000,
# The property is reset to the default value of 12000

introscope.agent.threaddump.MaxStackElements=12000

# Enable/disable DeadLock poller Metric support.
introscope.agent.threaddump.deadlockpoller.enable=false

# The property determines the interval in which the Agent queries for any deadlock in the system.
introscope.agent.threaddump.deadlockpollerinterval=15000

#######################
#  Transaction Structure aging properties
#
# ================
# This property is to evaluate the number of elements in the transaction structure at the period interval,
# to determine if "emergency aging" is required.
# Default value is "30000"
# com.wily.introscope.agent.harvesting.transaction.creation.checkperiod=30000       

# This property specifies the period in milliseconds that the aging for the transaction structure is checked, 
# Default value is "30000"
# com.wily.introscope.agent.harvesting.transaction.aging.checkperiod=30000
 
# This property specifies the minimum amount in milliseconds that a tree in the transaction structure must be inactive before it is purged.
# The inactivity does not imply that it will be aged out.
# Default value is "60000"
# com.wily.introscope.agent.harvesting.transaction.aging.period=60000 
             
# This property sets the maximum percentage increment in the size of the structure that is allowed to happen before aging of the transaction structure is forced
# If the change in the number of nodes between the aging periods is more than this percentage value, then checking for aging occurs
# if set to a small value, the transaction structure will be aged more frequently, and the memory utilization of the agent will be therefore 
# kept lower.
# Default value is "5", i.e. 5%
# com.wily.introscope.agent.harvesting.transaction.aging.attentionlevel.percentage=5        
 
# This property sets the maximum absolute increment in the size of the structure that is allowed to happen before aging of the transaction structure is forced
# If the change in the number of nodes between the aging periods is more than this percentage value, then checking for aging occurs
# if set to a small value, the transaction structure will be aged more frequently, and the memory utilization of the agent will be therefore 
# kept lower.
# Default value is "100000"
# com.wily.introscope.agent.harvesting.transaction.attentionlevel.absolute=100000

# This property is used to avoid spikes in memory utilization of the transaction structure.
# If there is an increase of elements at any time bigger than a third of this value,
# then "emergency aging" occurs immediately. Emergency aging will agent parts of the transaction structures that are younger than the 
# value specified in com.wily.introscope.agent.harvesting.transaction.aging.period,  and will likely reduce the amount of data sent by the agent.
# Only modify this value if the memory requirement are very strict. 
# Default value is "100000"
# com.wily.introscope.agent.harvesting.transaction.creation.attentionlevel.absolute=100000

# This property specifies the maximum duration in milliseconds of the aging process. It is used to avoid long aging process when 
# resources available are not sufficient. 
# default value if 30000
# com.wily.introscope.agent.harvesting.transaction.aging.duration.max=30000
 
#######################
#  Transaction Structure properties
#
# ================
# Enable/disable to shut down globally the transaction trace feature.
# Default value is "true"
# com.wily.introscope.agent.blame.transaction.doTransactionTrace=true

# Enable/disable high concurrency mode for all repositories.
# Set to true, it will use more memory but may give more throughput
# Default value is "false"
# com.wily.introscope.agent.blame.highconcurrency.enabled=false

# This property defines the number of stripes in the striped repositories
# It works when the high concurrency mode is on,
# which is "com.wily.introscope.agent.blame.highconcurrency.enabled=true"
# Default value is "16"
# com.wily.introscope.agent.blame.highconcurrency.stripes=16

# Enable/disable to removes stalls from all traces, and remove stall feature altogether.
# Default value is "true"
# com.wily.introscope.agent.blame.stall.trace.enabled=true

# Enable synchronized repositories instead of compare and swap repositories
# The synchronized repository is not used in java5 because of overhead in locking.
# the default value is true in java 6 and above, and false for java 5. In java 5, setting to false will cause overhead
# com.wily.introscope.agent.blame.synchronized.enabled=true

 
#######################
# Properties to activate sustainability metrics
#
# ================
# Sustainability metrics are generated to provide information on the agent health and
# internal status. There is a substantial overhead associated with these metrics, and therefore, their
# usage is not suggested at this time in production environments.
#
# Enable/disable to generate globally sustainability debug metrics.
# Set to true, it will generate globally sustainability debug metrics that can be used to evaluate the Transaction Structure
# Default value is "false"
# com.wily.introscope.agent.blame.transactions.debugmetrics.enabled=false           

# Enable/disable to generate sustainability metrics on the harvesting process.
# Default value is "false"
# com.wily.introscope.agent.harvesting.debugmetrics.enabled=false

# This property is to generate the metrics for the health of the data structures in the agent.
# Default value is "false"
# concurrentMapPolicy.generatemetrics=false   

#com.wily.introscope.agent.sustainabilitymetrics.enabled=true
#com.wily.introscope.agent.sustainabilitymetrics.metrics.enabled=true
#com.wily.introscope.agent.sustainabilitymetrics.report.enabled=true
#com.wily.introscope.agent.sustainabilitymetrics.report.frequency

# Enable/disable to generate collector agent java metrics
# Default value is "true"
#introscope.agent.environment.java.metrics.enabled=false

##############################################
# Smart Instrumentation properties
#
##############################################
#
#-------------------------------------
# Note: The following describes the functional behaviour on combination of the two properties 
# introscope.agent.deep.instrumentation.enabled and introscope.agent.deep.trace.enabled
#
# 1. The introscope.agent.deep.instrumentation.enabled property must be enabled
#    for the introscope.agent.deep.trace.enabled property to function.
#
# 2. When introscope.agent.deep.instrumentation.enabled=true and introscope.agent.deep.trace.enabled=true,
#    the agent automatically instruments deep transaction trace components and collects deep transaction traces.
#
# 3. When introscope.agent.deep.instrumentation.enabled=true and introscope.agent.deep.trace.enabled=false,
#    the agent automatically instruments deep transaction trace components.
#    However no deep transaction trace component data is sent to the Enterprise Manager or displayed.
#--------------------------------------
#
# Enables and disables deep transaction trace visibility.
# Enables and disables the agent ability to automatically instrument transaction trace components
# without PBD configuration to provide deep transaction trace visibility.
# The default value is true.
# You must restart the managed application before changes to this property take effect
introscope.agent.deep.instrumentation.enabled=true

# Enables and disables the agent ability to collect deep transaction traces
# and send the data to the Enterprise Manager.
# The default value is true.
# Change to this property takes effect immediately and does not require the 
# managed application to be restarted.
introscope.agent.deep.trace.enabled=true

# This property enables and disables deep component visibility into error snapshots
# Change to this property takes effect immediately and do not require the 
# collector agent to be restarted.
introscope.agent.deep.errorsnapshot.enable=true

# This property limits the maximum number of deep trace components in a Transaction Trace
# Change to this property takes effect immediately and does not require the 
# managed application to be restarted.
introscope.agent.deep.trace.max.components=1000

# This property limits the maximum number of consecutive deep trace components in a Transaction Trace
# Change to this property takes effect immediately and does not require the 
# managed application to be restarted.
introscope.agent.deep.trace.max.consecutive.components=15

introscope.agent.deep.automatic.trace.crossprocess.enabled=false
