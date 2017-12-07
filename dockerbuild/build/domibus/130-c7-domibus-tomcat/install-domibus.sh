#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Set DEBUG TO 1 to activate debugging
DEBUG=0


echo "--------------DOM_INSTALL: ${DOM_INSTALL}"
echo "--------------DOCKER_DOM_INSTALL: ${DOCKER_DOM_INSTALL}"
echo "--------------DOMIBUS_DISTRIBUTION: ${DOMIBUS_DISTRIBUTION}"
echo "--------------DOCKER_DOMIBUS_DISTRIBUTION: ${DOCKER_DOMIBUS_DISTRIBUTION}"
echo "--------------DB_TYPE: ${DB_TYPE}"
echo "--------------DB_HOST: ${DB_HOST}"
echo "--------------DB_PORT: ${DB_PORT}"
echo "--------------DB_NAME: ${DB_NAME}"
echo "--------------DB_USER: ${DB_USER}"
echo "--------------DB_PASS: ${DB_PASS}"
echo "--------------DOMIBUS_CONFIG_LOCATION: ${DOMIBUS_CONFIG_LOCATION}"
echo "--------------CATALINA_OPTS: ${CATALINA_OPTS}"
echo "--------------CATALINA_HOME: ${CATALINA_HOME}"

exit


ApplicationServer=Tomcat
echo "--------------DomibusInstallationDir: ${DomibusInstallationDir}"

function displayBanner {
   cat ${SCRIPTPATH}/scripts/textBanner.txt
}

function sourceExternalFunctions {

   echo ; echo "--Sourcing External Functions:"

   . /data/domInstall/scripts/functions/common.functions
   . /data/domInstall/scripts/functions/downloadJDBC.functions
   . /data/domInstall/scripts/functions/getDomibus.functions
   . /data/domInstall/scripts/functions/Tomcat.functions
}


function initInstallation {
   displayFunctionBanner ${FUNCNAME[0]}

  export DOWNLOAD_DIR="${SCRIPTPATH}/downloads"
  echo "Creating Temporary Download Directories: \${DOWNLOAD_DIR}"
  echo " - mkdir -p ${DOWNLOAD_DIR}"
  mkdir -p ${DOWNLOAD_DIR}
  echo " - mkdir -p ${DOWNLOAD_DIR}/Domibus/${DomibusVersion}"
  mkdir -p ${DOWNLOAD_DIR}/Domibus/${DomibusVersion}

}

#####################################################################################################################
##### MAIN PROGRAMM START HERE
####################################################################################################################

displayBanner
sourceExternalFunctions
showDomibusInstallProperties
initInstallation
getDomibus "${DomibusVersion}" "${ApplicationServer}" "${DomibusInstallationType}" "${DOWNLOAD_DIR}/Domibus/${DomibusVersion}"
echo $'\n\nStarting Domibus Installation'
installDomibusTomcatSingle

exit

