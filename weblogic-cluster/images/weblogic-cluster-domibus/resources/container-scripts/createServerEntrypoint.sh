#!/bin/bash
#
# WebLogic Server Entrypoint
#
# Since: November, 2017
# Author: FERNANDES Henrique
#
# =============================

dockerizeTemplates() {
    echo "Dockerizing templates..."
    dockerize -template ${DOMAIN_HOME}/conf/domibus/domibus.properties.tmpl > ${DOMAIN_HOME}/conf/domibus/domibus.properties && \
    dockerize -template ${DOMAIN_HOME}/conf/domibus/plugins/config/fs-plugin.properties.tmpl > ${DOMAIN_HOME}/conf/domibus/plugins/config/fs-plugin.properties
}

dockerizeTemplates

echo "Calling createServer.sh..."
/u01/oracle/createServer.sh
