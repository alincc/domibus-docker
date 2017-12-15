#!/bin/bash

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

DOMIBUS_DISTRIBUTION=$1
LOCAL_ARTEFACTS=./temp
SQL_SCRIPTS_DISTRIBUTION_NAME=domibus-distribution-${DOMIBUS_VERSION}-sql-scripts.zip
SQL_SCRIPTS_DISTRIBUTION=${DOMIBUS_DISTRIBUTION}/${SQL_SCRIPTS_DISTRIBUTION_NAME}

rm -rf  ${LOCAL_ARTEFACTS} ; mkdir -p ${LOCAL_ARTEFACTS}/sql-scripts

#. ../../../domInstall/scripts/functions/getDomibus.functions
#. ../../../domInstall/scripts/functions/common.functions

#getDomibusSQLScripts $1 ./temp/sql-scripts

unzip ${SQL_SCRIPTS_DISTRIBUTION} -d ${LOCAL_ARTEFACTS}

#zipFilename="`ls -1 ${LOCAL_ARTEFACTS}/sql-scripts`"
#echo ; echo "Getting ZIP file name: ${zipFilename}"

SQLDatabaseInitScriptName="`ls -1 ${LOCAL_ARTEFACTS}/sql-scripts | grep mysql | grep -v migration`"
echo ; echo "Database schema SQL creation nameis:" ${SQLDatabaseInitScriptName}
SQLDatabaseInitScript=${LOCAL_ARTEFACTS}/sql-scripts/${SQLDatabaseInitScriptName}
echo ; echo "Database schema SQL creation is:" ${SQLDatabaseInitScript}

domibusVersionLowerCase="`echo ${DOMIBUS_VERSION} | tr '[:upper:]' '[:lower:]'`"
dockerBuildContext="${WORKING_DIR}"
dockerFile="`ls -1 ${WORKING_DIR}/*.Dockerfile`"
dockerImage=domibus-mysql:${domibusVersionLowerCase}
DockerBuildArgs="--build-arg DOMIBUS_SCHEMA=${SQLDatabaseInitScript}"



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

#eval ${dockerBuildCmd}

#rm -rf ${WORKING_DIR}/temp

exit

