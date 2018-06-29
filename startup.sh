#!/bin/sh
/opt/apmia/apmia-ca-installer.sh start && telnet apmem1 5001 && tail -f /opt/apmia/logs/IntroscopeAgent.log;
