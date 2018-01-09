#!/usr/bin/env bash

FILE=$1

sed -i "s/^script.log.file =/script.log.file = WeblogicClusterImport.log/g" ${FILE} && \
sed -i "s/^domain.connect.url =/domain.connect.url =t3:\/\/${ADMIN_HOST}:${ADMIN_PORT}/g" ${FILE} && \
sed -i "s/^domain.connect.username =/domain.connect.username =${ADMIN_USERNAME}/g" ${FILE} && \
sed -i "s/^domain.connect.password =/domain.connect.password =${ADMIN_PASSWORD}/g" ${FILE} && \
sed -i "s/^domain.name =/domain.name =${DOMAIN_NAME}/g" ${FILE} && \
sed -i "s/^jms.module.0.targets=.*/jms.module.0.targets=${CLUSTER_NAME}/g" ${FILE} && \
sed -i "s/^jms.server.0.target=.*/jms.server.0.target=${CLUSTER_NAME}/g" ${FILE} && \
sed -i "s/^jdbc.datasource.0.targets=.*/jdbc.datasource.0.targets=${CLUSTER_NAME}/g" ${FILE} && \
sed -i "s/^jdbc.datasource.0.driver.url=/jdbc.datasource.0.driver.url=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}:xe/g" ${FILE} && \
sed -i "s/^jdbc.datasource.0.driver.username=/jdbc.datasource.0.driver.username=domibus/g" ${FILE} && \
sed -i "s/^jdbc.datasource.0.driver.password=/jdbc.datasource.0.driver.password=${DOMIBUS_PASSWORD}/g" ${FILE} && \
sed -i "s/^jdbc.datasource.1.targets=.*/jdbc.datasource.1.targets=${CLUSTER_NAME}/g" ${FILE} && \
sed -i "s/^jdbc.datasource.1.driver.url=/jdbc.datasource.1.driver.url=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}:xe/g" ${FILE} && \
sed -i "s/^jdbc.datasource.1.driver.username=/jdbc.datasource.1.driver.username=domibus/g" ${FILE} && \
sed -i "s/^jdbc.datasource.1.driver.password=/jdbc.datasource.1.driver.password=${DOMIBUS_PASSWORD}/g" ${FILE} && \
sed -i "s/^persistent.filestore.0.target=.*/persistent.filestore.0.target=${CLUSTER_NAME}/g" ${FILE} && \
sed -i "s#^persistent.filestore.0.location=#persistent.filestore.0.location=${DOMAIN_HOME}/persistent_filestore#g" ${FILE}