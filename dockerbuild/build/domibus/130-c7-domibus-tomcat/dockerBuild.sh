#!/bin/bash

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ; echo "WORKING_DIR: ${WORKING_DIR}"

function ABORT_JOB {
   echo
   echo "#################################################################################################"
   echo "### FATAL ERROR ABORTING: $1"
   echo "#################################################################################################"
   exit
}

DOMIBUS_DISTRIBUTION=$1
LOCAL_ARTEFACTS=./temp
DOM_INSTALL=${LOCAL_ARTEFACTS}/domInstall
LOCAL_DOMIBUS_DISTRIBUTION=${LOCAL_ARTEFACTS}/domibus

echo "--------------DOMIBUS_DISTRIBUTION: " ${DOMIBUS_DISTRIBUTION}
echo "--------------LOCAL_ARTEFACTS: " ${LOCAL_ARTEFACTS}
echo "--------------DOM_INSTALL: " ${DOM_INSTALL}
echo "--------------LOCAL_DOMIBUS_DISTRIBUTION: " ${LOCAL_DOMIBUS_DISTRIBUTION}

rm -rf  ${LOCAL_ARTEFACTS};
mkdir -p ${DOM_INSTALL}
mkdir -p ${LOCAL_DOMIBUS_DISTRIBUTION}

echo ; echo "Copying domInstall in: ${LOCAL_ARTEFACTS}"
cp -r ../../../../domInstall/* ${DOM_INSTALL}

echo "Sourcing file(s):"
. ${DOM_INSTALL}/scripts/functions/getDomibus.functions
. ${DOM_INSTALL}/scripts/functions/common.functions

# Copying Domibus artefacts into the Docker-Build Context
copyDomibus "${DOMIBUS_DISTRIBUTION}"  'tomcat' 'single' "${LOCAL_DOMIBUS_DISTRIBUTION}"

# Copy Domibus Policies
cp -r ${WORKING_DIR}/../../../../../domibus/Domibus-MSH/src/main/conf/domibus/policies ${DOM_INSTALL}

domibusVersionLowerCase="`echo ${DOMIBUS_VERSION} | tr '[:upper:]' '[:lower:]'`"
dockerFile=c7-domibus-tomcat.Dockerfile
dockerImage=domibus-${domibusVersionLowerCase}-tomcat
dockerBuildContext=.

DockerBuildArgs="
--build-arg DOMINSTALL=${DOM_INSTALL} \
--build-arg DOMIBUS_DISTRIBUTION=${LOCAL_DOMIBUS_DISTRIBUTION} \
"

echo
echo "Building Docker Image: ${dockerImage}:"
echo
echo "DOMIBUS_VERSION: ${DOMIBUS_VERSION}"

echo " - Docker Build Context		: ${dockerBuildContext}"
echo " - Docker File (-f)                     : ${dockerFile}"
echo " - Docker Build Args (--build-arg)	: ${DockerBuildArgs}"
echo " - Docker Target Image (-t)             : ${dockerImage}"
echo

dockerBuildCmd="docker build --force-rm=true --no-cache=true -f ${dockerFile} -t ${dockerImage} ${DockerBuildArgs} ${dockerBuildContext}"

echo
echo "   - Command                              : ${dockerBuildCmd}"
echo

eval ${dockerBuildCmd}

exit

