#!/bin/bash

echo ; echo "Sourcing domInstall Common Functions"
CATALINA_HOME=$1
export CATALINA_HOME=$CATALINA_HOME

function startDomibus {
   displayFunctionBanner ${FUNCNAME[0]}

   echo ; echo "Starting Domibus - Tomcat: $CATALINA_HOME/bin/catalina.sh start"
   nohup $CATALINA_HOME/bin/catalina.sh start > $CATALINA_HOME/domibus.log 2>&1 &
}


##########################################################################
# MAIN PROGRAMM STARTS HERE
##########################################################################

startDomibus
tail -f $CATALINA_HOME/logs/catalina.out


