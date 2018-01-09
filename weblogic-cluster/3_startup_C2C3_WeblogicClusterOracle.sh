#!/usr/bin/env bash
#
# Startup docker compose containers for C2 and C3 running Weblogic Cluster with Oracle Database.
#   * Set DOMIBUS_VERSION
#   * Startup containers
#
# For more information see compose/test/docker-compose.yml.
#

source common.sh

composeUp_C2_C3_WeblogicCluster() {
    echo "Compose up C2 and C3 Weblogic Cluster..."
    cd compose/test && docker-compose up -d
}

#
# main
#
setDomibusVersion
composeUp_C2_C3_WeblogicCluster