#!/bin/bash

export JAVA_HOME="/data/JDK/jdk1.7.0_79"

OLD_PATH=$PATH
export PATH=$JAVA_HOME/bin:$PATH

java -version

. /data/WebLogic/wls_12.1.3.0.0/Oracle/Middleware/Oracle_Home/wlserver/server/bin/setWLSEnv.sh

java weblogic.WLST createDomainCluster.py

PATH=$OLD_PATH

exit

