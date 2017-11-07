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

buildOracle="$1"

if [ "X${buildOracle}" == "X" ] ; then
   echo ; echo "Building Docker image for MySQL database ONLY"
else
   if [ "${buildOracle}" == "Oracle" ] ; then
      echo ; echo "Building Docker Image for MySQL AND ORACLE database"
   else
      ABORT_JOB "UNKNOWN PARAMETER RECEIVED... If specified, \$1 Must be 'Oracle': ${buildOracle}" 
   fi
fi

rm -rf  ${WORKING_DIR}/temp ; mkdir -p ${WORKING_DIR}/temp/domibus

echo ; echo "Copying domInstall in: ${WORKING_DIR}/temp"
cp -r ../../../../domInstall ${WORKING_DIR}/temp

# Getting Domibus artefacts into the Docker-Build Context
echo ; echo "Copying Domibus Artefacts to Docker-Build Context directory (`pwd`)"
echo "Sourcing file(s):"
. ../../../../domInstall/scripts/functions/getDomibus.functions
. ../../../../domInstall/scripts/functions/common.functions

domInstallPropertyFile="`basename ${WORKING_DIR}/*.properties`"
echo ; echo "Sourcing DomInstall Property file: ${WORKING_DIR}/${domInstallPropertyFile}"
. ${WORKING_DIR}/${domInstallPropertyFile}

# Copying Domibus artefacts into the Docker-Build Context
if [ "${DomibusVersion}" == "4.0-SNAPSHOT" ] ; then
   copyDomibus "${DomibusSnapshotLocation}"  "`echo ${ApplicationServer} | tr '[:upper:]' '[:lower:]'`" "`echo ${DomibusInstallationType} | tr '[:upper:]' '[:lower:]'`" "${WORKING_DIR}/temp/domInstall/downloads/Domibus/${DomibusVersion}"
fi

cp ${WORKING_DIR}/../../../../../domibus/Domibus-MSH-soapui-tests/src/main/soapui/domibus-gw-sample-pmode-*.xml ${WORKING_DIR}/temp/domInstall

# Copy Domibus Policies
cp -r ${WORKING_DIR}/../../../../../domibus/Domibus-MSH/src/main/conf/domibus/policies ${WORKING_DIR}/temp/domInstall

dockerBuildContext="`cd ${WORKING_DIR}/../../../../ ; pwd`"

dockerWorkingDir="`pwd  | sed \"s#${dockerBuildContext}/##g\"`"
dockerFile="`ls ${WORKING_DIR}/*.Dockerfile`"
dockerImage="`basename ${dockerFile} | cut -d. -f1`:${DomibusVersion}"
DockerBuildArgs="
--build-arg PARTY_ID=blue \
--build-arg WORKING_DIR=\"${dockerWorkingDir}\" \
--build-arg DOMINSTALL_PROPERTYFILE=${domInstallPropertyFile} \
--build-arg PARTY_ID=blue        \
--build-arg DB_TYPE=MySQL        \
--build-arg DB_HOST=domibus_blue \
--build-arg DB_PORT=3306         \
--build-arg DB_NAME=domibus      \
--build-arg DB_USER=edelivery    \
--build-arg DB_PASS=edelivery    \
"

echo
echo "Building Docker Image: ${dockerImage}:"
echo
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

if [ "${buildOracle}" == "Oracle" ] ; then
   mkdir -p ${WORKING_DIR}/temp/domInstall/downloads/jdbc
   cp ${ORACLE_REPO}/jdbc/* ${WORKING_DIR}/temp/domInstall/downloads/jdbc
   if [ $? -ne 0 ] ; then
      ABORT_JOB "ERROR Copying Oracle jdbc drivers from ${ORACLE_REPO}/jdbc to  ${WORKING_DIR}/temp/domInstall/downloads/jdbc"
   fi

   dockerBuildContext="`cd ${WORKING_DIR}/../../../../ ; pwd`"
   dockerWorkingDir="`pwd  | sed \"s#${dockerBuildContext}/##g\"`"
   dockerFile="`ls ${WORKING_DIR}/*.DockerfileOra`"
   dockerImage="`basename ${dockerFile} | cut -d. -f1`:${DomibusVersion}"
   DockerBuildArgs="                                                       \
   --build-arg PARTY_ID=blue                                               \
   --build-arg WORKING_DIR=${dockerWorkingDir}                             \
   --build-arg JAVA_VERSION                                                \
   --build-arg DB_TYPE="oracle"                                            \
   --build-arg DB_HOST="localhost"                                         \
   --build-arg DB_PORT="1521"                                              \
   --build-arg DB_NAME="XE"                                                \
   --build-arg DB_USER="edelivery"                                         \
   --build-arg DB_PASS="edelivery"
"

   echo
   echo "Building Docker Image: ${dockerImage}:"
   echo
   echo " - Docker Build Context           : ${dockerBuildContext}"
   echo " - Docker File (-f)                     : ${dockerFile}"
   echo " - Docker Build Args (--build-arg)        : ${DockerBuildArgs}"
   echo " - Docker Target Image (-t)             : ${dockerImage}"
   echo

   dockerBuildCmd="docker build --force-rm=true --no-cache=true -f ${dockerFile} -t ${dockerImage} ${DockerBuildArgs} ${dockerBuildContext}"

   echo
   echo "   - Command                              : ${dockerBuildCmd}"
   echo

   eval ${dockerBuildCmd}
fi

exit
