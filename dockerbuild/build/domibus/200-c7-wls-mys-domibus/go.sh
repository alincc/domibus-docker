#!/bin/bash

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ; echo "WORKING_DIR: ${WORKING_DIR}"

function abortJob {
   echo
   echo "#################################################################################################"
   echo "### FATAL ERROR ABORTING: $1"
   echo "#################################################################################################"
   exit
}

rm -rf ${WORKING_DIR}/temp ; mkdir -p ${WORKING_DIR}/temp/domibus

echo ; echo "Copying domInstall in: ${WORKING_DIR}/temp"
cp -r ../../../../domInstall ${WORKING_DIR}/temp

echo "Sourcing file(s):"
. ../../../../domInstall/scripts/functions/getDomibus.functions
. ../../../../domInstall/scripts/functions/common.functions

domInstallPropertyFile="`basename ${WORKING_DIR}/wls*.properties`"
echo ; echo "Sourcing DomInstall Property file: ${WORKING_DIR}/${domInstallPropertyFile}"
. ${WORKING_DIR}/${domInstallPropertyFile}

#getDomibus ${DOMIBUS_VERSION} ${ApplicationServer} ${DomibusInstallationType} ${WORKING_DIR}/temp/domibus
if [ "${DOMIBUS_VERSION}" == "4.0-SNAPSHOT" ] ; then
   copyDomibus "${DomibusSnapshotLocation}"  "`echo ${ApplicationServer} | tr '[:upper:]' '[:lower:]'`" "`echo ${DomibusInstallationType} | tr '[:upper:]' '[:lower:]'`" "${WORKING_DIR}/temp/domInstall/downloads/Domibus/${DOMIBUS_VERSION}"
fi

cp ${WORKING_DIR}/../../../../../domibus/Domibus-MSH-soapui-tests/src/main/soapui/domibus-gw-sample-pmode-*.xml ${WORKING_DIR}/temp/domInstall

# Copy Domibus Policies
cp -r ${WORKING_DIR}/../../../../../domibus/Domibus-MSH/src/main/conf/domibus/policies ${WORKING_DIR}/temp/domInstall

dockerBuildContext="`cd ${WORKING_DIR}/../../../../ ; pwd`"
dockerWorkingDir="`pwd | sed \"s#${dockerBuildContext}/##g\"`"
#dockerFile="`ls -1 ${WORKING_DIR}/*.Dockerfile | sed \"s#${dockerBuildContext}/##g\"`"
dockerFile="`ls ${WORKING_DIR}/*.Dockerfile`"

dockerImage=`basename ${dockerFile} | cut -d. -f1`
DockerBuildArgs="
--build-arg PARTY_ID=blue \
--build-arg WORKING_DIR=${dockerWorkingDir} \
--build-arg DOMINSTALL_PROPERTYFILE=${domInstallPropertyFile}
--build-arg PARTY_ID=blue	 \
--build-arg DB_TYPE=Oracle	 \
--build-arg DB_HOST=domibus_blue \
--build-arg DB_PORT=1521	 \
--build-arg DB_NAME=domibus	 \
--build-arg DB_USER=edelivery	 \
--build-arg DB_PASS=edelivery
"

echo
echo "Building Docker Image: ${dockerImage}:"

echo "   - Docker Build Context		: ${dockerBuildContext}"
echo "   - Docker File (-f)                     : ${dockerFile}"
echo "   - Docker Build Args (--build-arg)	: ${DockerBuildArgs}"
echo "   - Docker Target Image (-t)             : ${dockerImage}"

dockerBuildCmd="docker build --force-rm=true --no-cache=true -f ${dockerFile} -t ${dockerImage} ${DockerBuildArgs} ${dockerBuildContext}"

echo
echo "   - Command                              : ${dockerBuildCmd}"
echo

eval ${dockerBuildCmd}

exit

