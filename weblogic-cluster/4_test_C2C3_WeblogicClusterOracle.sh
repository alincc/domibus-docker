#!/usr/bin/env bash
#
# Run integration tests for C2 and C3.
#   * Inspect docker container IP addresses
#   * Copy SoapUI Tests Dependencies (Database driver)
#   * Copy SoapUI Tests Policies (required for the PMode)
#   * Copy SoapUI Tests PModes
#   * Update PModes configuration
#   * Wait fot Domibus C2 and C3
#   * Prepare Domibus C2 and C3 for testing (upload pmodes and define plugin order)
#   * Execute Integration Tests
#

source common.sh
source setEnvironment.sh

copySoapUITestsDependencies() {
    echo "Copy Soap UI Tests Dependencies..."
    cp -v ${REPO}/jdbcdrivers/ojdbc7.jar ../domibus/Domibus-MSH-soapui-tests/src/main/soapui/lib
}

copySoapUITestsPModes() {
    echo "Copy Soap UI Tests PModes..."
    local ORIGIN_PMODES=../domibus/Domibus-MSH-soapui-tests/src/main/soapui
    cp -v ${ORIGIN_PMODES}/domibus-gw-sample-pmode-blue.xml . && \
    cp -v ${ORIGIN_PMODES}/domibus-gw-sample-pmode-red.xml .
}

copySoapUITestsPolicies() {
    echo "Copy Soap UI Tests Policies..."
    local ORIGIN_POLICIES=../domibus/Domibus-MSH/src/main/conf/domibus/policies
    cp -v ${ORIGIN_POLICIES}/*.xml compose/test/c2/conf/domibus/policies
    cp -v ${ORIGIN_POLICIES}/*.xml compose/test/c3/conf/domibus/policies
}

updatePModes() {
    for FILE in domibus-gw-sample-pmode-*.xml; do
        echo "Processing ${FILE} file.."
        sed -i "s/http:\/\/localhost:8080\/domibus\/services\/msh/http:\/\/${DOMIBUS_IP_BLUE}\/domibus\/services\/msh/g" ${FILE}
        sed -i "s/http:\/\/localhost:8180\/domibus\/services\/msh/http:\/\/${DOMIBUS_IP_RED}\/domibus\/services\/msh/g" ${FILE}
    done
}

prepareDomibusCorner() {
    local DOMIBUS_URL=$1
    local PMODE_FILE_PATH=$2

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

copyContainerLogs() {
    echo "Copying container logs..."

    local CONTAINER_DOMAIN=/u01/oracle/user_projects/domains/base_domain

    for INSTANCE in c2i1 c2i2 c3i1 c3i2; do
        local SERVER=test_server${INSTANCE}_1
        echo "Copying server instance logs from ${SERVER}..."
        docker cp ${SERVER}:${CONTAINER_DOMAIN}/logs/domibus.log logs/${SERVER}_domibus.log
        docker cp ${SERVER}:${CONTAINER_DOMAIN}/servers/${INSTANCE}/logs/${INSTANCE}.out logs/${SERVER}_${INSTANCE}.out
    done
}

runTests() {
    mvn -f ../domibus/Domibus-MSH-soapui-tests/pom.xml clean install -Psoapui \
        -DlocalUrl="localUrl=http://${DOMIBUS_IP_BLUE}/domibus" \
        -DremoteUrl="remoteUrl=http://${DOMIBUS_IP_RED}/domibus" \
		-DallDomainsProperties="allDomainsProperties={\"C2Default\":{\"site\":\"C2\",\"domainName\":\"default\",\"domNo\":0,\"dbType\":\"oracle\",\"dbDriver\":\"oracle.jdbc.OracleDriver\",\"dbJdbcUrl\":\"jdbc:oracle:thin:@${DB_IP_BLUE}:1521/XE\",\"dbUser\":\"domibus\",\"dbPassword\":\"changeMe!\"},\"C3Default\":{\"site\":\"C3\",\"domainName\":\"default\",\"domNo\":0,\"dbType\":\"oracle\",\"dbDriver\":\"oracle.jdbc.OracleDriver\",\"dbJdbcUrl\":\"jdbc:oracle:thin:@${DB_IP_RED}:1521/XE\",\"dbUser\":\"domibus\",\"dbPassword\":\"changeMe!\"}}"
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

#
# main
#

echo "Getting IP addresses of Containers"
DB_IP_BLUE="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' test_oraclexec2_1`"
DB_IP_RED="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' test_oraclexec3_1`"
DOMIBUS_IP_BLUE="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' test_httpdc2_1`"
DOMIBUS_IP_RED="`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' test_httpdc3_1`"

echo "DB_IP_BLUE=${DB_IP_BLUE}"
echo "DB_IP_RED=${DB_IP_RED}"
echo "DOMIBUS_IP_BLUE=${DOMIBUS_IP_BLUE}"
echo "DOMIBUS_IP_RED=${DOMIBUS_IP_RED}"

copySoapUITestsDependencies
copySoapUITestsPolicies
copySoapUITestsPModes
updatePModes

# Wait for Domibus C2 and C3
echo "Waiting for Domibus Cluster startup... (sleeping $1)"
sleep $1
waitDomibusURL http://${DOMIBUS_IP_BLUE}/domibus/ 40
waitDomibusURL http://${DOMIBUS_IP_RED}/domibus/ 40

prepareDomibusCorner http://$DOMIBUS_IP_BLUE/domibus domibus-gw-sample-pmode-blue.xml
prepareDomibusCorner http://$DOMIBUS_IP_RED/domibus domibus-gw-sample-pmode-red.xml

runTests
copyContainerLogs
