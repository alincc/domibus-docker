#!/bin/bash
DOMIBUS_SCHEMA=${1}

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ; echo "WORKING_DIR: ${WORKING_DIR}"; echo

function abortJob {
   echo
   echo "#############################################################################################################################"
   echo "#                                                                                                                                  #"
   echo "### FATAL ERROR ABORTING: $1"
   echo "#                                                                                                                                  #"
   echo "#############################################################################################################################"
   echo
   exit
}

#[ ! -d "${WORKING_DIR}/temp/sql-scripts" ] && mkdir -p "${WORKING_DIR}/temp/sql-scripts"
rm -rf  ${WORKING_DIR}/temp ; mkdir -p ${WORKING_DIR}/temp/sql-scripts

# Getting Domibus SQL Scripts into the Docker-Build Context
echo ; echo "Copying ${DOMIBUS_SCHEMA} to Docker-Build Context directory (`pwd`)"
. ../../../domInstall/scripts/functions/getDomibus.functions
. ../../../domInstall/scripts/functions/common.functions

getDomibusSQLScripts $1 ./temp/sql-scripts

zipFilename="`ls -1 ${WORKING_DIR}/temp/sql-scripts`"
echo ; echo "Getting ZIP file name: ${zipFilename}"

SQLDatabaseInitScript="`zipinfo -1 ${WORKING_DIR}/temp/sql-scripts/${zipFilename} | grep mysql | grep -v migration`"
echo ; echo "Database schema SQL creation is:" ${SQLDatabaseInitScript}

echo ; echo "unzip -p	${WORKING_DIR}/temp/sql-scripts/${zipFilename} ${SQLDatabaseInitScript}	> ${WORKING_DIR}/temp/${SQLDatabaseInitScript}.sql"
unzip -p	${WORKING_DIR}/temp/sql-scripts/${zipFilename} ${SQLDatabaseInitScript}	> ${WORKING_DIR}/temp/${SQLDatabaseInitScript}.sql

dockerFile="`ls -1 *.Dockerfile`"

dockerBuildContext="${WORKING_DIR}"
dockerFile="`ls -1 ${WORKING_DIR}/*.Dockerfile`"
dockerImage=`basename ${dockerFile} | cut -d. -f1`
DockerBuildArgs="--build-arg DOMIBUS_SCHEMA=$(basename ${SQLDatabaseInitScript})"

echo
echo "Building Docker Image: ${dockerImage}:"

echo "   - Docker Build Directory		: ${dockerBuildContext}"
echo "   - Docker File (-f)			: ${dockerFile}"
echo "   - Docker Build Args (--build-arg)	: ${DockerBuildArgs}"
echo "   - Docker Target Image (-t)		: ${dockerImage}"

dockerBuildCmd="docker build --force-rm=true --no-cache=true -f ${dockerFile} -t ${dockerImage} ${DockerBuildArgs} ${dockerBuildContext}"

echo
echo "   - Command				: ${dockerBuildCmd}"
echo

eval ${dockerBuildCmd}

#rm -rf ${WORKING_DIR}/temp

exit

