#!/usr/bin/env bash
#
# Startup docker compose containers for C2 and C3 running Weblogic Cluster with Oracle Database.
#   * Set DOMIBUS_VERSION
#   * Startup containers
#
# For more information see compose/test/docker-compose.yml.
#

# Domibus distribution target folder
DOMIBUS_DISTRIBUTION=../domibus/Domibus-MSH-distribution/target

source common.sh

prepareDomibusConf() {
    local CONF_PATH=$1
    echo "Preparing Domibus shared conf ${CONF_PATH}"

    unzip -o ${DOMIBUS_DISTRIBUTION}/domibus-distribution-*-weblogic-configuration.zip -d ${CONF_PATH}/domibus && \
    unzip -o ${DOMIBUS_DISTRIBUTION}/domibus-distribution-*-weblogic-war.zip -d ${CONF_PATH}/domibus && \
    unzip -o -j ${DOMIBUS_DISTRIBUTION}/domibus-distribution-*-sample-configuration-and-testing.zip conf/domibus/keystores/* -d ${CONF_PATH}/domibus/keystores/

    mkdir -p ${CONF_PATH}/domibus/plugins/lib
    mkdir -p ${CONF_PATH}/domibus/plugins/config

    for PLUGIN in ws fs jms; do
        unzip -o -j ${DOMIBUS_DISTRIBUTION}/domibus-distribution-*-default-${PLUGIN}-plugin.zip conf/domibus/plugins/lib/domibus-default-${PLUGIN}-plugin-*.jar -d ${CONF_PATH}/domibus/plugins/lib && \
        unzip -o -j ${DOMIBUS_DISTRIBUTION}/domibus-distribution-*-default-${PLUGIN}-plugin.zip conf/domibus/plugins/config/weblogic/* -d ${CONF_PATH}/domibus/plugins/config
    done
}

composeUp_C2_C3_WeblogicCluster() {
    echo "Compose up C2 and C3 Weblogic Cluster..."
    cd compose/test && docker-compose up -d
}

#
# main
#

echo "Unpackage C2 Domibus configuration..."

setDomibusVersion
prepareDomibusConf compose/test/c2/conf
prepareDomibusConf compose/test/c3/conf

composeUp_C2_C3_WeblogicCluster