#!/bin/bash -ex

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo ; echo "WORKING_DIR: ${WORKING_DIR}"

function configurePmode4Tests {
    echo ; echo "Configuring:  Domibus pModes"

    local blueDomibusURL=$1
    local blueSamplePMode=$2

    local redDomibusURL=$3
    local redSamplePMode=$4

    initialString="endpoint=\"http://localhost:8080/domibus/services/msh\""
    replacedString="endpoint=\"${blueDomibusURL}/services/msh\""
    echo "   Replacing : ${initialString}"
    echo "   By        : ${replacedString}"
    echo "   In files   : ${blueSamplePMode} and ${redSamplePMode}"
    sed -i -e "s#${initialString}#${replacedString}#" ${blueSamplePMode}
    sed -i -e "s#${initialString}#${replacedString}#" ${redSamplePMode}

    initialString="endpoint=\"http://localhost:8081/domibus/services/msh\""
    replacedString="endpoint=\"${redDomibusURL}/services/msh\""
    echo "   Replacing : ${initialString}"
    echo "   By        : ${replacedString}"
    echo "   In files   : ${blueSamplePMode} and ${redSamplePMode}"
    sed -i -e "s#${initialString}#${replacedString}#" ${blueSamplePMode}
    sed -i -e "s#${initialString}#${replacedString}#" ${redSamplePMode}

}

function uploadPmode {
   local appServerURL=$1
   local pmodeFile2Upload=$2

   echo ; echo "Uploadling Pmode ${pmodeFile2Upload} to ${appServerURL}"

   echo "   Loging to Domibus to obtain cookies"
   curl ${appServerURL}/rest/security/authentication \
   -i \
   -H "Content-Type: application/json" \
   -X POST -d '{"username":"admin","password":"123456"}' \
   -c cookie.txt


   JSESSIONID=`grep JSESSIONID cookie.txt |  cut -d$'\t' -f 7`
   XSRFTOKEN=`grep XSRF-TOKEN cookie.txt |  cut -d$'\t' -f 7`

   echo ; echo
   echo "   JSESSIONID=${JSESSIONID}"
   echo "   XSRFTOKEN=${XSRFTOKEN}"
   echo  "  X-XSRF-TOKEN: ${XSRFTOKEN}"

   echo ; echo "   Uploading Pmode"

   curl ${appServerURL}/rest/pmode \
   -b cookie.txt \
   -v \
   -H "X-XSRF-TOKEN: ${XSRFTOKEN}" \
   -F  file=@${pmodeFile2Upload} \
   -F  description="soapUI tests"
}

PMODE_FILE_BLUE=$1
PMODE_FILE_RED=$2
DOMIBUS_BLUE_URL=$3
DOMIBUS_RED_URL=$4

LOCAL_PMODES=${WORKING_DIR}/temp/pmodes
echo "Deleting local PModes: " ${LOCAL_PMODES}
rm -rf  ${LOCAL_PMODES}
mkdir -p ${LOCAL_PMODES}

TARGET_FILE_BLUE="${LOCAL_PMODES}/domibus-gw-sample-pmode-blue.xml"
TARGET_FILE_RED="${LOCAL_PMODES}/domibus-gw-sample-pmode-red.xml"

echo "Copying PModes to " ${LOCAL_PMODES}
cp ${PMODE_FILE_BLUE} ${TARGET_FILE_BLUE}
cp ${PMODE_FILE_RED} ${TARGET_FILE_RED}

echo ; echo "Starting pMode upload with the following Parameters:"
echo "   TARGET_FILE_BLUE=${TARGET_FILE_BLUE}                 \\"
echo "   TARGET_FILE_RED=${TARGET_FILE_RED}                 \\"
echo "   DOMIBUS_BLUE_URL=${DOMIBUS_BLUE_URL}                 \\"
echo "   DOMIBUS_RED_URL=${DOMIBUS_RED_URL}               \\"


configurePmode4Tests ${DOMIBUS_BLUE_URL} ${TARGET_FILE_BLUE} ${DOMIBUS_RED_URL} ${TARGET_FILE_RED}
uploadPmode ${DOMIBUS_BLUE_URL} ${TARGET_FILE_BLUE}
uploadPmode ${DOMIBUS_RED_URL} ${TARGET_FILE_RED}