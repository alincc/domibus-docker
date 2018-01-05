#!/usr/bin/env bash

source common.sh

composeUp_C2_C3_WeblogicCluster() {
    echo "Compose up C2 and C3 Weblogic Cluster..."
    docker-compose -f compose/test/docker-compose.yml up -d
}

#
# main
#

setDomibusVersion
composeUp_C2_C3_WeblogicCluster