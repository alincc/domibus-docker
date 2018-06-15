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
LOCAL_ARTEFACTS=./temp/sql-scripts
SQL_SCRIPTS_DISTRIBUTION_NAME=domibus-distribution-${DOMIBUS_VERSION}-sql-scripts.zip
SQL_SCRIPTS_DISTRIBUTION=${DOMIBUS_DISTRIBUTION}/${SQL_SCRIPTS_DISTRIBUTION_NAME}

rm -rf  ${LOCAL_ARTEFACTS} ; mkdir -p ${LOCAL_ARTEFACTS}
unzip -j ${SQL_SCRIPTS_DISTRIBUTION} sql-scripts/* -d ${LOCAL_ARTEFACTS}

DOMIBUS_SHORT_VERSION=${DOMIBUS_VERSION/-SNAPSHOT/}
echo ; echo "DOMIBUS_SHORT_VERSION is ${DOMIBUS_SHORT_VERSION}"
DDLDatabaseInitScriptName="mysql5innoDb-${DOMIBUS_SHORT_VERSION}.ddl"
DDLDatabaseInitDataScriptName="mysql5innoDb-${DOMIBUS_SHORT_VERSION}-data.ddl"
echo ; echo "Database SQL script:" ${DDLDatabaseInitScriptName}
echo ; echo "Database SQL data script:" ${DDLDatabaseInitDataScriptName}
SQLDatabaseInitScriptName="1.${DDLDatabaseInitScriptName}.sql"
SQLDatabaseInitDataScriptName="2.${DDLDatabaseInitDataScriptName}.sql"
echo ; echo "Renaming database script SQL:" ${SQLDatabaseInitScriptName}
echo ; echo "Renaming database data script SQL:" ${SQLDatabaseInitDataScriptName}
mv ${LOCAL_ARTEFACTS}/${DDLDatabaseInitScriptName} ${LOCAL_ARTEFACTS}/${SQLDatabaseInitScriptName}
mv ${LOCAL_ARTEFACTS}/${DDLDatabaseInitDataScriptName} ${LOCAL_ARTEFACTS}/${SQLDatabaseInitDataScriptName}
SQLDatabaseInitScript=${LOCAL_ARTEFACTS}/${SQLDatabaseInitScriptName}
SQLDatabaseInitDataScript=${LOCAL_ARTEFACTS}/${SQLDatabaseInitDataScriptName}

echo ; echo "Database schema SQL creation is:" ${SQLDatabaseInitScript}
echo ; echo "Database schema SQL data creation is:" ${SQLDatabaseInitDataScript}

domibusVersionLowerCase="`echo ${DOMIBUS_VERSION} | tr '[:upper:]' '[:lower:]'`"
dockerBuildContext="${WORKING_DIR}"
dockerFile="`ls -1 ${WORKING_DIR}/*.Dockerfile`"
dockerImage=domibus-mysql:${domibusVersionLowerCase}
DockerBuildArgs="--build-arg DOMIBUS_SCHEMA=${SQLDatabaseInitScript} \
--build-arg DOMIBUS_DATA_INIT=${SQLDatabaseInitDataScript}
"

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

exit

