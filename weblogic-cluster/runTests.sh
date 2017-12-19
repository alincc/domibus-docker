#!/usr/bin/env bash

# Required Environment:
#PMODE_TEMPLATE_PATH
#THIS_PARTY_NAME
#THIS_PARTY_ID
#THIS_PARTY_DOMIBUS_URL
#OTHER_PARTY_NAME
#OTHER_PARTY_ID
#OTHER_PARTY_DOMIBUS_URL

prepareDomibusForAutomatedTests() {
    echo "Preparing Domibus for automated tests..."

    dockerize -template ${DOMAIN_HOME}/conf/pmodes/domibus-gw-sample-pmode.xml.tmpl > ${DOMAIN_HOME}/conf/pmodes/domibus-gw-sample-pmode.xml
    if [ "${PMODE_TEMPLATE_PATH}" != "" ] ; then
        dockerize -template ${PMODE_TEMPLATE_PATH} > ${DOMAIN_HOME}/conf/pmodes/domibus-gw-sample-pmode.xml
    fi

    if [ "${PMODE_FILE_PATH}" == "" ] ; then
        PMODE_FILE_PATH="$DOMAIN_HOME/conf/pmodes/domibus-gw-sample-pmode.xml"
    fi

    echo "Logging to Domibus to obtain cookies"
    curl ${THIS_PARTY_DOMIBUS_URL}/rest/security/authentication \
        -i \
        -H "Content-Type: application/json" \
        -X POST -d '{"username":"admin","password":"123456"}' \
        -c /tmp/domibus_cookie.txt

    JSESSIONID=`grep JSESSIONID /tmp/domibus_cookie.txt | cut -d$'\t' -f 7`
    XSRF_TOKEN=`grep XSRF-TOKEN /tmp/domibus_cookie.txt | cut -d$'\t' -f 7`

    echo "JSESSIONID=${JSESSIONID}"
    echo "X-XSRF-TOKEN=${XSRF_TOKEN}"

    # Upload PMode
    echo "Uploading PMode file ${PMODE_FILE_PATH}..."
    curl ${THIS_PARTY_DOMIBUS_URL}/rest/pmode -v \
        --cookie /tmp/domibus_cookie.txt \
        -H "X-XSRF-TOKEN: ${XSRF_TOKEN}" \
        -F file=@${PMODE_FILE_PATH}

    # Set Message Filter Plugin Order
    echo "Setting Message Filter Plugin Order..."
    curl ${THIS_PARTY_DOMIBUS_URL}/rest/messagefilters -v \
        --cookie /tmp/domibus_cookie.txt \
        -H "X-XSRF-TOKEN: ${XSRF_TOKEN}" \
        -H 'Content-Type: application/json' \
        -X PUT \
        --data-binary '[{"entityId":0,"index":1,"backendName":"backendWebservice","routingCriterias":[],"persisted":false,"from":null,"to":null,"action":null,"service":null,"$$index":0},{"entityId":0,"index":0,"backendName":"backendFSPlugin","routingCriterias":[],"persisted":false,"from":null,"to":null,"action":null,"service":null,"$$index":1},{"entityId":0,"index":2,"backendName":"Jms","routingCriterias":[],"persisted":false,"from":null,"to":null,"action":null,"service":null,"$$index":2}]' \
        --compressed
}