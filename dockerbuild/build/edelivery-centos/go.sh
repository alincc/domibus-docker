#!/bin/bash

REPO_DIR=$1
JAVA_REPO_DIR=${REPO_DIR}/Oracle/Java
SQLPLUS_REPO_DIR=${REPO_DIR}/Oracle/OracleDatabase/SQLPlus

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function abortJob {
   echo
   echo "###############################################################################################################################"
   echo "#                                                                                                                             #"
   echo "# FATAL ERROR ABORTING: $1"
   echo "#                                                                                                                             #"
   echo "###############################################################################################################################"
   echo
   exit 9
}

clear

echo ; echo "WORKING_DIR: ${WORKING_DIR}"; echo

if [ "X${REPO_DIR}" == "X" ] ; then
   abortJob " SOFTWARE REPOSITORY NOT PROVIDED as Parameter1(\$1)"
else
   if [ ! -d "${REPO_DIR}" ] ; then
      abortJob "THE SOFTWARE REPOSITORY PROVIDED as Parameter1 (\$1) DOES NOT EXIST: ${REPO_DIR}"
   fi
fi

echo ; echo "Copying JAVA JRE to \$WORKING_DIR: ${WORKING_DIR}"
if [ ! -d "${REPO_DIR}/Oracle/Java" ] ; then
   abortJob "JAVA JDK/JRE REPOSITORY DOES NOT EXIST: ${REPO_DIR}/Oracle/Java" 
else
   mkdir -p ${WORKING_DIR}/temp/java
   cp -r ${JAVA_REPO_DIR}/jre* ${WORKING_DIR}/temp/java
fi

echo ; echo "Copying ORACLE SQLPLUS to \$WORKING_DIR: ${WORKING_DIR}"
if [ ! -d "${SQLPLUS_REPO_DIR}" ] ; then
   abortJob "ORACLE Database SQLPlus REPOSITORY DOES NOT EXIST: ${SQLPLUS_REPO_DIR}"
else
   mkdir -p ${WORKING_DIR}/temp/SQLPlus
   cp -r ${SQLPLUS_REPO_DIR}/* ${WORKING_DIR}/temp/SQLPlus
fi

dockerFile="edelivery-centos.Dockerfile"
dockerBuildContext="."
dockerImage=`basename ${dockerFile} | cut -d. -f1`
DockerBuildArgs=""

echo
echo "Building Docker Image: ${dockerImage}:"

echo "   - Docker Build Context                 : ${dockerBuildContext}"
echo "   - Docker File (-f)                     : ${dockerFile}"
echo "   - Docker Build Args (--build-arg)      : ${DockerBuildArgs}"
echo "   - Docker Target Image (-t)             : ${dockerImage}"

dockerBuildCmd="docker build --force-rm=true --no-cache=true -f ${dockerFile} -t ${dockerImage} ${DockerBuildArgs} ${dockerBuildContext}"

echo
echo "   - Command                              : ${dockerBuildCmd}"
echo

eval ${dockerBuildCmd}

rm -rf ${WORKING_DIR}/temp

exit

