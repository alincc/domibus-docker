#!/bin/bash
#
# WebLogic Server Entrypoint
#
# Since: November, 2017
# Author: FERNANDES Henrique
#
# =============================

source domibusCommon.sh

updateDomibusProperties
updateFSPluginProperties

echo "Calling createServer.sh..."
/u01/oracle/createServer.sh
