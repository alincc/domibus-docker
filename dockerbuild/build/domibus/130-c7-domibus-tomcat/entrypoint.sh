#!/bin/bash

echo ; echo "Sourcing domInstall Common Functions"
. /data/domInstall/scripts/functions/common.functions
. /data/domInstall/scripts/functions/database.functions

echo "--------------entrypoint: "
echo "--------------CATALINA_HOME: " ${CATALINA_HOME}
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

function buildDomibusStartupParams {
   displayFunctionBanner ${FUNCNAME[0]}

echo "   DB_TYPE                 : ${DB_TYPE}"
echo "   DB_HOST                 : ${DB_HOST}"
echo "   DB_PORT                 : ${DB_PORT}"
echo "   DB_NAME                 : ${DB_NAME}"
echo "   DB_USER                 : ${DB_USER}"
echo "   DB_PASS                 : ${DB_PASS}"


   if [ ! "${DB_HOST}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.database.serverName=${DB_HOST}"
   fi

   if [ ! "${DB_PORT}" = "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.database.port=${DB_PORT}"
   fi

   if [ ! "${DB_USER}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.datasource.user=${DB_USER}"
      domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.property.user=${DB_USER}"
   fi

   if [ ! "${DB_PASS}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.property.password=${DB_PASS}"
      domStartupParams="${domStartupParams} -Ddomibus.datasource.password=${DB_PASS}"
   fi

   if [ ! "${DB_TYPE}" == "" ] ; then
      case "${DB_TYPE}" in
         "MySQL")
            domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.xaDataSourceClassName=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.property.url=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?pinGlobalTxToPhysicalConnection=true"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.driverClassName=com.mysql.jdbc.Driver"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.url=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false"
         ;;
         "Oracle")
            domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.xaDataSourceClassName=oracle.jdbc.xa.client.OracleXADataSource"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.property.URL=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}${DB_NAME}"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.driverClassName=oracle.jdbc.OracleDriver"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.url=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}${DB_NAME}"
         ;;
         *)
            ABORT_JOB "Database Type provided ({$DB_TYPE}) but MUST BE EITHER 'MySQL' or 'Oracle'"
         ;;
      esac
   fi
}

##########################################################################
# MAIN PROGRAMM STARTS HERE
##########################################################################

#TODO pass the database parameters to the script
waitForDatabase

echo ; echo "Starting Tomcat: $CATALINA_HOME/bin/catalina.sh run"
$CATALINA_HOME/bin/catalina.sh $domStartupParams run > $CATALINA_HOME/logs/catalina.out 2>&1

