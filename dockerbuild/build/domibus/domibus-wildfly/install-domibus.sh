#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Set DEBUG TO 1 to activate debugging
DEBUG=0

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

function sourceExternalFunctions {

   echo ; echo "--Sourcing External Functions:"

   . ${DOCKER_DOMINSTALL}/scripts/functions/common.functions
   . ${DOCKER_DOMINSTALL}/scripts/functions/getDomibus.functions
}


function configureArtefacts {
  displayFunctionBanner ${FUNCNAME[0]}

  mkdir -p ${DOMIBUS_CONFIG_LOCATION}

  #copy the WildFly configuration
  unzip $DOCKER_DOMIBUS_DISTRIBUTION/domibus-distribution-${DOMIBUS_VERSION}-wildfly-configuration.zip -d ${DOMIBUS_CONFIG_LOCATION}

  #copy the war in the webapps directory
  unzip $DOCKER_DOMIBUS_DISTRIBUTION/domibus-distribution-${DOMIBUS_VERSION}-wildfly-war.zip -d ${JBOSS_HOME}/standalone/deployments/

  #copy the sample keystore/truststore
  unzip -j $DOCKER_DOMIBUS_DISTRIBUTION/domibus-distribution-${DOMIBUS_VERSION}-sample-configuration-and-testing.zip conf/domibus/keystores/* -d ${DOMIBUS_CONFIG_LOCATION}/keystores

  #copy the policies
  mkdir -p ${DOMIBUS_CONFIG_LOCATION}/policies
  cp ${DOCKER_DOMINSTALL}/policies/* ${DOMIBUS_CONFIG_LOCATION}/policies

  #installing the plugins
  mkdir -p ${DOMIBUS_CONFIG_LOCATION}/plugins/config
  mkdir -p ${DOMIBUS_CONFIG_LOCATION}/plugins/lib
  unzip -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip conf/domibus/plugins/config/wildfly/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/config
  unzip -j ${DOCKER_DOMIBUS_DISTRIBUTION}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip conf/domibus/plugins/lib/* -d ${DOMIBUS_CONFIG_LOCATION}/plugins/lib

}

#####################################################################################################################
##### MAIN PROGRAMM START HERE
####################################################################################################################

sourceExternalFunctions
configureArtefacts

exit

