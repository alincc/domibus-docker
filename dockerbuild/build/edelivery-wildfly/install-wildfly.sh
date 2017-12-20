#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Set DEBUG TO 1 to activate debugging
DEBUG=0

JBOSS_HOME=$1 #/data/tomcat
DOM_INSTALL=$2 #/data/domInstall
JDBC_DRIVER_DIR=$3

MYSQL_DRIVER=mysql-connector-java-5.1.45-bin.jar
ORACLE_DRIVER=ojdbc7.jar

export JDBC_DRIVER_DIR=$JDBC_DRIVER_DIR
export MYSQL_DRIVER=$MYSQL_DRIVER
export ORACLE_DRIVER=$ORACLE_DRIVER


echo "--------------JBOSS_HOME: ${JBOSS_HOME}"
echo "--------------DOM_INSTALL: ${DOM_INSTALL}"
echo "--------------JDBC_DRIVER_DIR: ${JDBC_DRIVER_DIR}"

function sourceExternalFunctions {

   echo ; echo "--Sourcing External Functions:"

   ls -la $DOM_INSTALL

   . $DOM_INSTALL/scripts/functions/common.functions
   . $DOM_INSTALL/scripts/functions/downloadJDBC.functions
}

function configureJDBCDrivers {
   displayFunctionBanner ${FUNCNAME[0]}

   ${JBOSS_HOME}/bin/jboss-cli.sh --file=${DOM_INSTALL}/wildfly/resources/edelivery-wildfly.cli
}

sourceExternalFunctions
configureJDBCDrivers

rm -r ${DOM_INSTALL}

exit

