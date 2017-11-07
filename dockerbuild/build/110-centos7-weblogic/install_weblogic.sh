#!/bin/bash

#export JAVA_HOME=/data/java/jdk1.7.0_80
#export PATH=$JAVA_HOME/bin:$PATH

# Selecting the LAST JDK 7
export JAVA_HOME="`ls -1 /usr/local/java | grep jdk1.7 | tail -1`"
export PATH=/usr/local/java/${JAVA_HOME}/bin:${PATH}

java -jar /data/WebLogic/fmw_12.1.3.0.0_wls.jar -silent -responseFile /data/WebLogic/wls_answer_file -invPtrLoc /data/WebLogic/oraInst.loc
