########################################################################
#                                                                      
# Agent Optional Extensions Configuration                         
#                                                                      
# CA Wily Introscope(R) Version 10.7.0 Release 10.7.0.45
# Copyright &copy; 2018 CA. All Rights Reserved.
# Introscope(R) is a registered trademark of CA.
########################################################################


#Included Field Extensions
#
# This property specifies a list of all extensions loaded by 
# the agent from the extensions directory. Once an extension 
# has been added to the deploy directory,it will automatically
# be added to the property.
# Eg: introscope.agent.extensions.bundles.load=f5ltmExtension,HostMonitor,NodeExtension,Webserver-monitor,PhpExtension
introscope.agent.extensions.bundles.load=HostMonitor
