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

#
# main
#

DOMIBUS_BRANCH=development

if [ ! -d "domibus" ]; then
    cloneDomibus
    buildDomibus
else
    echo "Domibus was already built..."
fi