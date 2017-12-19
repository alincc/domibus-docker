#!/bin/bash

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ; echo "WORKING_DIR: ${WORKING_DIR}"

echo ; echo "Copying domInstall in: ${WORKING_DIR}/temp"
cp -r ../../../../domInstall ${WORKING_DIR}/temp

#Copy database drivers
mkdir -p ${WORKING_DIR}/temp/domInstall/downloads/jdbc
   cp ${JDBC_DRIVERS}/* ${WORKING_DIR}/temp/domInstall/downloads/jdbc
   if [ $? -ne 0 ] ; then
      ABORT_JOB "ERROR Copying Oracle jdbc drivers from ${JDBC_DRIVERS} to  ${WORKING_DIR}/temp/domInstall/downloads/jdbc"
   fi

dockerFile="`ls -1 ${WORKING_DIR}/*.Dockerfile`"
dockerImage=edelivery-wildfly:9.0.2.Final
dockerBuildContext=.


DockerBuildArgs="
--build-arg JDBC_DRIVER_DIR=temp/domInstall/downloads/jdbc \
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

exit

