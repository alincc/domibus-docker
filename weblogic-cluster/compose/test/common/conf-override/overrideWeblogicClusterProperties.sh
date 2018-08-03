#!/usr/bin/env bash

FILE=$1

sed -i "s/^script.log.file =/script.log.file = WeblogicClusterImport.log/g" ${FILE} && \
sed -i "s/^domain.connect.url =/domain.connect.url =t3:\/\/${ADMIN_HOST}:${ADMIN_PORT}/g" ${FILE} && \
sed -i "s/^domain.connect.username =/domain.connect.username =${ADMIN_USERNAME}/g" ${FILE} && \
sed -i "s/^domain.connect.password =/domain.connect.password =${ADMIN_PASSWORD}/g" ${FILE} && \
sed -i "s/^domain.name =/domain.name =${DOMAIN_NAME}/g" ${FILE} && \
sed -i "s/^application.module.target=.*/application.module.target=${CLUSTER_NAME}/g" ${FILE} && \
sed -i "s/^jdbc.datasource.driver.url=/jdbc.datasource.driver.url=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}:xe/g" ${FILE} && \
sed -i "s/^jdbc.datasource.driver.username=/jdbc.datasource.driver.username=domibus/g" ${FILE} && \
sed -i "s/^jdbc.datasource.driver.password=/jdbc.datasource.driver.password=${DOMIBUS_PASSWORD}/g" ${FILE} && \
sed -i "s#^persistent.filestore.0.location=#persistent.filestore.0.location=${DOMAIN_HOME}/persistent_filestore#g" ${FILE}
