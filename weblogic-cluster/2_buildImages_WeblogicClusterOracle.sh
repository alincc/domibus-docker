#!/usr/bin/env bash

source common.sh
source setEnvironment.sh

copyExternalImageResources() {
    echo "Copy images external resources..."

    # images/edelivery-weblogic-cluster/resources
    cp ${REPO}/fmw_12.1.3.0.0_wls.jar images/edelivery-weblogic-cluster/resources && \
    cp ${REPO}/dockerize-linux-amd64-v0.6.0.tar.gz images/edelivery-weblogic-cluster/resources && \
    cp ${REPO}/Oracle/Java/jdk-8u144-linux-x64.tar.gz images/edelivery-weblogic-cluster/resources && \
    # images/weblogic-cluster-domibus/resources
    cp ${REPO}/Oracle/wslt-api-1.9.1.zip images/weblogic-cluster-domibus/resources
}

copyDomibusDistributionImageResources() {
    setDomibusVersion

    echo "Copy domibus distribution artifacts..."
    local ORIGIN_DIST=domibus/Domibus-MSH-distribution/target
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

copyExternalImageResources
copyDomibusDistributionImageResources
composeBuildWeblogicClusterImages