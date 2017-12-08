#!/bin/bash

echo ; echo "Starting Tomcat: $CATALINA_HOME/bin/catalina.sh start"
nohup $CATALINA_HOME/bin/catalina.sh start > $CATALINA_HOME/tomcat.log 2>&1 &



