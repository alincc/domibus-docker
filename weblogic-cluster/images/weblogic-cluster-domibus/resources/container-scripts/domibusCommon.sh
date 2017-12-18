#!/usr/bin/env bash

updateWeblogicClusterProperties() {
    WEBLOGIC_CLUSTER_PROPERTIES=${ORACLE_HOME}/wslt-api-1.9.1/WeblogicCluster.properties

    echo "Updating Weblogic Cluster Properties: ${WEBLOGIC_CLUSTER_PROPERTIES}"

    sed -i "s/^script.log.file =/script.log.file = WeblogicClusterImport.log/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^domain.connect.url =/domain.connect.url =t3:\/\/${ADMIN_HOST}:${ADMIN_PORT}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^domain.connect.username =/domain.connect.username =${ADMIN_USERNAME}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^domain.connect.password =/domain.connect.password =${ADMIN_PASSWORD}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^domain.name =/domain.name =${DOMAIN_NAME}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^jms.module.0.targets=.*/jms.module.0.targets=${CLUSTER_NAME}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^jms.server.0.target=.*/jms.server.0.target=${CLUSTER_NAME}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^jdbc.datasource.0.targets=.*/jdbc.datasource.0.targets=${CLUSTER_NAME}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^jdbc.datasource.0.driver.url=/jdbc.datasource.0.driver.url=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}:xe/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^jdbc.datasource.0.driver.username=/jdbc.datasource.0.driver.username=domibus/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^jdbc.datasource.0.driver.password=/jdbc.datasource.0.driver.password=${DOMIBUS_PASSWORD}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^jdbc.datasource.1.targets=.*/jdbc.datasource.1.targets=${CLUSTER_NAME}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^jdbc.datasource.1.driver.url=/jdbc.datasource.1.driver.url=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}:xe/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^jdbc.datasource.1.driver.username=/jdbc.datasource.1.driver.username=domibus/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^jdbc.datasource.1.driver.password=/jdbc.datasource.1.driver.password=${DOMIBUS_PASSWORD}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s/^persistent.filestore.0.target=.*/persistent.filestore.0.target=${CLUSTER_NAME}/g" ${WEBLOGIC_CLUSTER_PROPERTIES} && \
    sed -i "s#^persistent.filestore.0.location=#persistent.filestore.0.location=${DOMAIN_HOME}/filestores/persistent_filestore#g" ${WEBLOGIC_CLUSTER_PROPERTIES}
}

updateDomibusProperties() {
    DOMIBUS_PROPERTIES=${DOMAIN_HOME}/conf/domibus/domibus.properties

    echo "Updating Domibus Properties: ${DOMIBUS_PROPERTIES}"
    sed -i "s/^domibus.deployment.clustered=.*/domibus.deployment.clustered=true/g" ${DOMIBUS_PROPERTIES} && \
    sed -i "s/^domibus.security.key.private.alias=.*/domibus.security.key.private.alias=${PARTY_NAME}/g" ${DOMIBUS_PROPERTIES} && \
    sed -i "s/^domibus.jmx.user=.*/domibus.jmx.user=weblogic/g" ${DOMIBUS_PROPERTIES} && \
    sed -i "s/^domibus.jmx.password=.*/domibus.jmx.password=${ADMIN_PASSWORD}/g" ${DOMIBUS_PROPERTIES}
}

updateFSPluginProperties() {
    FSPLUGIN_PROPERTIES=${DOMAIN_HOME}/conf/domibus/plugins/config/fs-plugin.properties

    echo "Updating FS Plugin Properties: ${FSPLUGIN_PROPERTIES}"
    sed -i "s#^fsplugin.messages.location=.*#fsplugin.messages.location=${DOMAIN_HOME}/filestores/fs_plugin_data#g" ${DOMAIN_HOME}/conf/domibus/plugins/config/fs-plugin.properties
}
