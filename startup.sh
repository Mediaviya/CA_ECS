#!/bin/sh
/opt/apmia/apmia-ca-installer.sh start && telnet 13.0.2.196 5001 && ping localhost;
