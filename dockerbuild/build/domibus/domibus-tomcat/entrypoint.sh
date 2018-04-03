#!/bin/bash

echo ; echo "--------------Domibus entry point"


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


   if [ ! "${DB_HOST}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.database.serverName=${DB_HOST}"
   fi

   if [ ! "${DB_PORT}" == "" ] ; then
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

   if [ ! "${CERT_ALIAS}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.security.key.private.alias=${CERT_ALIAS}"
   fi

   if [ ! "${PRIVATE_PASSWD}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.security.key.private.password=${PRIVATE_PASSWD}"
   fi

   if [ ! "${KEYSTORE_PASSWD}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.security.keystore.password=${KEYSTORE_PASSWD}"
   fi

   if [ ! "${TRUSTSTORE_PASSWD}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.security.truststore.password=${TRUSTSTORE_PASSWD}"
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

   echo ; echo "Before: $CATALINA_OPTS"
   CATALINA_OPTS="${CATALINA_OPTS} ${domStartupParams}"
   export CATALINA_OPTS=${CATALINA_OPTS}
   echo ; echo "After: $CATALINA_OPTS"
}

function installDefaultPlugins {
    echo ; echo "NO_DEFAULT_PLUGINS=${NO_DEFAULT_PLUGINS}"
    if [ "${NO_DEFAULT_PLUGINS}" == "true" ] ; then
        return
    fi
    [ -d ${DOMIBUS_CONFIG_LOCATION}/plugins/config ] || mkdir -p ${DOMIBUS_CONFIG_LOCATION}/plugins/config
    [ -d ${DOMIBUS_CONFIG_LOCATION}/plugins/lib ] || mkdir -p ${DOMIBUS_CONFIG_LOCATION}/plugins/lib
    echo ; echo "Installing default plugins"
    # WS
    unzip -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip conf/domibus/plugins/config/tomcat/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/config
    unzip -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip conf/domibus/plugins/lib/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/lib

    # JMS
    unzip -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-jms-plugin.zip conf/domibus/plugins/config/tomcat/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/config
    unzip -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-jms-plugin.zip conf/domibus/plugins/lib/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/lib

    # FS
    unzip -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-fs-plugin.zip conf/domibus/plugins/config/tomcat/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/config
    unzip -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-fs-plugin.zip conf/domibus/plugins/lib/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/lib
    [ -d ${CATALINA_HOME}/fs_plugin_data/MAIN ] || mkdir -p ${CATALINA_HOME}/fs_plugin_data/MAIN
    sed -i "s#^fsplugin.messages.location=.*#fsplugin.messages.location=${CATALINA_HOME}/fs_plugin_data/MAIN#g" ${DOMIBUS_CONFIG_LOCATION}/plugins/config/fs-plugin.properties
}

##########################################################################
# MAIN PROGRAMM STARTS HERE
##########################################################################

installDefaultPlugins
buildDomibusStartupParams
waitForDatabase ${DB_TYPE} ${DB_HOST} ${DB_PORT} ${DB_USER} ${DB_PASS} ${DB_NAME}

echo ; echo "Starting Tomcat: $CATALINA_HOME/bin/catalina.sh run $CATALINA_OPTS"
$CATALINA_HOME/bin/catalina.sh run -DCATALINA_OPTS="$CATALINA_OPTS" > $CATALINA_HOME/logs/catalina.out 2>&1

