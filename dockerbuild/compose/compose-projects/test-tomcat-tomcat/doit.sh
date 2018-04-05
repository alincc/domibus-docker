#!/usr/bin/env bash

export DOMIBUS_VERSION=4.0-SNAPSHOT
DOMIBUS_DISTRIBUTION=/c/Work/Devel/Java/Project/Source/domibus/Domibus-MSH-distribution/target
DOMIBUS_CONFIG_LOCATION=/c/Work/Devel/Java/Project/Source/docker/dockerbuild/compose/domibus-configs/tomcat/domibus_red/domibus

unzip -j -o $DOMIBUS_DISTRIBUTION/domibus-distribution-$DOMIBUS_VERSION-tomcat-configuration.zip domibus.properties -d $DOMIBUS_CONFIG_LOCATION/
unzip -j -o $DOMIBUS_DISTRIBUTION/domibus-distribution-$DOMIBUS_VERSION-default-ws-plugin.zip conf/domibus/plugins/config/tomcat/* -d $DOMIBUS_CONFIG_LOCATION/plugins/config
unzip -j -o $DOMIBUS_DISTRIBUTION/domibus-distribution-$DOMIBUS_VERSION-default-ws-plugin.zip conf/domibus/plugins/lib/* -d $DOMIBUS_CONFIG_LOCATION/plugins/lib

domibusVersionLowerCase="`echo ${DOMIBUS_VERSION} | tr '[:upper:]' '[:lower:]'`"
export DOMIBUS_VERSION=${domibusVersionLowerCase}

# Start docker-compose Plan
docker-compose up -d
