#!/usr/bin/env bash

setDomibusVersion() {
    echo "Get domibus version from pom file..."
    export DOMIBUS_VERSION=$(mvn -f domibus/pom.xml -q -Dexec.executable="echo" -Dexec.args='${project.version}' --non-recursive exec:exec)
    export DOMIBUS_SHORT_VERSION=${DOMIBUS_VERSION/-SNAPSHOT/}

    echo "DOMIBUS_VERSION: ${DOMIBUS_VERSION}"
    echo "DOMIBUS_SHORT_VERSION: ${DOMIBUS_SHORT_VERSION}"
}