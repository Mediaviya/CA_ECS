#!/bin/bash
# description: CA APM Infrastructure Agent
# Edited on - 6-Dec-2017
########################################################################
#
# 	Version: 1.0
#   Copyright (c) 2011 CA. All rights reserved.
#
#   This software and all information contained therein is confidential and
#   proprietary and shall not be duplicated, used, disclosed or disseminated
#   in any way except as authorized by the applicable license agreement,
#   without the express written permission of CA. All authorized
#   reproductions must be marked with this language.
#
#   EXCEPT AS SET FORTH IN THE APPLICABLE LICENSE AGREEMENT, TO THE
#   EXTENT PERMITTED BY APPLICABLE LAW, CA PROVIDES THIS SOFTWARE
#   WITHOUT WARRANTY OF ANY KIND, INCLUDING WITHOUT LIMITATION, ANY
#   IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
#   PURPOSE. IN NO EVENT WILL CA BE LIABLE TO THE END USER OR ANY
#   THIRD PARTY FOR ANY LOSS OR DAMAGE, DIRECT OR INDIRECT, FROM THE
#   USE OF THIS SOFTWARE, INCLUDING WITHOUT LIMITATION, LOST PROFITS,
#   BUSINESS INTERRUPTION, GOODWILL, OR LOST DATA, EVEN IF CA IS EXPRESSLY
#   ADVISED OF SUCH LOSS OR DAMAGE.
#
########################################################################
#
# apmia-ca-installer.sh
# Master script for installing CA Host Monitoring Agent and  CA APM Infrastructure Agent
# Usage:
# apmia-ca-installer.sh install
# apmia-ca-installer.sh uninstall
# apmia-ca-installer.sh clean_uninstall
# apmia-ca-installer.sh status
# apmia-ca-installer.sh start
# apmia-ca-installer.sh stop
# apmia-ca-installer.sh restart
# apmia-ca-installer.sh force_start
# apmia-ca-installer.sh -help
#
# Run "apmia-ca-installer.sh help" for usage info
# Set the home directory if it is unset.
# Different OS require different test statements


ERROR=0

SCRIPTNAME="${BASH_SOURCE[0]}"

# The time and date for the logs
timeAndDate=`date`

# Variable to check directory of host monitor
dir_HostMonitor=0

# Variable to check port number
port_se=1691

# Variable to check installation mode 
withHostMonitor=0

# Variable for input arguments
arg_1_usage=$1
arg_2_usage=$2

# Variable for clean uninstall
clean_del=0

#Variable for install hostmonitor on start and restart
install_hostmonitor=0

CURRENT_DIR=`pwd | sed 's/[[:space:]]/\\\ /g'`

# Set directories variables
if ! [ "$APMIA_HOME" ] ; then
	APMIA_HOME="$( cd "$( dirname "$SCRIPTNAME" )" && pwd )";
	APMIA_HOME=`echo "$APMIA_HOME" | sed 's/[[:space:]]/\\\ /g'`
	eval cd $APMIA_HOME
	HOSTMONITOR_HOME=CA_SystemEDGE_Core
	UNIFIEDAGENT_HOME=bin
fi

# Setting Log for APMIA
if [ "$arg_2_usage" = "console" ]; then
	LOGCONSOLE=1
	SCRIPT_LOG="| tee -a $APMIA_HOME/APMIA_install.log"
else
	SCRIPT_LOG=">> $APMIA_HOME/APMIA_install.log"
	LOGCONSOLE=0
fi

# Set AGENTHOME to home
export AGENTHOME=$APMIA_HOME

############################Functions starts here############################

#This Fuction logs everthing here
function logMyAPMIA()
{
        eval "echo ********************`date` [INFO]********************* $SCRIPT_LOG"	
        eval "echo $timeAndDate [INFO] Current Shell: $SHELL $SCRIPT_LOG"
        eval "echo $timeAndDate [INFO] Home Directory: $HOME $SCRIPT_LOG"
        eval "echo $timeAndDate [INFO] Your O/s Type: $OSTYPE $SCRIPT_LOG"
        eval "echo $timeAndDate [INFO] PATH: $PATH $SCRIPT_LOG"
        eval "echo $timeAndDate [INFO] Current directory: `pwd` $SCRIPT_LOG"
}

function EXIT()
{
	eval cd "$CURRENT_DIR"
	exit $1
}

function extractDIR()
{
	checkInstallDir
	if [ "$dir_HostMonitor" == "0" ]; then
		eval "echo $timeAndDate [INFO] Extracting tar files $SCRIPT_LOG"
		tar -xf casystemedge*.tar.gz
	fi
}

#Check cron entry for start, uninstall, clean_uninstall and restart
function checkCronEntry()
{
	crontab -l > cronfile 2>/dev/null
	OUTPUTSTR=`grep -F "$APMIA_HOME/apmia-ca-installer.sh start" cronfile`
	CMDSTATUS=$?
	if [ "$CMDSTATUS" -eq 0 ]; then
		rm -f cronfile
    	return 1
	fi
	
	OUTPUTSTR=`grep -F "$APMIA_HOME//apmia-ca-installer.sh start" cronfile`
	CMDSTATUS=$?
	rm -f cronfile
	if [ "$CMDSTATUS" -eq 0 ]; then
		return 1
	fi
	eval "echo $timeAndDate [ERROR] Entry in crontab is not found. $SCRIPT_LOG"
	eval "echo $timeAndDate [ERROR] APMIA is not installed/corrupt installation is present. $SCRIPT_LOG"
	echo "APMIA is not installed/corrupt installation is present/APMIA is started using force_start ."
	EXIT 1 
}

function checkInstallDir()
{
	eval cd "$APMIA_HOME"
	if [ -d "SystemEDGE" ]; then
		dir_HostMonitor=1
	else
		dir_HostMonitor=0
	fi
}

#This function shall check if Port is available reurn 1 when available else return 0
function checkPortStatus()
{
	status=0

	# Lets check 1691 port
	if ! netstat -an | grep -E "^udp[      ]+[0-9]+[       ]+[0-9]+[       ]+[0-9a-f\.:\*]+:1691[         ]+">/dev/null
	then
		eval "echo $timeAndDate [INFO] 1691 port is free $SCRIPT_LOG"
		status=1
		port_se=1691
		return $status
	else
		eval "echo $timeAndDate [INFO] 1691 port is not free, lets check port 1791 $SCRIPT_LOG"
		status=0
	fi

	# Lets check 1791 port
    if ! netstat -an | grep -E "^udp[      ]+[0-9]+[       ]+[0-9]+[       ]+[0-9a-f\.:\*]+:1791[         ]+">/dev/null
	then
		eval "echo $timeAndDate [INFO] 1791 port is free $SCRIPT_LOG"
		status=1
		port_se=1791
		return $status
	else
		echo -e "1691 and 1791 ports are not free, Cannot install Host Monitoring Agent"
		eval "echo $timeAndDate [INFO] 1691 and 1791 ports are not free, Cannot install Host Monitoring Agent $SCRIPT_LOG"
		status=0
		return $status
	fi
	
}

function checkInstallMode()
{
	eval cd "$APMIA_HOME"
	if [ -f "casystemedge-5.9.8-unix-x64.tar.gz" ]; then
		if [ -d "extensions/HostMonitor" ]; then
			OUTPUTSTR=`grep -E '^['$'\t'' ]*introscope.agent.extensions.bundles.load=' extensions/Extensions.profile | grep -F HostMonitor`
			CMDSTATUS=$?
			if [ "$CMDSTATUS" -eq 0 ]; then
				withHostMonitor=1
				eval "echo $timeAndDate [INFO] APM Infrastructure Agent installation mode is with Host Monitoring Agent. $SCRIPT_LOG"
				eval cd "$APMIA_HOME"
				return $withHostMonitor
			else
				withHostMonitor=0
				eval "echo $timeAndDate [INFO] APM Infrastructure Agent installation mode is without Host Monitoring Agent. $SCRIPT_LOG"
				eval "echo $timeAndDate [INFO] User did not loaded HostMonitor in Extensions.profile $SCRIPT_LOG"
				eval cd "$APMIA_HOME"
				return $withHostMonitor
			fi
		else
			if [ -f "extensions/deploy/HostMonitor.tar.gz" ]; then
				withHostMonitor=1	 
				eval "echo $timeAndDate [INFO] APM Infrastructure Agent installation mode is with Host Monitoring Agent. $SCRIPT_LOG"
			else
				withHostMonitor=0
				eval "echo $timeAndDate [INFO] APM Infrastructure Agent installation mode is without Host Monitoring Agent. $SCRIPT_LOG"
				eval "echo $timeAndDate [INFO] HostMonitor extension tar file is not found in deploy folder. $SCRIPT_LOG"
			fi
		fi
	else	
		withHostMonitor=0
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent installation mode is without Host Monitoring Agent. $SCRIPT_LOG"
		eval "echo $timeAndDate [INFO] Host Monitor tar file is not found for installation. $SCRIPT_LOG"
	fi
}

function check_hostmonitor_mode()
{
	checkInstallMode
	if [ "$withHostMonitor" == "1" ]; then
		checkInstallDir
		if [ "$dir_HostMonitor" == "1" ]; then
			install_hostmonitor=0
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent Host Monitor found installed. $SCRIPT_LOG"
		fi
	fi
	
	if [ "$withHostMonitor" == "1" ]; then
		checkInstallDir
		if [ "$dir_HostMonitor" == "0" ]; then
			install_hostmonitor=1
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent Host Monitor to be install. $SCRIPT_LOG"
		fi
	fi
	
	if [ "$withHostMonitor" == "0" ]; then
		checkInstallDir
		if [ "$dir_HostMonitor" == "0" ]; then
			install_hostmonitor=0
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent is without Host Monitor. $SCRIPT_LOG"
		fi
	fi
	
	if [ "$withHostMonitor" == "0" ]; then
		checkInstallDir
		if [ "$dir_HostMonitor" == "1" ]; then
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent Host Monitor to be uninstall. $SCRIPT_LOG"
			uninstallSE
		fi
	fi
	
	if [ "$install_hostmonitor" == "1" ]; then
		installSE
	fi
}

function set_bundleProperties()
{
	if [ "$1" == "1791" ] ; then
		checkInstallDir
		if [ "$dir_HostMonitor" == "1" ]; then
			echo -e "Please Update port number in bundle properties of HostMonitor extension as Host Monitoring agent installed on port $1 and RESTART the APMIA "
			eval "echo $timeAndDate [INFO] Please Update port number in bundle properties of HostMonitor extension as Host Monitoring agent installed on port $1 and RESTART the APMIA $SCRIPT_LOG"
		fi
	fi
	eval cd "$APMIA_HOME"
	if [ -f extensions/HostMonitor/bundle.properties ]; then
        	tr -d '\r' < extensions/HostMonitor/bundle.properties >  output.txt
        	mv -f output.txt extensions/HostMonitor/bundle.properties	
	fi
}
function set_IntroscopeAgentprofile()
{
	eval cd "$APMIA_HOME"
	LOGTYPE=`grep -E '^['$'\t'' ]*log4j.logger.IntroscopeAgent=' core/config/IntroscopeAgent.profile|cut -d'=' -f2|cut -d',' -f1`
    if [ $LOGCONSOLE == 1 ]; then
		eval "echo $timeAndDate [INFO] Updating log4j in IntroscopeAgent.profile with console $SCRIPT_LOG"
		`sed -ie "s/^log4j.logger.IntroscopeAgent=.*/log4j.logger.IntroscopeAgent=$LOGTYPE, console, logfile/" core/config/IntroscopeAgent.profile`
		rm -rf core/config/IntroscopeAgent.profilee
	else
		eval "echo $timeAndDate [INFO] Updating log4j in IntroscopeAgent.profile with logfile $SCRIPT_LOG"
		`sed -ie "s/^log4j.logger.IntroscopeAgent=.*/log4j.logger.IntroscopeAgent=$LOGTYPE, logfile/" core/config/IntroscopeAgent.profile`
		rm -rf core/config/IntroscopeAgent.profilee
	fi
        tr -d '\r' < core/config/IntroscopeAgent.profile >  output.txt
        mv -f output.txt core/config/IntroscopeAgent.profile

	cd - >/dev/null
}

#display help for this script
function displayhelp()
{
	echo -e "Usage: <apmia-ca-installer.sh> {install|uninstall|clean_uninstall|start|stop|status|restart|force_start|-help}" >&2
}

function installSE()
{
	checkInstallDir
	if [ "$dir_HostMonitor" == "1" ]; then
		eval "echo $timeAndDate [INFO] Host Monitor Agent folder present. $SCRIPT_LOG"
		eval "echo $timeAndDate [INFO] Removing Host Monitor Agent folder. $SCRIPT_LOG"
		rm -rf SystemEDGE
	fi
	
	OUTPUTSTR1=`ps -ef | grep "$APMIA_HOME/SystemEDGE" |grep -v grep` 
	CMDSTATUS1=$?
	if [ "$CMDSTATUS1" -eq 0 ]; then
		OUTPUTSTR1=`ps -ef | grep "$APMIA_HOME/SystemEDGE" |grep -v grep | awk '{print $2}'`
		eval "echo $timeAndDate [INFO] Removing Host Monitor Agent service. $SCRIPT_LOG"
		`kill -9 $OUTPUTSTR1`
	fi
		
	checkPortStatus
	if [ "$status" == "1" ]; then
		eval cd "$APMIA_HOME"
		extractDIR
		eval "echo $timeAndDate [INFO] Calling installer to install sysedge $SCRIPT_LOG"
		eval cd "$HOSTMONITOR_HOME"
		eval "echo $timeAndDate [INFO] Setting HOSTMONITOR_HOME to $HOSTMONITOR_HOME $SCRIPT_LOG"
	
		echo -e "Installing Host Monitoring Agent on PORT $port_se"
		eval "echo $timeAndDate [INFO] ./ca-setup.sh install -p $port_se $SCRIPT_LOG"
		eval "./ca-setup.sh install -p $port_se $SCRIPT_LOG"
		checkSEinst=$?
		if [ ! "$checkSEinst" == "0" ] ; then
			echo -e "Host Monitoring Agent Installation is Completed with Exit Status as $checkSEinst. If exit status is non zero please check APMIA_install.log"
		fi
		eval "echo $timeAndDate [INFO] Host Monitoring Agent Installation is Completed with Exit Status as $checkSEinst. If exit status is non zero please check SystemEDGE/sysedge_install.log and APMIA_install.log $SCRIPT_LOG"
		eval cd "$APMIA_HOME"
	fi
}

function installAPMIA()
{
	#check for supported platform
	THIS_OS=`uname -a | awk '{print $1}'`
	case "$THIS_OS" in 
	'Linux')
	;;
	'Darwin')
	;;
	*)
		eval "echo $timeAndDate [ERROR] Unsupported platform $SCRIPT_LOG"
		echo "Unsupported platform"
		EXIT 1
	;;
	esac

	#check if APMIA is installed for user
	crontab -l > cronfile 2>/dev/null
	OUTPUTSTR=`grep "apmia-ca-installer.sh start" cronfile`
	CMDSTATUS=$?
	if [ "$CMDSTATUS" -eq 0 ]; then
	    OUTPUTSTR=`grep "apmia-ca-installer.sh start" cronfile|sed 's/apmia-ca-installer.sh start//'|sed 's/@reboot //'`
	    eval "echo $timeAndDate [ERROR] Entry in crontab is found. $SCRIPT_LOG"
	    eval "echo $timeAndDate [ERROR] APMIA is already installed/corrupt installation is present at location $OUTPUTSTR $SCRIPT_LOG"
		echo "APMIA is already installed/corrupt installation is present at location $OUTPUTSTR"
	    rm -f cronfile
		EXIT 1
	fi
	rm -f cronfile

	#check if APMIA is installed for user
	OUTPUTSTR=`ps ax -o command | grep "UnifiedMonitoringAgent.jar"|grep -v grep`
	CMDSTATUS=$?
	if [ "$CMDSTATUS" -eq 0 ]; then
		#check if APMIA is installed for same user
		killInstall=0
		filename=jre.txt
		ps axo ruser=WIDE-RUSER-COLUMN,command | grep -v grep | grep UnifiedMonitoringAgent.jar > $filename
		CURRENTUSER=`whoami`
		while read p; do 
		USERNAME=`echo $p | grep UnifiedMonitoringAgent.jar | awk '{ print $1 }'`
		OUTPUTSTR=`echo $p|awk -F' /' '{print $2F}'|sed 's/jre\/bin\/java*/>/'|cut -d'>' -f1`
		if [ $USERNAME == $CURRENTUSER ]; then
			eval "echo $timeAndDate [ERROR] APMIA is running using FORCE_START option at location '/$OUTPUTSTR'. Please stop/kill to proceed. $SCRIPT_LOG"
			echo "APMIA is running using FORCE_START option at location '/$OUTPUTSTR'. Please stop/kill to proceed."
			killInstall=1
		else
			eval "echo $timeAndDate [WARNING] APMIA is already running at location '/$OUTPUTSTR' $SCRIPT_LOG"
		fi
		done < $filename
		rm -rf $filename
		if [ $killInstall == 1 ]; then
			EXIT 1
		fi
	fi

	eval "echo $timeAndDate [INFO] APM Infrastructure Agent home $APMIA_HOME $SCRIPT_LOG"
	echo -e "APM Infrastructure Agent Installation In Progress..."
	eval "echo $timeAndDate [INFO] APM Infrastructure Agent Installation In Progress... $SCRIPT_LOG"
	
	checkInstallMode
	if [ "$withHostMonitor" == 1 ]; then
		installSE
	fi
	eval cd "$APMIA_HOME"
	eval cd "$UNIFIEDAGENT_HOME"
	if [ $LOGCONSOLE == 1 ]; then
		set_IntroscopeAgentprofile
		eval "./APMIAgent.sh startwithlogs"
		startStatus=$?
		if [ ! $startStatus == 0 ] ; then
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent could not be installed, Exited with status $startStatus  $SCRIPT_LOG"
			echo -e "APM Infrastructure Agent could not be installed, please check APMIA_install.log"
			if [ "$withHostMonitor" == 1 ]; then
				uninstallSE
			fi
			EXIT 1
		fi
		set_bundleProperties "$port_se"
	else
		set_IntroscopeAgentprofile
		eval "./APMIAgent.sh start $SCRIPT_LOG"
		startStatus=$?
		if [ ! $startStatus == 0 ] ; then
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent could not be installed, Exited with status $startStatus  $SCRIPT_LOG"
			echo -e "APM Infrastructure Agent could not be installed, please check APMIA_install.log"
			if [ "$withHostMonitor" == 1 ]; then
				uninstallSE
			fi
			EXIT 1
		fi
		set_bundleProperties "$port_se"
	fi
	crontab -l > cronfile1 2>/dev/null
	echo "@reboot ${APMIA_HOME}/apmia-ca-installer.sh start">> cronfile1
	crontab cronfile1
	rm -f cronfile1

	crontab -l > cronfile2 2>/dev/null
	OUTPUTSTR=`grep -F "${APMIA_HOME}/apmia-ca-installer.sh" cronfile2`
	CMDSTATUS1=$?
	if ! [ "$CMDSTATUS1" -eq 0 ]; then
		eval "echo $timeAndDate [ERROR] Entry in crontab is not created $SCRIPT_LOG"
		echo -e "Entry in crontab is not created, Installation failed"
		rm -f cronfile2
		EXIT 1
	fi
	rm -f cronfile2

	echo -e "APM Infrastructure Agent Installation Completed."
	eval "echo $timeAndDate [INFO] APM Infrastructure Agent Installation Completed. $SCRIPT_LOG"
	eval cd "$APMIA_HOME"
}

function force_start_APMIA()
{
	#check for supported platform
	THIS_OS=`uname -a | awk '{print $1}'`
	case "$THIS_OS" in 
	'Linux')
	;;
	'Darwin')
	;;
	*)
		eval "echo $timeAndDate [ERROR] Unsupported platform $SCRIPT_LOG"
		echo "Unsupported platform"
		EXIT 1
	;;
	esac
	
	#checking APMIA service running at same location
	OUTPUTSTR=`ps -ef | grep "$APMIA_HOME/lib/UnifiedMonitoringAgent.jar" |grep -v grep` 
	CMDSTATUS=$?
	if [ "$CMDSTATUS" -eq 0 ]; then
		eval "echo $timeAndDate [INFO] Removing APM Infrastructure Agent service. $SCRIPT_LOG"
		OUTPUTSTR1=`ps -ef | grep "$APMIA_HOME/lib/UnifiedMonitoringAgent.jar" |grep -v grep | awk '{print $2}'`
		`kill -9 $OUTPUTSTR1`
	fi
	checkInstallDir
	if [ "$dir_HostMonitor" == "1" ]; then
		cd "$HOSTMONITOR_HOME"
		eval "echo $timeAndDate [INFO] Uninstalling HostMonitor $SCRIPT_LOG"
		eval "echo $timeAndDate [INFO] ./ca-setup.sh uninstall $SCRIPT_LOG"
		eval "./ca-setup.sh uninstall $SCRIPT_LOG"
		eval cd "$APMIA_HOME"
		rm -rf SystemEDGE
	fi

	echo -e "APM Infrastructure Agent Force Start in Progress..."
	eval "echo $timeAndDate [INFO] APM Infrastructure Agent Force Start in Progress... $SCRIPT_LOG"
	
	eval cd "$APMIA_HOME"
	check_hostmonitor_mode
	if [ "$port_se" == "1791" ] ; then
		checkInstallDir
		if [ "$dir_HostMonitor" == "1" ]; then
			echo -e "Please Update port number in bundle properties of HostMonitor extension as port $port_se and FORCE_START again "
			echo -e "Please ignore above message if you have already updated port number. "
			eval "echo $timeAndDate [INFO] Please Update port number in bundle properties of HostMonitor extension as port $port_se and FORCE_START again $SCRIPT_LOG"
			eval "echo $timeAndDate [INFO] Please ignore above message if you have already updated port number. $SCRIPT_LOG"
		fi
	fi
	eval cd "$APMIA_HOME"
	if [ -f extensions/HostMonitor/bundle.properties ]; then
		tr -d '\r' < extensions/HostMonitor/bundle.properties >  output.txt
		mv -f output.txt extensions/HostMonitor/bundle.properties
	fi
		
	eval cd "$APMIA_HOME"
	cd "$UNIFIEDAGENT_HOME"
	if [ $LOGCONSOLE == 1 ]; then
		set_IntroscopeAgentprofile
		eval "./APMIAgent.sh startwithlogs"
		startStatus=$?
		if [ ! $startStatus == 0 ] ; then
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent could not be started, Exited with status $startStatus  $SCRIPT_LOG"
			echo -e "APM Infrastructure Agent could not be started, please check APMIA_install.log"
			if [ "$withHostMonitor" == 1 ]; then
				uninstallSE
			fi
			EXIT 1
		fi
	else
		set_IntroscopeAgentprofile
		eval "./APMIAgent.sh start $SCRIPT_LOG"
		startStatus=$?
		if [ ! $startStatus == 0 ] ; then
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent could not be started, Exited with status $startStatus  $SCRIPT_LOG"
			echo -e "APM Infrastructure Agent could not be started, please check APMIA_install.log"
			if [ "$withHostMonitor" == 1 ]; then
				uninstallSE
			fi
			EXIT 1
		fi
	fi
		
	
	echo -e "APM Infrastructure Agent Start is Completed"
	eval "echo $timeAndDate [INFO] APM Infrastructure Agent Start is Completed $SCRIPT_LOG"
	
}

function uninstall_main()
{
	checkCronEntry
	echo -e "APM Infrastructure Agent Uninstallation In Progress..."
	eval "echo $timeAndDate [INFO] APM Infrastructure Agent Uninstallation In Progress... $SCRIPT_LOG"
	uninstallSE
	uninstallAPMIA
}

function uninstallSE()
{
	checkInstallDir
	if [ "$dir_HostMonitor" == "1" ]; then
		cd "$HOSTMONITOR_HOME"
		echo -e "Uninstalling HostMonitor"
		eval "echo $timeAndDate [INFO] Uninstalling HostMonitor $SCRIPT_LOG"
		eval "echo $timeAndDate [INFO] ./ca-setup.sh uninstall $SCRIPT_LOG"
		eval "./ca-setup.sh uninstall $SCRIPT_LOG"
		eval cd "$APMIA_HOME"
		rm -rf CA_SystemEDGE_Core 
	else
		eval "echo $timeAndDate [INFO] Host Monitoring Agent is not present at $APMIA_HOME. $SCRIPT_LOG"
	fi
}

function uninstallAPMIA()
{
	eval cd "$APMIA_HOME"
	cd "$UNIFIEDAGENT_HOME"
	if [ -f "APMIAgent.pid" ]; then
		eval "./APMIAgent.sh stop $SCRIPT_LOG"
		stopStatus=$?
		if [ ! $stopStatus == 0 ] ; then
			echo -e "APM Infrastructure Agent could not be stoped"
			echo -e "APM Infrastructure Agent Uninstallation Aborted."
			eval "echo $timeAndDate [ERROR] APM Infrastructure Agent Uninstallation Aborted. $SCRIPT_LOG"
			EXIT 1
		fi
	fi
	eval cd "$APMIA_HOME"
	crontab -l > cronfile 2>/dev/null
	OUTPUTSTR=`grep -vF "${AGENTHOME}" cronfile > new_cronfile`
	OUTPUTSTR1=`grep "apmia/apmia-ca-installer.sh start" cronfile`
	CDMOUT=$?
	crontab new_cronfile
	rm -f cronfile new_cronfile 
	if [ $CDMOUT == 0 ]; then
		clean_del=1
	fi
	echo -e "APM Infrastructure Agent Uninstallation Completed."
	eval "echo $timeAndDate [INFO] APM Infrastructure Agent Uninstallation Completed. $SCRIPT_LOG"
}

function stop_APMIA()
{
	checkInstallDir
	if [ "$dir_HostMonitor" == "1" ]; then
		eval cd "$APMIA_HOME"
		cd "SystemEDGE/bin"
		./sysedgectl status >/dev/null
		if ! [ $? -eq 0 ]; then
			echo -e "Host Monitoring Agent service is not running"
			eval "echo $timeAndDate [INFO] Host Monitoring Agent service is not running $SCRIPT_LOG"
		else
			echo -e "APM Infrastructure Agent stop in progress.."
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent stop in progress.. $SCRIPT_LOG"
			eval "./sysedgectl stop $SCRIPT_LOG"
		fi
	fi
	eval cd "$APMIA_HOME"
	cd "$UNIFIEDAGENT_HOME" 
	if [ -f "APMIAgent.pid" ]; then
		eval "./APMIAgent.sh stop $SCRIPT_LOG"
		echo -e "APM Infrastructure Agent stop completed"
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent stop completed $SCRIPT_LOG"
	else
		OUTPUTSTR=`ps -ef | grep "$APMIA_HOME/lib/UnifiedMonitoringAgent.jar" |grep -v grep` 
		CMDSTATUS=$?
		if [ "$CMDSTATUS" -eq 0 ]; then
			eval "echo $timeAndDate [ERROR] APMIA corrupt installation is present at current location. $SCRIPT_LOG"
			echo "APMIA corrupt installation is present at current location."
		else
			echo -e "APM Infrastructure Agent service is not running"
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent service is not running $SCRIPT_LOG"
		fi
	fi
	eval cd "$APMIA_HOME"
}

function start_APMIA()
{
	OUTPUTSTR=`ps -ef | grep "$APMIA_HOME/lib/UnifiedMonitoringAgent.jar" |grep -v grep` 
	CMDSTATUS=$?
	if [ "$CMDSTATUS" -eq 0 ]; then
		echo -e "APM Infrastructure Agent service is already running"
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent service is already running $SCRIPT_LOG"
		EXIT 0
	fi
	
	check_hostmonitor_mode
	if [ "$install_hostmonitor" == "0" ]; then
		checkInstallDir
		if [ "$dir_HostMonitor" == "1" ]; then
			eval cd "$APMIA_HOME"
			cd "SystemEDGE/bin"
			echo -e "APM Infrastructure Agent start in progress.."
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent start in progress.. $SCRIPT_LOG"
			eval "./sysedgectl start $SCRIPT_LOG"
		fi
	fi
	
	eval cd "$APMIA_HOME"
	cd "$UNIFIEDAGENT_HOME"
	if [ $LOGCONSOLE == 1 ]; then
		set_IntroscopeAgentprofile
		eval "./APMIAgent.sh startwithlogs"
		startStatus=$?
		if [ ! $startStatus == 0 ] ; then
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent could not be started, Exited with status $startStatus  $SCRIPT_LOG"
			echo -e "APM Infrastructure Agent could not be started, please check APMIA_install.log"
		fi
	else
		set_IntroscopeAgentprofile
		eval "./APMIAgent.sh start $SCRIPT_LOG"
		startStatus=$?
		if [ ! $startStatus == 0 ] ; then
			eval "echo $timeAndDate [INFO] APM Infrastructure Agent could not be started, Exited with status $startStatus  $SCRIPT_LOG"
			echo -e "APM Infrastructure Agent could not be started, please check APMIA_install.log"
		fi
	fi
	echo -e "APM Infrastructure Agent start completed"
	eval "echo $timeAndDate [INFO] APM Infrastructure Agent start completed $SCRIPT_LOG"
	
	eval cd "$APMIA_HOME"
}

####################Main starts here################
#lets log the Basic information about the system first
logMyAPMIA

eval cd "$APMIA_HOME"

#lets start the execution based on the command arguments
case "$arg_1_usage" in 
	'install')
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent user entered install $SCRIPT_LOG"
		installAPMIA
	;;
	'uninstall') 	
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent user entered uninstall $SCRIPT_LOG"
		uninstall_main
	;;
	'clean_uninstall')
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent user entered clean_uninstall $SCRIPT_LOG"
		uninstall_main
		if [ "$clean_del" == 1 ]; then
			rm -rf * 
			EXIT 0
		else
			echo -e "Could not remove file/folders of APM IA"
			eval "echo $timeAndDate [INFO] Could not remove file/folders of APM IA $SCRIPT_LOG"
		fi
	;;
	'force_start')
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent user entered force_start $SCRIPT_LOG"
		force_start_APMIA
	;;
	'start')
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent user entered start $SCRIPT_LOG"
		checkCronEntry
		start_APMIA
	;;
	'stop')
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent user entered stop $SCRIPT_LOG"
		stop_APMIA
	;;
	'restart')
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent user entered restart $SCRIPT_LOG"
		checkCronEntry
		stop_APMIA
		start_APMIA
	;;
	'status')
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent user entered status $SCRIPT_LOG"
		checkInstallDir
		if [ "$dir_HostMonitor" == "1" ]; then
			eval cd "$APMIA_HOME"
			cd "SystemEDGE/bin"
			./sysedgectl status
			eval "echo $timeAndDate [INFO] `./sysedgectl status` $SCRIPT_LOG"
		fi
		
		eval cd "$APMIA_HOME"
		cd "$UNIFIEDAGENT_HOME"
		if [ -f "APMIAgent.pid" ]; then
			./APMIAgent.sh status
			eval "echo $timeAndDate [INFO] `./APMIAgent.sh status` $SCRIPT_LOG"
		else
			OUTPUTSTR=`pgrep -f "$APMIA_HOME/lib/UnifiedMonitoringAgent.jar"`
			CMDSTATUS=$?
			if [ "$CMDSTATUS" -eq 0 ]; then
				echo "APM Infrastructure Agent                $OUTPUTSTR  running"
				eval "echo $timeAndDate [ERROR] APM Infrastructure Agent                $OUTPUTSTR  running $SCRIPT_LOG"
				eval "echo $timeAndDate [ERROR] APMIA corrupt installation is present at current location. $SCRIPT_LOG"
				echo "APMIA corrupt installation is present at current location."
			else
				./APMIAgent.sh status
				eval "echo $timeAndDate [INFO] `./APMIAgent.sh status` $SCRIPT_LOG"
			fi
		fi
	;;
	'-help')
		eval "echo $timeAndDate [INFO] APM Infrastructure Agent user entered help $SCRIPT_LOG"
		echo -e "User Need Help"	
		displayhelp
		EXIT 0
	;;
	*)
		echo -e "Sorry, Invalid option for this Script."
		eval "echo $timeAndDate [INFO] User gave invalid option for this Script. $SCRIPT_LOG"
		displayhelp
		EXIT 1
	;;
esac
	
EXIT $ERROR
