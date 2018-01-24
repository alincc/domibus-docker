#!/usr/bin/env bash

FILE=$1

sed -i "s#^fsplugin.messages.location=.*#fsplugin.messages.location=${DOMAIN_HOME}/fs_plugin_data/MAIN#g" ${DOMAIN_HOME}/conf/domibus/plugins/config/fs-plugin.properties