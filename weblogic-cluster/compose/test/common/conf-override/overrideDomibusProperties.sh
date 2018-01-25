#!/usr/bin/env bash

FILE=$1

sed -i "s/^domibus.deployment.clustered=.*/domibus.deployment.clustered=true/g" ${FILE} && \
sed -i "s/^domibus.security.key.private.alias=.*/domibus.security.key.private.alias=${PARTY_NAME}/g" ${FILE} && \
sed -i "s/^domibus.jmx.user=.*/domibus.jmx.user=weblogic/g" ${FILE} && \
sed -i "s/^domibus.jmx.password=.*/domibus.jmx.password=${ADMIN_PASSWORD}/g" ${FILE}