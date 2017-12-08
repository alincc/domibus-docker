#!/bin/bash

echo ; echo "Starting Tomcat: $CATALINA_HOME/bin/catalina.sh run"
$CATALINA_HOME/bin/catalina.sh run > $CATALINA_HOME/logs/catalina.out 2>&1



