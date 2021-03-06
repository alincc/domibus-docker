#!/usr/bin/env bash
#
# Clone and build Domibus repo
#

# Select the Domibus repository branch to build
# e.g.: DOMIBUS_BRANCH=development
DOMIBUS_BRANCH=development

cloneDomibus() {
    echo "Clone domibus $1 branch..."
    git clone https://ec.europa.eu/cefdigital/code/scm/edelivery/domibus.git ../domibus --branch $1 --depth 1
}

buildDomibus() {
    echo "Build domibus..."
    # Official build command for distribution
    #mvn -f domibus/pom.xml clean install -Ptomcat -Pweblogic -Pwildfly -Pdefault-plugins -Pdatabase -Psample-configuration -PUI -Pdistribution
    mvn -f ../domibus/pom.xml clean install -Pweblogic -Pdefault-plugins -Pdatabase -Psample-configuration -PUI -Pdistribution -DskipTests=true -DskipITs=true
}

#
# main
#

if [ ! -d "../domibus" ]; then
    source setEnvironment.sh && \
    cloneDomibus ${DOMIBUS_BRANCH} && \
    buildDomibus
else
    echo "Domibus was already built..."
fi
