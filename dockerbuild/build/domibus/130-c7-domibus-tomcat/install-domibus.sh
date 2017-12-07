#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Set DEBUG TO 1 to activate debugging
DEBUG=0

CATALINA_HOME=$1
DOMIBUS_CONFIG_LOCATION=$2
DOCKER_DOMINSTALL=$3
DOCKER_DOMIBUS_DISTRIBUTION=$4
DB_TYPE=$5
DB_HOST=$6
DB_PORT=$7
DB_NAME=$8
DB_USER=$9
DB_PASS=${10}


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

export CATALINA_HOME=-DmycustomVariable=myCustomValue:$CATALINA_HOME

exit

function displayBanner {
   cat ${DOCKER_DOMINSTALL}/scripts/textBanner.txt
}

function sourceExternalFunctions {

   echo ; echo "--Sourcing External Functions:"

   . ${DOCKER_DOMINSTALL}/scripts/functions/common.functions
   . ${DOCKER_DOMINSTALL}/scripts/functions/downloadJDBC.functions
   . ${DOCKER_DOMINSTALL}/scripts/functions/getDomibus.functions
   . ${DOCKER_DOMINSTALL}/scripts/functions/Tomcat.functions
}


function initInstallation {
  displayFunctionBanner ${FUNCNAME[0]}

  mkdir -p ${DOMIBUS_CONFIG_LOCATION}
  unzip $DOCKER_DOMIBUS_DISTRIBUTION/domibus-distribution-${DOMIBUS_VERSION}-tomcat-configuration.zip -d ${cef_edelivery_path}/domibus/conf/domibus


}

#####################################################################################################################
##### MAIN PROGRAMM START HERE
####################################################################################################################

displayBanner
sourceExternalFunctions
initInstallation
installDomibusTomcatSingle

exit

