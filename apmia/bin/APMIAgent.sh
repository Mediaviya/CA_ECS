#! /bin/bash
# chkconfig: 2345 92 18
# description: CA APM Infrastructure Agent
# Edited 20-Sep-2017
########################################################################
#
# Version: 10.7.0.45
# Build: 990045
#                                                                      
# CA Wily Introscope(R) Version 10.7.0 Release 10.7.0.45
# Copyright &copy; 2018 CA. All Rights Reserved.
# Introscope(R) is a registered trademark of CA.
#######################################################################
#
# APMIAgent.sh
# Control script for running the CA APM Introscope Unified Monitoring Agent
# as a Unix/Linux service via an easy-to-use command line interface.
# Usage:
# APMIAgent.sh start
# APMIAgent.sh status
# APMIAgent.sh stop
# APMIAgent.sh help
# APMIAgent.sh install
# APMIAgent.sh uninstall
#
#
# With specifying memory values:
# APMIAgent.sh start 64 1024
#
# The exit codes returned are:
#       0 - operation completed successfully
#       1 -
#       2 - usage error
#       3 - APM Infrastructure Agent could not be started
#       4 - APM Infrastructure Agent could not be stopped
#       5 - Invalid user permissions
#       6 - Unsupported operation for the OS type
#       8 - configuration syntax error
#
# When multiple arguments are given, only the error from the _last_
# argument is reported.
# Run "APMIAgent.sh help" for usage info

# Set the home directory if it is unset.
# Different OSes require different test statements

ERROR=0

eval cd "$AGENTHOME"
if [ -z "$AGENTLOGDIR" ]; then
    AGENTLOGDIR="logs"
fi

# The logfiles
LOGFILE=${AGENTLOGDIR}/APMIAgentConsole.log
JVMERRORFILE=${AGENTLOGDIR}/jvm_error.%p.log

# the path to your PID file
PIDFILE="bin/APMIAgent.pid"

# changes for passing heap values in arguments
MIN_HEAP_VAL_IN_MB=16
MAX_HEAP_VAL_IN_MB=256

MIN_ARG_PRESENT=true
if [ -z "$2" ]
  then
    MIN_ARG_PRESENT=false
fi

MAX_ARG_PRESENT=true
if [ -z "$3" ]
  then
    MAX_ARG_PRESENT=false
fi

if [ "$MIN_ARG_PRESENT" = "true" ]
   then
        #checking whether the input is a number
        echo $2 | grep "[^0-9]" > /dev/null 2>&1
        if [ "$?" -eq "0" ]; then  # If the grep found something other than 0-9  # then it's not an integer. 
          echo "Invalid value: $2. Please specify a numeric value for minimum java heap memory"
          ERROR=2
        else
          if [ $2 -gt ${MIN_HEAP_VAL_IN_MB} ]
            then
              MIN_HEAP_VAL_IN_MB=$2
              #echo Min Heap is: $MIN_HEAP_VAL_IN_MB
          fi
        fi
fi

if [ "$MAX_ARG_PRESENT" = "true" ]
   then
        #checking whether the input is a number
        echo $3 | grep "[^0-9]" > /dev/null 2>&1
        if [ "$?" -eq "0" ]; then  # If the grep found something other than 0-9  # then it's not an integer. 
          echo "Invalid value: $3. Please specify a numeric value for maximum java heap memory"
          ERROR=2
        else
          if [ $3 -ge ${MIN_HEAP_VAL_IN_MB} ]
            then
              MAX_HEAP_VAL_IN_MB=$3
              #echo Min Heap is: $MIN_HEAP_VAL_IN_MB,           Min Heap is: $MAX_HEAP_VAL_IN_MB
          fi
        fi
fi

if [ ${MIN_HEAP_VAL_IN_MB} -gt ${MAX_HEAP_VAL_IN_MB} ]
  then
    MAX_HEAP_VAL_IN_MB=$MIN_HEAP_VAL_IN_MB
fi

# Set JAVA_HOME to locally installed JRE
eval export JAVA_HOME="\"${AGENTHOME}/jre*\""

# ||||||||||||||||||||   END CONFIGURATION SECTION  ||||||||||||||||||||
# The command to start the APM Infrastructure Agent
function setJavaCmd()
{
	JavaCmd="${JAVA_HOME}/bin/java -server -Xms${MIN_HEAP_VAL_IN_MB}m -Xmx${MAX_HEAP_VAL_IN_MB}m -XX:ErrorFile=${JVMERRORFILE} -jar ${AGENTHOME}/lib/UnifiedMonitoringAgent.jar"
}

function start_Agent()
{
	if [ $RUNNING -eq 1 ]; then
		echo "$0 $ARG: APM Infrastructure Agent (pid $PID) already running"
		continue
	fi
	setJavaCmd
	echo Starting $JavaCmd
	if [ "$CONSOLELOGENABLED" == "1" ]; then
		eval  $JavaCmd &
 	else
		eval nohup $JavaCmd >> "$LOGFILE" 2>&1 &
	fi
	sleep 5
	if [ "x$!" != "x" ] ; then
		#PID=$!;
		PID=`pgrep -f "${AGENTHOME}/lib/UnifiedMonitoringAgent.jar"`
		ps -ef | grep -v grep | grep $PID > /dev/null
		RESULT=$?
		if [ "$RESULT" != "0" ]; then
			echo "$0 $ARG: APM Infrastructure Agent has failed";
			echo "Check log files in $AGENTLOGDIR for more information.";
			ERROR=3
		else
			eval echo "$PID" > "$PIDFILE";
			echo "$0 $ARG: APM Infrastructure Agent (pid $PID) started";
			break
		fi
	else
		echo "$0 $ARG: APM Infrastructure Agent could not be started";
		echo "Check log files in $AGENTLOGDIR for more information.";
		ERROR=3
	fi
}

function stop_Agent()
{
	if [ $RUNNING -eq 0 ]; then
		echo "$0 $ARG: $STATUS"
		continue
        fi
        echo Stopping $PID
        if kill $PID ; then
                RESULT="0"
                COUNT="0"
                while [ $COUNT -lt 3 -a "$RESULT" = "0" ]
                do
                        sleep 1
                        ps -ef | grep -v grep | grep $PID > /dev/null
                        RESULT=$?
                        COUNT=$[$COUNT+1]
                done
                if [ "$RESULT" = "0" ]; then
                        echo Forcing $PID to stop
                        kill -9 $PID
                        sleep 1
                        ps -ef | grep -v grep | grep $PID > /dev/null
                        RESULT=$?
                        if [ "$RESULT" = "0" ]; then
                        echo "$0 $ARG: APM Infrastructure Agent could not be stopped"
                        ERROR=4
                    fi
                fi
                rm -rf "$PIDFILE"
            echo "$0 $ARG: APM Infrastructure Agent stopped"
        else
            echo "$0 $ARG: APM Infrastructure Agent could not be stopped"
            ERROR=4
        fi
 
}

eval cd "${AGENTHOME}"

ARGV="$@"
if [ "x$ARGV" = "x" ] ; then
    ARGS="help"
fi

for ARG_RAW in $@ $ARGS
do
    # check for pidfile
    if [ -f "$PIDFILE" ] ; then
        PID=`cat "$PIDFILE"`
        if [ "x$PID" != "x" ] && kill -0 $PID 2>/dev/null ; then
            STATUS="APM Infrastructure Agent (pid $PID) running"
            RUNNING=1
        else
            STATUS="APM Infrastructure Agent (pid $PID?) not running"
            RUNNING=0
        fi
    else
        STATUS="APM Infrastructure Agent (no pid file) not running"
        RUNNING=0
    fi

    if [ $ERROR -eq 2 ]; then
		ARG="help"
		#echo  VALUE CHANGED to help: $ARG
	else
        ARG=${ARG_RAW}
        #echo  VALUE CHANGED to actual: $ARG
    fi

    case $ARG in
    status)
        if [ $RUNNING -eq 1 ]; then
                echo "APM Infrastructure Agent                $PID  running"
        else
                echo "APM Infrastructure Agent                    -  not active"
        fi
        ;;
		
    startwithlogs)
	CONSOLELOGENABLED=1
	start_Agent
	;;
		
    start)
	start_Agent
        ;;

    stop)
	stop_Agent
        ;;
    *)
        echo "usage: $0 (start|stop|status|help) [min java heap] [max java heap]"
        cat <<EOF

where
     start                      - start APM Infrastructure Agent
     stop                       - stop APM Infrastructure Agent
     status                     - status of APM Infrastructure Agent
     help                       - this screen
     min java heap              - minimum java heap memory in MB, default is 16
     max java heap              - maximum java heap memory in MB, default is 256

EOF
        ERROR=2
    ;;

    esac
    break
done

exit $ERROR

