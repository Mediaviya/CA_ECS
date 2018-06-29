#!/bin/sh
/opt/apmia/apmia-ca-installer.sh start && echo "13.0.2.48    apmem1" >> /etc/hosts && tail -f /opt/apmia/logs/IntroscopeAgent.log;
