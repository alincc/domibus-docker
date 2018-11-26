#!/bin/bash

#JaCoCo agent settings for collecting code coverage
JACOCO_VERSION=0.7.7.201606060606
JACOCO_PORT=6400
JACOCO_ADDRESS=*
JACOCO_AGENT="-javaagent:/data/jacoco/org.jacoco.agent-${JACOCO_VERSION}-runtime.jar=output=tcpserver,address=${JACOCO_ADDRESS},port=${JACOCO_PORT}"

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
echo "--------------JACOCO_AGENT: ${JACOCO_AGENT}"

echo "ls DOCKER_DOMINSTALL"
ls ${DOCKER_DOMINSTALL}

echo ; echo "Sourcing domInstall Common Functions"
. ${DOCKER_DOMINSTALL}/scripts/functions/common.functions
. ${DOCKER_DOMINSTALL}/scripts/functions/database.functions

function configureDomibus {
   displayFunctionBanner ${FUNCNAME[0]}

   printenv > env.properties
   ${JBOSS_HOME}/bin/jboss-cli.sh --file=${DOCKER_DOMINSTALL}/wildfly/resources/domibus-configuration.cli --properties=env.properties
   rm env.properties
}


function buildDomibusStartupParams {
   displayFunctionBanner ${FUNCNAME[0]}

echo "   DB_TYPE                 : ${DB_TYPE}"
echo "   DB_HOST                 : ${DB_HOST}"
echo "   DB_PORT                 : ${DB_PORT}"
echo "   DB_NAME                 : ${DB_NAME}"
echo "   DB_USER                 : ${DB_USER}"
echo "   DB_PASS                 : ${DB_PASS}"

   domStartupParams="${domStartupParams} -Ddomibus.passwordPolicy.checkDefaultPassword=false"

   if [ ! "${CERT_ALIAS}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.security.key.private.alias=${CERT_ALIAS}"
   fi

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


   JAVA_OPTS="${JACOCO_AGENT} ${JAVA_OPTS} ${domStartupParams}"
   export JAVA_OPTS=${JAVA_OPTS}
   echo ; echo "Start with:  $JAVA_OPTS"
}

function installDefaultPlugins {
    [ -d ${DOMIBUS_CONFIG_LOCATION}/plugins/config ] || mkdir -p ${DOMIBUS_CONFIG_LOCATION}/plugins/config
    [ -d ${DOMIBUS_CONFIG_LOCATION}/plugins/lib ] || mkdir -p ${DOMIBUS_CONFIG_LOCATION}/plugins/lib

    # WS
    unzip -o -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip conf/domibus/plugins/config/wildfly/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/config
    unzip -o -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip conf/domibus/plugins/lib/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/lib

    # JMS
    unzip -o -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-jms-plugin.zip conf/domibus/plugins/config/wildfly/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/config
    unzip -o -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-jms-plugin.zip conf/domibus/plugins/lib/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/lib

    # FS
    unzip -o -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-fs-plugin.zip conf/domibus/plugins/config/wildfly/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/config
    unzip -o -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-fs-plugin.zip conf/domibus/plugins/lib/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/lib
    [ -d ${JBOSS_HOME}/fs_plugin_data/MAIN ] || mkdir -p ${JBOSS_HOME}/fs_plugin_data/MAIN
    sed -i "s#^fsplugin.messages.location=.*#fsplugin.messages.location=${JBOSS_HOME}/fs_plugin_data/MAIN#g" ${DOMIBUS_CONFIG_LOCATION}/plugins/config/fs-plugin.properties
}

##########################################################################
# MAIN PROGRAMM STARTS HERE
##########################################################################

installDefaultPlugins
buildDomibusStartupParams
configureDomibus

cat  ${JBOSS_HOME}/standalone/configuration/standalone-full.xml

waitForDatabase ${DB_TYPE} ${DB_HOST} ${DB_PORT} ${DB_USER} ${DB_PASS} ${DB_NAME}

echo ; echo "Starting WildFly:"

$JBOSS_HOME/bin/standalone.sh --server-config=standalone-full.xml -b 0.0.0.0 -bmanagement 0.0.0.0 -DJAVA_OPTS="$JAVA_OPTS"

