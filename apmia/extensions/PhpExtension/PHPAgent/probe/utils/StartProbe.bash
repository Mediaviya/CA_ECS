#!/bin/bash

# Start the PHP Probe
echo "Starting APM PHP Agent Probe..."
php -r 'echo wily_php_agent_start();'

