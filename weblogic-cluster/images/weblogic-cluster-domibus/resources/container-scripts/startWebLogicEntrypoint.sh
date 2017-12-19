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
    updateWeblogicClusterProperties
    startAdminServer
    waitForDatabaseServer
    waitForAdminServer
    waitForClusterNodesRunning
    importDomibusWeblogicClusterResources
    storeUserConfigFile
    deployDomibusWar
    waitForDomibus

    tail -f ${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.log
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

main