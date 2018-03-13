#!/bin/bash -ex

DOMIBUS_ARTEFACTS=${1}
localUrl=${2}
remoteUrl=${3}
jdbcUrlBlue=${4}
jdbcUrlRed=${5}
driverBlue=${6}
driverRed=${7}
databaseBlue=${8}
databaseRed=${9}
blueDbUser=${10}
redDbUser=${11}
blueDbPassword=${12}
redDbPassword=${13}
jacocoRemotePortBlue=${14}
jacocoRemoteAddressBlue=${15}
jacocoRemotePortRed=${16}
jacocoRemoteAddressRed=${17}

ADMIN_USER="admin"
ADMIN_PASSW="123456"

# To be replaced with a Curl Loop
echo ; echo "Waiting 180 seconds..."
sleep 180

echo ; echo "Starting SoaUI Tests with the following Parameters:"
echo "   ${DOMIBUS_ARTEFACTS}"
echo "   mvn com.smartbear.soapui:soapui-pro-maven-plugin:5.1.2:test \\"
echo "   -DlocalUrl=${localUrl}                 \\"
echo "   -DremoteUrl=${remoteUrl}               \\"
echo "   -DjdbcUrlBlue=${jdbcUrlBlue}           \\"
echo "   -DjdbcUrlRed=${jdbcUrlRed}             \\"
echo "   -DdriverBlue=${driverBlue}             \\"
echo "   -DdriverRed=${driverRed}               \\"
echo "   -DdatabaseBlue=${databaseBlue}         \\"
echo "   -DdatabaseRed=${databaseRed}           \\"
echo "   -DblueDbUser=${blueDbUser}             \\"
echo "   -DredDbUser=${redDbUser}               \\"
echo "   -DblueDbPassword=${blueDbPassword}     \\"
echo "   -DredDbPassword=${redDbPassword}       \\"
echo "   -DjacocoRemotePortBlue=${jacocoRemotePortBlue}       \\"
echo "   -DjacocoRemoteAddressBlue=${jacocoRemoteAddressBlue}       \\"
echo "   -DjacocoRemotePortRed=${jacocoRemotePortRed}       \\"
echo "   -DjacocoRemoteAddressRed=${jacocoRemoteAddressRed}"

#mvn com.smartbear.soapui:soapui-pro-maven-plugin:5.1.2:test \
mvn -Psoapui \
-DlocalUrl="${localUrl}"                \
-DremoteUrl="${remoteUrl}"              \
-DjdbcUrlBlue="${jdbcUrlBlue}"          \
-DjdbcUrlRed="${jdbcUrlRed}"            \
-DdriverBlue="${driverBlue}"            \
-DdriverRed="${driverRed}"              \
-DdatabaseBlue="${databaseBlue}"        \
-DdatabaseRed="${databaseRed}"          \
-DblueDbUser="${blueDbUser}"            \
-DredDbUser="${redDbUser}"              \
-DblueDbPassword="${blueDbPassword}"    \
-DredDbPassword="${redDbPassword}"  \
-DjacocoRemotePortBlue=${jacocoRemotePortBlue}       \
-DjacocoRemoteAddressBlue=${jacocoRemoteAddressBlue}       \
-DjacocoRemotePortRed=${jacocoRemotePortRed}       \
-DjacocoRemoteAddressRed=${jacocoRemoteAddressRed}
