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

    initialString="endpoint=\"http://localhost:8180/domibus/services/msh\""
    replacedString="endpoint=\"${redDomibusURL}/services/msh\""
    echo "   Replacing : ${initialString}"
    echo "   By        : ${replacedString}"
    echo "   In files   : ${blueSamplePMode} and ${redSamplePMode}"
    sed -i -e "s#${initialString}#${replacedString}#" ${blueSamplePMode}
    sed -i -e "s#${initialString}#${replacedString}#" ${redSamplePMode}

}

function prepareDomibusCorner {
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

    # Set Message Filter Plugin Order
    echo "Setting Message Filter Plugin Order..."
    curl ${appServerURL}/rest/messagefilters -v \
        --cookie cookie.txt \
        -H "X-XSRF-TOKEN: ${XSRFTOKEN}" \
        -H 'Content-Type: application/json' \
        -X PUT \
        --data-binary '[{"entityId":0,"index":1,"backendName":"backendWebservice","routingCriterias":[],"persisted":false,"from":null,"to":null,"action":null,"service":null,"$$index":0},{"entityId":0,"index":0,"backendName":"backendFSPlugin","routingCriterias":[],"persisted":false,"from":null,"to":null,"action":null,"service":null,"$$index":1},{"entityId":0,"index":2,"backendName":"Jms","routingCriterias":[],"persisted":false,"from":null,"to":null,"action":null,"service":null,"$$index":2}]' \
        --compressed
}

# Args:
#   $1 - Domibus URL
#   $2 - Retries
function waitDomibusURL {
    echo "Waiting for Domibus URL $1"

    NEXT_WAIT_TIME=0
    until [ ${NEXT_WAIT_TIME} -eq $2 ]; do
        if [ $(curl -s -o /dev/null -w "%{http_code}" $1/) -eq 200 ]; then
            echo "Domibus at $1 is available"
            return 0
        else
            echo "Domibus is not available... retrying in ${NEXT_WAIT_TIME} seconds..."
            sleep $(( NEXT_WAIT_TIME++ ))
        fi
    done
    echo "Domibus URL $1 not available even after ${NEXT_WAIT_TIME} retries..."
    return 1
}

PMODE_FILE_BLUE=$1
PMODE_FILE_RED=$2
DOMIBUS_BLUE_URL=$3
DOMIBUS_RED_URL=$4
DOCKER_NAME_BLUE=$5
DOCKER_NAME_RED=$6
DOM_C2="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DOCKER_NAME_BLUE}`"
DOM_C3="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${DOCKER_NAME_RED}`"

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


configurePmode4Tests http://${DOM_C2}:8080/domibus ${TARGET_FILE_BLUE} http://${DOM_C3}:8080/domibus ${TARGET_FILE_RED}
waitDomibusURL ${DOMIBUS_BLUE_URL} 500
waitDomibusURL ${DOMIBUS_RED_URL} 500
prepareDomibusCorner ${DOMIBUS_BLUE_URL} ${TARGET_FILE_BLUE}
prepareDomibusCorner ${DOMIBUS_RED_URL} ${TARGET_FILE_RED}