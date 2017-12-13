#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Set DEBUG TO 1 to activate debugging
DEBUG=0

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

function sourceExternalFunctions {

   echo ; echo "--Sourcing External Functions:"

   . ${DOCKER_DOMINSTALL}/scripts/functions/common.functions
   . ${DOCKER_DOMINSTALL}/scripts/functions/downloadJDBC.functions
   . ${DOCKER_DOMINSTALL}/scripts/functions/getDomibus.functions
}


function initInstallation {
  displayFunctionBanner ${FUNCNAME[0]}

  mkdir -p ${DOMIBUS_CONFIG_LOCATION}

  #copy the Tomcat configuration
  unzip $DOCKER_DOMIBUS_DISTRIBUTION/domibus-distribution-${DOMIBUS_VERSION}-tomcat-configuration.zip -d ${DOMIBUS_CONFIG_LOCATION}

  #copy the war in the webapps directory
  unzip $DOCKER_DOMIBUS_DISTRIBUTION/domibus-distribution-${DOMIBUS_VERSION}-tomcat-war.zip -d ${CATALINA_HOME}/webapps
  mv ${CATALINA_HOME}/webapps/domibus-MSH-tomcat-4.0-SNAPSHOT.war ${CATALINA_HOME}/webapps/domibus.war

  #copy the sample keystore/truststore
  unzip -j $DOCKER_DOMIBUS_DISTRIBUTION/domibus-distribution-${DOMIBUS_VERSION}-sample-configuration-and-testing.zip conf/domibus/keystores/* -d ${DOMIBUS_CONFIG_LOCATION}/keystores

  #unzip $DOCKER_DOMIBUS_DISTRIBUTION/domibus-distribution-${DOMIBUS_VERSION}-sample-configuration-and-testing.zip -d ${DOMIBUS_CONFIG_LOCATION}/temp
  #mv ${DOMIBUS_CONFIG_LOCATION}/conf/domibus/keystores ${DOMIBUS_CONFIG_LOCATION}
  #rm -rf ${DOMIBUS_CONFIG_LOCATION}/temp

  #copy the policies
  mkdir -p ${DOMIBUS_CONFIG_LOCATION}/policies
  cp ${DOCKER_DOMINSTALL}/policies/* ${DOMIBUS_CONFIG_LOCATION}/policies

  #installing the plugins
  mkdir -p ${DOMIBUS_CONFIG_LOCATION}/plugins/config
  mkdir -p ${DOMIBUS_CONFIG_LOCATION}/plugins/lib
  unzip -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip conf/domibus/plugins/config/tomcat/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/config
  unzip -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip conf/domibus/plugins/lib/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/lib

}

#####################################################################################################################
##### MAIN PROGRAMM START HERE
####################################################################################################################

sourceExternalFunctions
initInstallation

exit

