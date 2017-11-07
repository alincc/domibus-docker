#!/bin/bash

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ; echo "WORKING_DIR: ${WORKING_DIR}"; echo

function ABORT_JOB {
   echo
   echo "#############################################################################################################################"
   echo "#                                                                                                                                  #"
   echo "### FATAL ERROR ABORTING: $1"
   echo "#                                                                                                                                  #"
   echo "#############################################################################################################################"
   echo
   exit 9
}

ORACLE_REPO=${1}
if [ "X${ORACLE_REPO}" == "X" ] ; then
   ABORT_JOB "Oracle Repository NOT PROVIDED"
else
   if [ ! -d "${ORACLE_REPO}" ] ; then
      ABORT_JOB "The provided Oracle Repository (\$1) DOES NOT EXIST: ${ORACLE_REPO}"  
   fi
fi

echo ; echo "Copying Oracle Database Artifacts to Docker build context:"
echo "   From: ${ORACLE_REPO}"
echo "   To  : ${WORKING_DIR}/dockerfiles/11.2.0.1"
echo

ORACLE11202_ARTEFACTS="
oracle-xe-11.2.0-1.0.x86_64.rpm.zip
"

for oracleArtefacts in ${ORACLE11202_ARTEFACTS} ; do
   echo "Copying: ${oracleArtefacts}"
   if [ -f "${ORACLE_REPO}/${oracleArtefacts}" ] ; then
      cp "${ORACLE_REPO}/${oracleArtefacts}" "${WORKING_DIR}/dockerfiles/11.2.0.1"
      [ $? -ne 0 ] && ABORT_JOB "Error Copying file: ${ORACLE_REPO}/${oracleArtefacts} into ${WORKING_DIR}/dockerfiles/11.2.0.1" || echo "   Copied: /${oracleArtefacts}"
   else
      ABORT_JOB "File not found: ${ORACLE_REPO}/${oracleArtefacts}"
  fi
done

echo ; echo "Starting creation of Oracle Dabatase Docker Image"
cd ${WORKING_DIR}/dockerfiles
./buildDockerImage.sh -x -i -v 11.2.0.1

if [ $? -ne 0 ] ; then
   echo ; echo "Clean-up Oracle Database Installation files"
   rm ${WORKING_DIR}/dockerfiles/11.2.0.1/*.zip
   ABORT_JOB "Error creating Oracle Database Docker Image."
fi 

echo ; echo "Clean-up Oracle Database Installation files"
rm ${WORKING_DIR}/dockerfiles/11.2.0.1/*.zip

exit
