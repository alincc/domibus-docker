#!/bin/bash

CATALINA_HOME=$1
echo ; echo "-------CATALINA_HOME $CATALINA_HOME"
export CATALINA_HOME=$CATALINA_HOME
echo ; echo "Starting Domibus - Tomcat: $CATALINA_HOME/bin/catalina.sh start"
nohup $CATALINA_HOME/bin/catalina.sh start > $CATALINA_HOME/domibus.log 2>&1 &




