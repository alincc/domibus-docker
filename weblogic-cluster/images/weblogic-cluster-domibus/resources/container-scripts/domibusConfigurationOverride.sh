#!/usr/bin/env bash

overrideWeblogicClusterProperties() {
    local FILE=${DOMAIN_HOME}/conf/domibus/scripts/WeblogicCluster.properties
    echo "Overriding Weblogic Cluster Default Properties: ${FILE}"

    cp -v ${FILE} "${FILE}.orig"
    chmod +x ${ORACLE_HOME}/conf-override/overrideWeblogicClusterProperties.sh
    ${ORACLE_HOME}/conf-override/overrideWeblogicClusterProperties.sh ${FILE}
    diff ${FILE} "${FILE}.orig"
}

overrideDomibusProperties() {
    local FILE=${DOMAIN_HOME}/conf/domibus/domibus.properties
    echo "Overriding Domibus Properties: ${FILE}"

    cp -v ${FILE} "${FILE}.orig"
    chmod +x ${ORACLE_HOME}/conf-override/overrideDomibusProperties.sh
    ${ORACLE_HOME}/conf-override/overrideDomibusProperties.sh ${FILE}
    diff ${FILE} "${FILE}.orig"
}

overrideFSPluginProperties() {
    local FILE=${DOMAIN_HOME}/conf/domibus/plugins/config/fs-plugin.properties
    echo "Overriding FS Plugin Properties: ${FILE}"

    cp -v ${FILE} "${FILE}.orig"
    chmod +x ${ORACLE_HOME}/conf-override/overrideFSPluginProperties.sh
    ${ORACLE_HOME}/conf-override/overrideFSPluginProperties.sh ${FILE}
    diff ${FILE} "${FILE}.orig"
}
