#
# Script to Create userConfigFile and userKeyFile
#
# Since: November, 2017
# Author: FERNANDES Henrique

# Disable user confirmation with: export CONFIG_JVM_ARGS="-Dweblogic.management.confirmKeyfileCreation=true"
# =============================
execfile('/u01/oracle/commonfuncs.py')

# Connect to AdminServer
connect(admin_username, admin_password, 't3://'+admin_host+':'+admin_port)
storeUserConfig('weblogicConfigFile.secure', 'weblogicKeyFile.secure')

exit()
