#!/usr/bin/env bash

updateWeblogicClusterProperties() {
    local FILE=${ORACLE_HOME}/wslt-api-1.9.1/WeblogicCluster.properties
    echo "Overriding Weblogic Cluster Default Properties: ${FILE}"

    cp -v ${FILE} "${FILE}.orig"
    chmod +x ${ORACLE_HOME}/conf-override/overrideWeblogicClusterProperties.sh
    ${ORACLE_HOME}/conf-override/overrideWeblogicClusterProperties.sh ${FILE}
    diff ${FILE} "${FILE}.orig"
}

updateDomibusProperties() {
    local FILE=${DOMAIN_HOME}/conf/domibus/domibus.properties
    echo "Overriding Domibus Properties: ${FILE}"

    cp -v ${FILE} "${FILE}.orig"
    chmod +x ${ORACLE_HOME}/conf-override/overrideDomibusProperties.sh
    ${ORACLE_HOME}/conf-override/overrideDomibusProperties.sh ${FILE}
    diff ${FILE} "${FILE}.orig"
}

updateFSPluginProperties() {
    local FILE=${DOMAIN_HOME}/conf/domibus/plugins/config/fs-plugin.properties
    echo "Overriding FS Plugin Properties: ${FILE}"

    cp -v ${FILE} "${FILE}.orig"
    chmod +x ${ORACLE_HOME}/conf-override/overrideFSPluginProperties.sh
    ${ORACLE_HOME}/conf-override/overrideFSPluginProperties.sh ${FILE}
    diff ${FILE} "${FILE}.orig"
}
