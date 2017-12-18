#!/bin/bash
#
# WebLogic AdminServer Entrypoint
#
# Since: November, 2017
# Author: FERNANDES Henrique
#
# References:
#   https://github.com/oracle/docker-images
#   https://github.com/jwilder/dockerize
#   https://docs.oracle.com/middleware/1213/wls/WLSTC/reference.htm
# =============================

source domibusCommon.sh

main() {
    dockerizeTemplates
    startAdminServer
    waitForDatabaseServer
    waitForAdminServer
    waitForClusterNodesRunning
    importDomibusWeblogicClusterResources
    storeUserConfigFile
    deployDomibusWar
    waitForDomibus
    prepareDomibusForAutomatedTests

    tail -f ${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.log
}

dockerizeTemplates() {
    echo "Dockerizing templates..."
    #dockerize -template ${ORACLE_HOME}/wslt-api-1.9.1/WeblogicCluster.properties.tmpl > ${ORACLE_HOME}/wslt-api-1.9.1/WeblogicCluster.properties && \
    updateWeblogicClusterProperties

    dockerize -template ${DOMAIN_HOME}/conf/pmodes/domibus-gw-sample-pmode.xml.tmpl > ${DOMAIN_HOME}/conf/pmodes/domibus-gw-sample-pmode.xml
    if [ "${PMODE_TEMPLATE_PATH}" != "" ] ; then
        dockerize -template ${PMODE_TEMPLATE_PATH} > ${DOMAIN_HOME}/conf/pmodes/domibus-gw-sample-pmode.xml
    fi
}

startAdminServer() {
    echo "Starting AdminServer..."
    ./startWebLogic.sh &
}

waitForAdminServer() {
    echo "Waiting for Admin Server on ${ADMIN_HOST}:${ADMIN_PORT} to become available..."
    dockerize -wait tcp://${ADMIN_HOST}:${ADMIN_PORT} -timeout 120s
}

waitForDatabaseServer() {
    echo "Waiting for Database Server on ${DB_HOST}:${DB_PORT} to become available..."
    dockerize -wait tcp://${DB_HOST}:${DB_PORT} -timeout 120s
}

waitForClusterNodesRunning() {
    echo "Waiting for Cluster Nodes to become available..."
    wlst ~/wait-cluster-nodes-running.py
}

waitForDomibus() {
    echo "Waiting for Domibus on ${THIS_PARTY_DOMIBUS_URL} to become available..."
    dockerize -wait ${THIS_PARTY_DOMIBUS_URL} -timeout 120s
}

storeUserConfigFile() {
    echo "Storing user key configuration file..."
    export CONFIG_JVM_ARGS="-Dweblogic.management.confirmKeyfileCreation=true" && \
    cd ~
    /u01/oracle/wlst /u01/oracle/store-user-config-file.py
}

importDomibusWeblogicClusterResources() {
    cd /u01/oracle/wslt-api-1.9.1/
    # If WeblogicClusterImport.log does not exists, container is importing for 1st time
    if [ ! -f WeblogicClusterImport.log ]; then
        echo "Importing WeblogicCluster Properties..."
        # Use the WSLT script to load the WeblogicCluster.properties configuration and create the JMS and datasource resources
        # Retry because wlstapi doesn't implement edit timeout
        NEXT_WAIT_TIME=0
        until ./bin/wlstapi.sh scripts/import.py --property WeblogicCluster.properties || [ ${NEXT_WAIT_TIME} -eq 10 ]; do
            echo "Failed to import WeblogicCluster Properties... retrying in $NEXT_WAIT_TIME seconds..."
            sleep $(( NEXT_WAIT_TIME++ ))
        done
    fi
}


deployDomibusWar() {
    DOMIBUS_WAR_NAME=domibus-MSH-weblogic-${DOMIBUS_VERSION}.war

    echo "Deploying Domibus War..."
    # prepare environment (required for weblogic.Deployer)
    source ~/.bashrc

    # deploy domibus war (using userConfigFile)
    java weblogic.Deployer \
        -adminurl t3://${ADMIN_HOST}:${ADMIN_PORT} \
        -userconfigfile ~/weblogicConfigFile.secure \
        -userkeyfile ~/weblogicKeyFile.secure \
        -deploy -name ${DOMIBUS_WAR_NAME} \
        -targets ${CLUSTER_NAME} \
        -source ${DOMAIN_HOME}/conf/domibus/${DOMIBUS_WAR_NAME}
}

# TODO extract to the test context...
prepareDomibusForAutomatedTests() {
    echo "Preparing Domibus for automated tests..."

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

main