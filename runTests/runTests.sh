#!/bin/bash -ex

DOMIBUS_ARTEFACTS=${1}
localUrl=${2}
remoteUrl=${3}
allDomainsProperties=${4}
jacocoRemotePortBlue=${5}
jacocoRemoteAddressBlue=${6}
jacocoRemotePortRed=${7}
jacocoRemoteAddressRed=${8}

ADMIN_USER="admin"
ADMIN_PASSW="123456"

# To be replaced with a Curl Loop
echo ; echo "Waiting 180 seconds..."
sleep 180

echo ; echo "Starting SoapUI Tests with the following Parameters:"
echo "   ${DOMIBUS_ARTEFACTS}"
echo "   mvn clean install -Psoapui \\"
echo "   -DlocalUrl=${localUrl}                 \\"
echo "   -DremoteUrl=${remoteUrl}               \\"
echo "   -DallDomainsProperties=${allDomainsProperties}           \\"
echo "   -DjacocoRemotePortBlue=${jacocoRemotePortBlue}       \\"
echo "   -DjacocoRemoteAddressBlue=${jacocoRemoteAddressBlue}       \\"
echo "   -DjacocoRemotePortRed=${jacocoRemotePortRed}       \\"
echo "   -DjacocoRemoteAddressRed=${jacocoRemoteAddressRed}"

mvn clean install -Psoapui \
-DlocalUrl="${localUrl}"                \
-DremoteUrl="${remoteUrl}"              \
-DallDomainsProperties="${allDomainsProperties}"          \
-DjacocoRemotePortBlue=${jacocoRemotePortBlue}       \
-DjacocoRemoteAddressBlue=${jacocoRemoteAddressBlue}       \
-DjacocoRemotePortRed=${jacocoRemotePortRed}       \
-DjacocoRemoteAddressRed=${jacocoRemoteAddressRed}
