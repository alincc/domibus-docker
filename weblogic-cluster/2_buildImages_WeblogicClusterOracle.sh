#!/usr/bin/env bash

source common.sh

copyDomibusDistributionImageResources() {
    setDomibusVersion

    echo "Copy domibus distribution artifacts..."
    ORIGIN_DIST=domibus/Domibus-MSH-distribution/target
    # oraclexe-domibus/resources
    cp ${ORIGIN_DIST}/domibus-distribution-${DOMIBUS_VERSION}-sql-scripts.zip images/oraclexe-domibus/resources && \
    # weblogic-cluster-domibus/resources
    cp ${ORIGIN_DIST}/domibus-distribution-${DOMIBUS_VERSION}-default-fs-plugin.zip images/weblogic-cluster-domibus/resources && \
    cp ${ORIGIN_DIST}/domibus-distribution-${DOMIBUS_VERSION}-default-jms-plugin.zip images/weblogic-cluster-domibus/resources && \
    cp ${ORIGIN_DIST}/domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip images/weblogic-cluster-domibus/resources && \
    cp ${ORIGIN_DIST}/domibus-distribution-${DOMIBUS_VERSION}-sample-configuration-and-testing.zip images/weblogic-cluster-domibus/resources && \
    cp ${ORIGIN_DIST}/domibus-distribution-${DOMIBUS_VERSION}-weblogic-configuration.zip images/weblogic-cluster-domibus/resources && \
    cp ${ORIGIN_DIST}/domibus-distribution-${DOMIBUS_VERSION}-weblogic-war.zip images/weblogic-cluster-domibus/resources
}

composeBuildWeblogicClusterImages() {
    echo "Compose build Weblogic Cluster Images..."
    cd images && docker-compose -f docker-compose.build.yml build
}

#
# main
#
export USER_ID=$(id -u $USER)

copyDomibusDistributionImageResources
composeBuildWeblogicClusterImages