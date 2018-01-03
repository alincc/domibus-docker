#!/usr/bin/env bash

source common.sh

composeUp_C2_C3_WeblogicCluster() {
    echo "Compose up C2 and C3 Weblogic Cluster..."
    cd compose/test/ && docker-compose up -d
}

#
# main
#

setDomibusVersion
composeUp_C2_C3_WeblogicCluster