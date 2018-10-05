#!/bin/bash

echo ; echo "RECEIVED ARGs:"
echo "   PARTY_ID   = ${PARTY_ID}"
echo "   ARG DB_TYPE= ${DB_TYPE}"
echo "   ARG DB_HOST= ${DB_HOST}"
echo "   ARG DB_PORT= ${DB_PORT}"
echo "   ARG DB_NAME= ${DB_NAME}"
echo "   ARG DB_USER= ${DB_USER}"
echo "   ARG DB_PASS= ${DB_PASS}"

function displayFunctionBanner {
   echo ;
   echo "####################################################################"
   echo "### FUNCTION: $1"
   echo "####################################################################"
}

function quickFix01 {
   displayFunctionBanner ${FUNCNAME[0]}

   # quickFix ######################################
   cef_edelivery_path="/data/domibus"

   TEMP_DIR="/data/domibus/domibus/temp"
   mkdir ${TEMP_DIR}

   initialString="OracleDatabaseHost=oracle$"
   replacedString="OracleDatabaseHost=${DB_HOST}"
   targetFile="/data/domInstall/wil-ora-domibus.properties"
   echo "   Replacing : ${initialString}"
   echo "   By        : ${replacedString}"
   echo "   In file   : ${targetFile}"
   sed -i -e "s#${initialString}#${replacedString}#" ${targetFile}

   echo ; echo "Sourcing installation file: /data/domInstall/wil-ora-domibus.properties"
   . /data/domInstall/wil-ora-domibus.properties
   ####################################################
}

echo
echo "\${OracleDatabaseHost}=${OracleDatabaseHost}"
echo

function configureAppServerURL {
   displayFunctionBanner ${FUNCNAME[0]}

   echo "ApplicationServer=${ApplicationServer}"
   if [ "${1}" == "Tomcat" ] ; then appServerURL="domibus" ; fi
   if [ "${1}" == "WildFly" ] ; then appServerURL="domibus-wildfly" ; fi
   if [ "${1}" == "Weblogic" ] ; then appServerURL="domibus-weblogic" ; fi
}

function configureJava {
   displayFunctionBanner ${FUNCNAME[0]}

   export JAVA_HOME=/usr/local/java/jre1.7.0_80
   export PATH=${JAVA_HOME}/bin:${PATH}
}

function niceSleep {
   displayFunctionBanner ${FUNCNAME[0]}

   let waitTime=$1
   for i in $(eval echo "{0..${waitTime}..5}") ; do
      echo -n "${i}s"
      sleep 1
      for j in {1..4} ; do echo -n . ; sleep 1 ; done
   done
}

function configureDomibusProperties {
   displayFunctionBanner ${FUNCNAME[0]}

echo ; echo "Configuring Domibus as PARTY_ID: ${PARTY_ID}"

echo ; echo "Configuring Private Key Alias as ${PARTY_ID}_gw"
initialString="domibus.security.key.private.alias=blue_gw"
replacedString="domibus.security.key.private.alias=${PARTY_ID}_gw"
targetFile="/data/domibus/domibus/conf/domibus/domibus.properties"
echo "   Replacing : ${initialString}"
echo "   By        : ${replacedString}"
echo "   In file   : ${targetFile}"
sed -i -e "s#${initialString}#${replacedString}#" ${targetFile}
}

function updateNONXADatasourceWildFly {
   displayFunctionBanner ${FUNCNAME[0]}
   echo ; echo "Updating NON-XA Datasource in \$DOMIBUS_DIR/domibus/standalone/configuration/${WildFlyServerConfig}.xml"

   ${cef_edelivery_path}/domibus/bin/jboss-cli.sh << EOF

embed-server --server-config=${WildFlyServerConfig}.xml

/subsystem=datasources/data-source=eDeliveryOracleNonXADS:write-attribute(name=user-name,value=${OracleDatabaseUserId})
/subsystem=datasources/data-source=eDeliveryOracleNonXADS:write-attribute(name=password,value=${OracleDatabaseUserPassword})
/subsystem=datasources/data-source=eDeliveryOracleNonXADS:write-attribute(name=connection-url,value=jdbc:oracle:thin:@${OracleDatabaseHost}:${OracleDatabasePort}/${OracleDatabaseSID})

exit
EOF
}

function updateXADatasourceWildFly {
   displayFunctionBanner ${FUNCNAME[0]}
   echo ; echo "Updating XA Datasource in \$DOMIBUS_DIR/domibus/standalone/configuration/${WildFlyServerConfig}.xml"

   ${cef_edelivery_path}/domibus/bin/jboss-cli.sh << EOF

embed-server --server-config=${WildFlyServerConfig}.xml

/subsystem=datasources/xa-data-source=eDeliveryOracleXADS:write-attribute(name=user-name,value=${OracleDatabaseUserId})
/subsystem=datasources/xa-data-source=eDeliveryOracleXADS:write-attribute(name=password,value=${OracleDatabaseUserPassword})
/subsystem=datasources/xa-data-source=eDeliveryOracleXADS/xa-datasource-properties=URL:remove
/subsystem=datasources/xa-data-source=eDeliveryOracleXADS/xa-datasource-properties=URL:add(value=jdbc:oracle:thin:@${OracleDatabaseHost}:${OracleDatabasePort}/${OracleDatabaseSID})

exit
EOF
}

function updateDatasourcesWildFly {
   displayFunctionBanner ${FUNCNAME[0]}
   echo "move /data/domibus/domibus/standalone/configuration/standalone_xml_history/current"
   rm -rf /data/domibus/domibus/standalone/configuration/standalone_xml_history/current/* 
   updateNONXADatasourceWildFly
   rm -rf /data/domibus/domibus/standalone/configuration/standalone_xml_history/current/*   
   updateXADatasourceWildFly
   rm -rf /data/domibus/domibus/standalone/configuration/standalone_xml_history/current/*
}

function startDomibus {
   displayFunctionBanner ${FUNCNAME[0]}

   echo ; echo "Starting Domibus - WildFly: /data/domibus/domibus/bin/standalone.sh --server-config=standalone-full.xml"
   nohup /data/domibus/domibus/bin/standalone.sh --server-config=standalone-full.xml > /data/domibus/domibus/domibus.log 2>&1 &
}

function wait4Domibus {
   displayFunctionBanner ${FUNCNAME[0]}

#   while ! curl --output /dev/null --silent --head --fail http://localhost:8080/domibus/home ; do
   while ! curl -X POST --silent --output /dev/null \
         http://localhost:8080/domibus/rest/security/authentication \
         -i -H "Content-Type: application/json" \
         -d '{"username":"","password":""}' ; do
     sleep 1 && echo -n .
   done

#   echo ; echo "Waiting 30 second for all services to be started"
#   niceSleep 30

   echo ; echo "Waiting for message WFLYSRV0025 in /data/domibus/domibus/domibus.log..."
   while ! grep WFLYSRV0025 /data/domibus/domibus/domibus.log ; do
      echo -n . ; sleep 2
   done
}

function wait4OracleDatabase {

   SQLPLUS_HOME=/usr/local/Oracle/SQLPlus
   export LD_LIBRARY_PATH=${SQLPLUS_HOME}

   echo ; echo "Wait for Oracle Database to be ready"

   while [ ! "${OracleTableCheck}" == "admin" ] ; do
      OracleTableCheck=$(${SQLPLUS_HOME}/sqlplus -s edelivery/edelivery@${DB_HOST}:1521/XE << EOF | sed 's/[  ]//g'
      SET heading OFF;
      SET echo OFF;
      SET feedback OFF;
      set pagesize 0 feedback off verify off heading off echo off;
      select USER_NAME from TB_USER where ID_PK=1;
      exit;
EOF
)

   sleep 1
   echo -n "."
   done
}

function keepLooping {
   displayFunctionBanner ${FUNCNAME[0]}

   while true ; do sleep 1 ; done
}

function configurePmode4Tests {
    displayFunctionBanner ${FUNCNAME[0]}

    applicationServer=$1

    appServerURL_blue = ${appServerURL}
    appServerURL_red = ${appServerURL}

    echo ; echo "Configuring:  Domibus pModes"

    targetFileBlue="/data/domInstall/domibus-gw-sample-pmode-blue.xml"
    targetFileRed="/data/domInstall/domibus-gw-sample-pmode-red.xml"

    initialString="endpoint=\"http://localhost:8080/domibus/services/msh\""
    replacedString="endpoint=\"http://domibus_blue:8080/${appServerURL}/services/msh\""
    echo "   Replacing : ${initialString}"
    echo "   By        : ${replacedString}"
    echo "   In files   : ${targetFileBlue} and ${targetFileRed}"
    sed -i -e "s#${initialString}#${replacedString}#" ${targetFileBlue}
    sed -i -e "s#${initialString}#${replacedString}#" ${targetFileRed}

    initialString="endpoint=\"http://localhost:8180/domibus/services/msh\""
    replacedString="endpoint=\"http://domibus_red:8080/${appServerURL}/services/msh\""
    echo "   Replacing : ${initialString}"
    echo "   By        : ${replacedString}"
    echo "   In files   : ${targetFileBlue} and ${targetFileRed}"
    sed -i -e "s#${initialString}#${replacedString}#" ${targetFileBlue}
    sed -i -e "s#${initialString}#${replacedString}#" ${targetFileRed}

}

function uploadPmode {
   displayFunctionBanner ${FUNCNAME[0]}


   if [ "${pmodeFile2Upload}" == "" ] ; then
    pmodeFile2Upload="/data/domInstall/domibus-gw-sample-pmode-blue.xml"
   fi
   echo ; echo "Uploadling Pmode ${pmodeFile2Upload}"

   echo "Uploading ${pmodeFile2Upload}"
   echo "   Loging to Domibus to obtain cookies"
   curl http://localhost:8080/${appServerURL}/rest/security/authentication \
   -i \
   -H "Content-Type: application/json" \
   -X POST -d '{"username":"admin","password":"123456"}' \
   -c ${TEMP_DIR}/cookie.txt


   JSESSIONID=`grep JSESSIONID ${TEMP_DIR}/cookie.txt |  cut -d$'\t' -f 7`
   XSRFTOKEN=`grep XSRF-TOKEN ${TEMP_DIR}/cookie.txt |  cut -d$'\t' -f 7`

   echo ; echo
   echo "   JSESSIONID=${JSESSIONID}"
   echo "   XSRFTOKEN=${XSRFTOKEN}"
   echo  "  X-XSRF-TOKEN: ${XSRFTOKEN}"

   echo ; echo "   Uploading Pmode"

   curl http://localhost:8080/${appServerURL}/rest/pmode \
   -b ${TEMP_DIR}/cookie.txt \
   -v \
   -H "X-XSRF-TOKEN: ${XSRFTOKEN}" \
   -F  file=@${pmodeFile2Upload}
}

##########################################################################
# MAIN PROGRAMM STARTS HERE
##########################################################################

quickFix01
configureAppServerURL WildFly
configureJava
updateDatasourcesWildFly
#Quick Fix Using SED
#QF_updateDatasourcesSED
#configureDomibusProperties
wait4OracleDatabase
startDomibus
wait4Domibus
configurePmode4Tests WildFly
uploadPmode
keepLooping

