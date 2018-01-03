#!/usr/bin/env bash

copyDomibusSoapUITestPModes() {
    echo "Copy domibus soap ui tests pmodes..."
    ORIGIN_PMODES=${BASE}/domibus/Domibus-MSH-soapui-tests/src/main/soapui
    cp ${ORIGIN_PMODES}/domibus-gw-sample-pmode-blue.xml ${BASE} && \
    cp ${ORIGIN_PMODES}/domibus-gw-sample-pmode-red.xml ${BASE}
}

updatePModes() {
    # TODO inspect docker network info
    for FILE in ${BASE}/domibus-gw-sample-pmode-*.xml; do
        echo "Processing ${FILE} file.."
        sed -i "s/http:\/\/localhost:8080\/domibus\/services\/msh/http:\/\/localhost\/domibus-weblogic\/services\/msh/g" ${FILE}
        sed -i "s/http:\/\/localhost:8180\/domibus\/services\/msh/http:\/\/localhost:8080\/domibus-weblogic\/services\/msh/g" ${FILE}
    done
}

prepareDomibusCorner() {
    DOMIBUS_URL=$1
    PMODE_FILE_PATH=$2

    echo "Preparing Domibus for automated tests..."

    echo "Logging to Domibus to obtain cookies"
    curl ${DOMIBUS_URL}/rest/security/authentication \
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
    curl ${DOMIBUS_URL}/rest/pmode -v \
        --cookie /tmp/domibus_cookie.txt \
        -H "X-XSRF-TOKEN: ${XSRF_TOKEN}" \
        -F file=@${PMODE_FILE_PATH} \
        -F description="Soap UI Test"

    # Set Message Filter Plugin Order
    echo "Setting Message Filter Plugin Order..."
    curl ${DOMIBUS_URL}/rest/messagefilters -v \
        --cookie /tmp/domibus_cookie.txt \
        -H "X-XSRF-TOKEN: ${XSRF_TOKEN}" \
        -H 'Content-Type: application/json' \
        -X PUT \
        --data-binary '[{"entityId":0,"index":1,"backendName":"backendWebservice","routingCriterias":[],"persisted":false,"from":null,"to":null,"action":null,"service":null,"$$index":0},{"entityId":0,"index":0,"backendName":"backendFSPlugin","routingCriterias":[],"persisted":false,"from":null,"to":null,"action":null,"service":null,"$$index":1},{"entityId":0,"index":2,"backendName":"Jms","routingCriterias":[],"persisted":false,"from":null,"to":null,"action":null,"service":null,"$$index":2}]' \
        --compressed
}

runTests() {
    mvn com.smartbear.soapui:soapui-pro-maven-plugin:5.1.2:test \
        -DlocalUrl="http://localhost/domibus-weblogic" \
        -DremoteUrl="http://localhost:8080/domibus-weblogic" \
        -DjdbcUrlBlue="jdbc:oracle:thin:@127.0.0.1:49161/XE" \
        -DjdbcUrlRed="jdbc:oracle:thin:@127.0.0.1:49261/XE" \
        -DdriverBlue="oracle.jdbc.OracleDriver" \
        -DdriverRed="oracle.jdbc.OracleDriver" \
        -DdatabaseBlue="oracle" \
        -DdatabaseRed="oracle" \
        -DblueDbUser="domibus" \
        -DredDbUser="domibus" \
        -DblueDbPassword="XXXXXX" \
        -DredDbPassword="XXXXXX"
}

#
# main
#

BASE=$(pwd)

copyDomibusSoapUITestPModes
updatePModes
prepareDomibusCorner http://edelivery.domibus.eu/domibus-weblogic domibus-gw-sample-pmode-blue.xml
prepareDomibusCorner http://edelivery.domibus.eu:8080/domibus-weblogic domibus-gw-sample-pmode-red.xml

#runTests