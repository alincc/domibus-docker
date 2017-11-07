#!/bin/bash

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ; echo "WORKING_DIR: ${WORKING_DIR}"

function ABORT_JOB {
   message="${1}"
   echo
   echo "#################################################################################################"
   echo "### FATAL ERROR ABORTING: ${message}"
   echo "#################################################################################################"
   exit 9
}

REPOSITORY="$1"
if [ "X${REPOSITORY}" == "X" ] ; then
   ABORT_JOB "REPOSITORY NOT PROVIDED as parameter 1 (\$1)"
else
   if [ ! -f ${REPOSITORY}/fmw_12.1.3.0.0_wls.jar ] ; then
      ABORT_JOB "Could not locate WebLogic Universal Installer at the specified location:  ${REPOSITORY}/fmw_12.1.3.0.0_wls.jar"
   fi
fi
echo "WebLogic Installation will be performed using:${REPOSITORY}/fmw_12.1.3.0.0_wls.jar"

TEMP_DIR="${WORKING_DIR}/temp"
mkdir "${TEMP_DIR}"
if [ $? -ne 0 ] ; then
   ABORT_JOB "Error creating 'temp' directory: ${TEMP_DIR}"
fi

echo ; echo "Copying WebLogic Universal Installer into Docker Build Context"
cp  ${REPOSITORY}/fmw_12.1.3.0.0_wls.jar ${TEMP_DIR}
if [ $? -ne 0 ] ; then
   ABORT_JOB "Error copying ${REPOSITORY}/fmw_12.1.3.0.0_wls.jar into ${TEMP_DIR}"
fi

echo ; echo "Copying wsltapi1.9.1 into Docker Build Context"
echo "cp  ${REPOSITORY}/Oracle/wslt-api-1.9.1.zip ${TEMP_DIR}"
cp  ${REPOSITORY}/Oracle/wslt-api-1.9.1.zip ${TEMP_DIR}
if [ $? -ne 0 ] ; then
   ABORT_JOB "Error copying ${REPOSITORY}/Oracle/wslt-api-1.9.1.zip into ${TEMP_DIR}"
fi

mkdir ${TEMP_DIR}/java && cp -r  ${REPOSITORY}/Oracle/Java/jdk* ${TEMP_DIR}/java
if [ $? -ne 0 ] ; then
   ABORT_JOB "Error copying ${REPOSITORY}/Oracle/Java/jdk* into ${TEMP_DIR}/java"
fi


dockerFile="`ls -1 *.Dockerfile`"
dockerBuildContext="${WORKING_DIR}"
dockerFile="`ls -1 ${WORKING_DIR}/*.Dockerfile`"
dockerImage=`basename ${dockerFile} | cut -d. -f1`
DockerBuildArgs=""

echo
echo "Building Docker Image: ${dockerImage}:"

echo "   - Docker Build Directory               : ${dockerBuildContext}"
echo "   - Docker File (-f)                     : ${dockerFile}"
echo "   - Docker Build Args (--build-arg)      : ${DockerBuildArgs}"
echo "   - Docker Target Image (-t)             : ${dockerImage}"

dockerBuildCmd="docker build --force-rm=true --no-cache=true -f ${dockerFile} -t ${dockerImage} ${DockerBuildArgs} ${dockerBuildContext}"

echo
echo "   - Command                              : ${dockerBuildCmd}"
echo

eval ${dockerBuildCmd}

echo ; echo "Removing 'temp' directory:  ${TEMP_DIR}"
rm -rf ${TEMP_DIR}/java

exit

