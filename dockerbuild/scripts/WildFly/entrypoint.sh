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

   initialString="MySQLDatabaseHost=mysql$"
   replacedString="MySQLDatabaseHost=${DB_HOST}"
   targetFile="/data/domInstall/wil-mys-domibus.properties"
   echo "   Replacing : ${initialString}"
   echo "   By        : ${replacedString}"
   echo "   In file   : ${targetFile}"
   sed -i -e "s#${initialString}#${replacedString}#" ${targetFile}

   echo ; echo "Sourcing installation file: /data/domInstall/wil-mys-domibus.properties"
   . /data/domInstall/wil-mys-domibus.properties
   ####################################################
}

echo
echo "\${MySQLDatabaseHost}=${MySQLDatabaseHost}"
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

/subsystem=datasources/data-source=eDeliveryMysqlNonXADS:write-attribute(name=user-name,value=${MySQLDatabaseUserId})
/subsystem=datasources/data-source=eDeliveryMysqlNonXADS:write-attribute(name=password,value=${MySQLDatabaseUserPassword})
/subsystem=datasources/data-source=eDeliveryMysqlNonXADS:write-attribute(name=connection-url,value=jdbc:mysql://${MySQLDatabaseHost}:${MySQLDatabasePort}/${MySQLDatabaseName})

exit
EOF
}

function updateXADatasourceWildFly {
   displayFunctionBanner ${FUNCNAME[0]}
   echo ; echo "Updating XA Datasource in \$DOMIBUS_DIR/domibus/standalone/configuration/${WildFlyServerConfig}.xml"

   ${cef_edelivery_path}/domibus/bin/jboss-cli.sh << EOF

embed-server --server-config=${WildFlyServerConfig}.xml

#/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS/xa-datasource-properties=ServerName:write(value=${MySQLDatabaseHost})
#/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS/xa-datasource-properties=PortNumber:write-attribute(value=${MySQLDatabasePort})
/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS/xa-datasource-properties=ServerName:remove
/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS/xa-datasource-properties=ServerName:add(value=${MySQLDatabaseHost})
#/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS/xa-datasource-properties=PortNumber:write-attribute(value=${MySQLDatabasePort})
/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS/xa-datasource-properties=PortNumber:remove
/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS/xa-datasource-properties=PortNumber:add(value=${MySQLDatabasePort})
#/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS:write-attribute(name=DatabaseName,value=${MySQLDatabaseName})
/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS/xa-datasource-properties=DatabaseName:remove
/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS/xa-datasource-properties=DatabaseName:add(value=${MySQLDatabaseName})
/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS:write-attribute(name=user-name,value=${MySQLDatabaseUserId})
/subsystem=datasources/xa-data-source=eDeliveryMysqlXADS:write-attribute(name=password,value=${MySQLDatabaseUserPassword})

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

function QF_updateDatasourcesSED {
   displayFunctionBanner ${FUNCNAME[0]}
   echo; echo "   sed -i -e 's#mysql$#${DB_HOST}#g'	${cef_edelivery_path}/domibus/standalone/configuration/${WildFlyServerConfig}.xml"
   sed -i -e 's#mysql$#${DB_HOST}#g'			${cef_edelivery_path}/domibus/standalone/configuration/${WildFlyServerConfig}.xml
   echo

   echo ; echo "   sed -i -e 's#<connection-url>jdbc:mysql://mysql:#<connection-url>jdbc:mysql://${DB_HOST}:#g'	${cef_edelivery_path}/domibus/standalone/configuration/${WildFlyServerConfig}.xml"
   sed -i -e 's#<connection-url>jdbc:mysql://mysql:#<connection-url>jdbc:mysql://${DB_HOST}:#g'			${cef_edelivery_path}/domibus/standalone/configuration/${WildFlyServerConfig}.xml
   echo

   #sed -i -e 's#:3306/domibus</connection-url>#:${MySQLDatabasePort}/domibus</connection-url>#g'		${cef_edelivery_path}/domibus/standalone/configuration/${WildFlyServerConfig}.xml
   #sed -i -e 's#<user-name>edelivery</user-name>#<user-name>${MySQLDatabaseUserId}</user-name>g'	 	${cef_edelivery_path}/domibus/standalone/configuration/${WildFlyServerConfig}.xml
   #sed -i -e 's#<password>edelivery</password>#<password>${MySQLDatabaseUserPassword}</password>'		${cef_edelivery_path}/domibus/standalone/configuration/${WildFlyServerConfig}.xml
}


function waitForMySQLDatabase {

   echo ; echo "Wait for MySQL Database to be ready"

   while [ ! "${MySQLTableCheck}" == "admin" ] ; do
      MySQLTableCheck=$(mysql -sN -h${DB_HOST} -uedelivery -pedelivery domibus 2> /dev/null << EOF | sed 's/[  ]//g'
      select USER_NAME from TB_USER where ID_PK=1;
EOF
)

   sleep 1
   echo -n "."
   done
}

function startDomibus {
   displayFunctionBanner ${FUNCNAME[0]}

   echo ; echo "Starting Domibus - WildFly: /data/domibus/domibus/bin/standalone.sh --server-config=standalone-full.xml"
   nohup /data/domibus/domibus/bin/standalone.sh --server-config=standalone-full.xml > /data/domibus/domibus/domibus.log 2>&1 &
}

function Wait4Domibus {
   displayFunctionBanner ${FUNCNAME[0]}

#   while ! curl --output /dev/null --silent --head --fail http://localhost:8080/domibus-wildfly/home ; do
   while ! curl -X POST --silent --output /dev/null \
         http://localhost:8080/domibus-wildfly/rest/security/authentication \
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
waitForMySQLDatabase
#configureDomibusProperties
startDomibus
Wait4Domibus
configurePmode4Tests WildFly
uploadPmode
keepLooping

