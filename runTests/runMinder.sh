#!/bin/bash -xe

set -x

runSuite() {
	RUN_SUITE_DATA="<suiteRunRequest xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"restRunRequestResponseTypes.xsd\"><suiteId>$1</suiteId></suiteRunRequest>"
	SUITE_RUN_ID=`curl -s --data "$RUN_SUITE_DATA" --digest --user root@minder:retset1 -X POST http://13.93.127.140:9000/rest/run/runSuite | awk -F "</suiteRunId>" '{print $1}' | awk -F "<suiteRunId>" '{print $2}'`
	echo $SUITE_RUN_ID
}

suiteRunStatus() {
    # Wait for runSuite to end and get the status
    SUITE_RUN_STATUS_DATA="<suiteRunStatusRequest xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"restRunRequestResponseTypes.xsd\"><suiteRunId>$1</suiteRunId></suiteRunStatusRequest>"
    STATUS=`curl -s --data "$SUITE_RUN_STATUS_DATA" --digest --user root@minder:retset1 -X POST http://13.93.127.140:9000/rest/run/suiteRunStatus | awk -F "</status>" '{print $1}' | awk -F "<status>" '{print $2}'`
    echo $STATUS
}

copyMinderTestsPModes() {
    echo "Copy Minder Tests PModes..."
    local ORIGIN_PMODES=../../domibus-plugins/Domibus-kerkovi-plugin/src/main/resources/pmodes
    cp -v ${ORIGIN_PMODES}/domibus-configuration-domibus_c2.xml . && \
    cp -v ${ORIGIN_PMODES}/domibus-configuration-domibus_c3.xml .
}

uploadPmode() {
    local DOMIBUS_URL=$1
    local PMODE_FILE_PATH=$2

    echo "Uploading pMode for conformance tests..."

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
        -F description="Minder Test"
}

# Args:
#   $1 - Domibus URL
#   $2 - Retries
function waitDomibusURL {
    echo "Waiting for Domibus URL $1"

    NEXT_WAIT_TIME=0
    until [ $(curl -s -o /dev/null -w "%{http_code}" $1/) -eq 200 ] || [ ${NEXT_WAIT_TIME} -eq $2 ]; do
        echo "Domibus is not available... retrying in ${NEXT_WAIT_TIME} seconds..."
        sleep $(( NEXT_WAIT_TIME++ ))
    done
}

function runTests() {

    SUITES=( "7:Domibus_basic_connectivity"
             "5:Domibus_esens_specific_as4"
             "4:Domibus_generic_as4" )

    #SUITES=( "7:Domibus_basic_connectivity" )

    RESULT=PASSED

    for SUITE in "${SUITES[@]}"
    do
        SUITE_ID="${SUITE%%:*}"
        SUITE_NAME="${SUITE##*:}"
        echo Running suite $SUITE_ID - $SUITE_NAME .

        # Run suite an get the run id as the result
        SUITE_RUN_ID=`runSuite $SUITE_ID`
        echo Result is: $SUITE_RUN_ID

        # Get suite run status, wait until is ready
        STATUS=`suiteRunStatus $SUITE_RUN_ID`
        echo $STATUS

        # Wait for runSuite to end
        NEXT_WAIT_TIME=0
        while ([ "$STATUS" == "IN_PROGRESS" ] || [ "$STATUS" == "" ] ) && [ $NEXT_WAIT_TIME -ne 20 ]; do
          echo  "Retrying after $NEXT_WAIT_TIME."
          sleep 60
          STATUS=`suiteRunStatus $SUITE_RUN_ID`
          echo $STATUS
          let NEXT_WAIT_TIME=NEXT_WAIT_TIME+1
        done

        echo Status of suite $SUITE_ID is $STATUS

        # If at least one suite failed, the plan will fail
        if [ "$STATUS" != "SUCCESS" ]; then
          echo Suite "$SUITE_ID" - "$SUITE_NAME" has status \"$STATUS\".
          RESULT="FAILED"
        fi
    done

    echo  "RESULT: $RESULT"

    if [ "$RESULT" != "PASSED" ]; then
        exit 1
    fi
    exit 0
}

##### main starts here #####

DOMIBUS_ENDPOINT_C2=52.174.157.171:18081
DOMIBUS_ENDPOINT_C3=52.174.157.171:18082

copyMinderTestsPModes
echo "Waiting for Domibus instances startup..."
waitDomibusURL http://${DOMIBUS_ENDPOINT_C2}/domibus/ 40
waitDomibusURL http://${DOMIBUS_ENDPOINT_C3}/domibus/ 40

uploadPmode http://$DOMIBUS_ENDPOINT_C2/domibus domibus-configuration-domibus_c2.xml
uploadPmode http://$DOMIBUS_ENDPOINT_C3/domibus domibus-configuration-domibus_c3.xml

runTests


