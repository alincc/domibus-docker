#!/bin/bash -ex

function configurePmode4Tests {
    echo ; echo "Configuring:  Domibus pModes"

    initialString="endpoint=\"http://localhost:8080/domibus/services/msh\""
    replacedString="endpoint=\"${APP_SERVER_URL_BLUE}/services/msh\""
    echo "   Replacing : ${initialString}"
    echo "   By        : ${replacedString}"
    echo "   In files   : ${targetFileBlue} and ${targetFileRed}"
    sed -i -e "s#${initialString}#${replacedString}#" ${TARGET_FILE_BLUE}
    sed -i -e "s#${initialString}#${replacedString}#" ${TARGET_FILE_RED}

    initialString="endpoint=\"http://localhost:8180/domibus/services/msh\""
    replacedString="endpoint=\"${APP_SERVER_URL_RED}/services/msh\""
    echo "   Replacing : ${initialString}"
    echo "   By        : ${replacedString}"
    echo "   In files   : ${targetFileBlue} and ${targetFileRed}"
    sed -i -e "s#${initialString}#${replacedString}#" ${TARGET_FILE_BLUE}
    sed -i -e "s#${initialString}#${replacedString}#" ${TARGET_FILE_RED}

}

function uploadPmode {
   appServerURL=$1
   pmodeFile2Upload=$2
   echo ; echo "Uploadling Pmode ${pmodeFile2Upload}"

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
   -F  file=@${pmodeFile2Upload}
}

DOMIBUS_ARTEFACTS=${1}
APP_SERVER_URL_BLUE=${2}
APP_SERVER_URL_RED=${3}
localURL=${4}
remoteURL=${5}

ADMIN_USER="admin"
ADMIN_PASSW="123456"

TARGET_FILE_BLUE="${DOMIBUS_ARTEFACTS}/../../Domibus-MSH-soapui-tests/src/main/soapui/domibus-gw-sample-pmode-blue.xml"
TARGET_FILE_RED="${DOMIBUS_ARTEFACTS}/../../Domibus-MSH-soapui-tests/src/main/soapui/domibus-gw-sample-pmode-red.xml"


echo ; echo "Starting pMode upload with the following Parameters:"
echo "   ${DOMIBUS_ARTEFACTS}"
echo "   APP_SERVER_URL_BLUE=${APP_SERVER_URL_BLUE}                 \\"
echo "   APP_SERVER_URL_RED=${APP_SERVER_URL_RED}               \\"
echo "   localURL=${localURL}               \\"
echo "   remoteURL=${remoteURL}               \\"
echo "   TARGET_FILE_BLUE=${TARGET_FILE_BLUE}               \\"
echo "   TARGET_FILE_RED=${TARGET_FILE_RED}"


configurePmode4Tests
uploadPmode $localURL $TARGET_FILE_BLUE
uploadPmode $remoteURL $TARGET_FILE_RED