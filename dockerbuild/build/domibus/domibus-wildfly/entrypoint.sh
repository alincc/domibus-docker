#!/bin/bash

echo ; echo "--------------Domibus entry point"

echo "--------------JBOSS_HOME: " ${JBOSS_HOME}
echo "--------------DOMIBUS_CONFIG_LOCATION: ${DOMIBUS_CONFIG_LOCATION}"
echo "--------------DOCKER_DOMINSTALL: ${DOCKER_DOMINSTALL}"
echo "--------------DOCKER_DOMIBUS_DISTRIBUTION: ${DOCKER_DOMIBUS_DISTRIBUTION}"
echo "--------------DB_TYPE: ${DB_TYPE}"
echo "--------------DB_HOST: ${DB_HOST}"
echo "--------------DB_PORT: ${DB_PORT}"
echo "--------------DB_NAME: ${DB_NAME}"
echo "--------------DB_USER: ${DB_USER}"
echo "--------------DB_PASS: ${DB_PASS}"
echo "--------------DOMIBUS_VERSION: ${DOMIBUS_VERSION}"

echo "ls DOCKER_DOMINSTALL"
ls ${DOCKER_DOMINSTALL}

echo ; echo "Sourcing domInstall Common Functions"
. ${DOCKER_DOMINSTALL}/scripts/functions/common.functions
. ${DOCKER_DOMINSTALL}/scripts/functions/database.functions

function buildDomibusStartupParams {
   displayFunctionBanner ${FUNCNAME[0]}

echo "   DB_TYPE                 : ${DB_TYPE}"
echo "   DB_HOST                 : ${DB_HOST}"
echo "   DB_PORT                 : ${DB_PORT}"
echo "   DB_NAME                 : ${DB_NAME}"
echo "   DB_USER                 : ${DB_USER}"
echo "   DB_PASS                 : ${DB_PASS}"

   if [ ! "${DB_TYPE}" == "" ] ; then
      case "${DB_TYPE}" in
         "MySQL")
            echo "Default properties are used"
         ;;
         "Oracle")
            domStartupParams="${domStartupParams} -Ddomibus.entityManagerFactory.jpaProperty.hibernate.connection.driver_class=oracle.jdbc.xa.client.OracleXADataSource"
            domStartupParams="${domStartupParams} -Ddomibus.entityManagerFactory.jpaProperty.hibernate.dialect=org.hibernate.dialect.Oracle10gDialect"
         ;;
         *)
            ABORT_JOB "Database Type provided ({$DB_TYPE}) but MUST BE EITHER 'MySQL' or 'Oracle'"
         ;;
      esac
   fi

   echo ; echo "Before: $JBOSS_OPTS"
   JAVA_OPTS="${JAVA_OPTS} ${domStartupParams}"
   export JAVA_OPTS=${JAVA_OPTS}
   echo ; echo "After: JAVA_OPTS"
}

##########################################################################
# MAIN PROGRAMM STARTS HERE
##########################################################################

buildDomibusStartupParams
waitForDatabase ${DB_TYPE} ${DB_HOST} ${DB_PORT} ${DB_USER} ${DB_PASS} ${DB_NAME}

echo ; echo "Starting WildFly:"

$JBOSS_HOME/bin/standalone.sh --server-config=standalone-full.xml -b 0.0.0.0 -bmanagement 0.0.0.0 -DJAVA_OPTS="$JAVA_OPTS"

