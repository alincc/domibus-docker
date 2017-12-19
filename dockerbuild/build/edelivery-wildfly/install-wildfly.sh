#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Set DEBUG TO 1 to activate debugging
DEBUG=0

JBOSS_HOME=$1 #/data/tomcat
DOM_INSTALL=$2 #/data/domInstall
JDBC_DRIVER_DIR=$3

MYSQL_DRIVER=mysql-connector-java-5.1.45-bin.jar
ORACLE_DRIVER=ojdbc7.jar


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

   echo ; echo "Configuring the MySQL module"
   cat << EOF | ${JBOSS_HOME}/bin/jboss-cli.sh

embed-server --server-config=standalone-full.xml

module add --name=com.mysql --resources=${JDBC_DRIVER_DIR}/${MYSQL_DRIVER} --dependencies=javax.api,javax.transaction.api

exit
EOF

   echo ; echo "Configuring the Oracle module"
   ${JBOSS_HOME}/bin/jboss-cli.sh <<EOF

embed-server --server-config=standalone-full.xml

module add --name=com.oracle --resources=${JDBC_DRIVER_DIR}/${ORACLE_DRIVER} --dependencies=javax.api,javax.transaction.api

exit
EOF

    echo ; echo "Adding MySQL JDBC Driver"
   ${JBOSS_HOME}/bin/jboss-cli.sh <<EOF

embed-server --server-config=standalone-full.xml

/subsystem=datasources/jdbc-driver=mysql:add(driver-name="com.mysql", \
driver-module-name="com.mysql",\
driver-xa-datasource-class-name=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource)

exit
EOF

    echo ; echo "Adding Oracle JDBC Driver"
   ${JBOSS_HOME}/bin/jboss-cli.sh <<EOF

embed-server --server-config=standalone-full.xml

/subsystem=datasources/jdbc-driver=oracle:add(driver-name="com.oracle", \
driver-module-name="com.oracle", \
driver-xa-datasource-class-name=oracle.jdbc.xa.client.OracleXADataSource)

exit
EOF
}

sourceExternalFunctions
configureJDBCDrivers

rm -r ${DOM_INSTALL}

exit

