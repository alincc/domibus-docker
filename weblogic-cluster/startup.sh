#!/usr/bin/env bash

cloneDomibus() {
    echo "Clone domibus development branch..."
    git clone https://ec.europa.eu/cefdigital/code/scm/edelivery/domibus.git domibus --branch ${DOMIBUS_BRANCH} --depth 1
}

buildDomibus() {
    echo "Build domibus..."
    # TODO: Replace with official build command for distribution
    #mvn -f domibus/pom.xml clean install -Ptomcat -Pweblogic -Pwildfly -Pdefault-plugins -Pdatabase -Psample-configuration -PUI -Pdistribution
    mvn -f domibus/pom.xml clean install -Pweblogic -Pdefault-plugins -Pdatabase -Psample-configuration -PUI -Pdistribution -DskipTests=true -DskipITs=true
}

setDomibusVersion() {
    echo "Get domibus version from pom file..."
    export DOMIBUS_VERSION=$(mvn -f domibus/pom.xml -q -Dexec.executable="echo" -Dexec.args='${project.version}' --non-recursive exec:exec)
    export DOMIBUS_SHORT_VERSION=${DOMIBUS_VERSION/-SNAPSHOT/}

    echo "DOMIBUS_VERSION: ${DOMIBUS_VERSION}"
    echo "DOMIBUS_SHORT_VERSION: ${DOMIBUS_SHORT_VERSION}"
}

copyDomibusDistributionImageResources() {
    setDomibusVersion

    echo "Copy domibus distribution artifacts..."
    ORIGIN_DIST=${BASE}/domibus/Domibus-MSH-distribution/target
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

copyDomibusConfigurationPolicies() {
    echo "Copy domibus configuration policies..."
    ORIGIN_POLICIES=${BASE}/domibus/Domibus-MSH/src/main/conf/domibus/policies
    DEST_POLICIES=${BASE}/compose/test/common/conf/domibus/policies/
    cp ${ORIGIN_POLICIES}/doNothingPolicy.xml ${DEST_POLICIES} && \
    cp ${ORIGIN_POLICIES}/encryptAll.xml ${DEST_POLICIES} && \
    cp ${ORIGIN_POLICIES}/signEncrypt.xml ${DEST_POLICIES} && \
    cp ${ORIGIN_POLICIES}/signOnly.xml ${DEST_POLICIES}
}

composeBuildWeblogicClusterImages() {
    echo "Compose build Weblogic Cluster Images..."
    cd ${BASE}/images && docker-compose -f docker-compose.build.yml build
}

composeUp_C2_C3_WeblogicCluster() {
    echo "Compose up C2 and C3 Weblogic Cluster..."
    cd ${BASE}/compose/test/ && docker-compose up -d && docker-compose logs -f
}

#
# main
#

DOMIBUS_BRANCH=development
BASE=$(pwd)

if [ ! -d "domibus" ]; then
    cloneDomibus
    buildDomibus
    copyDomibusDistributionImageResources
else
    setDomibusVersion
fi

composeBuildWeblogicClusterImages
copyDomibusConfigurationPolicies
composeUp_C2_C3_WeblogicCluster