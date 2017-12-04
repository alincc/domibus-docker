#!/bin/bash

echo ; echo "Sourcing domInstall Common Functions"
. /data/domInstall/scripts/functions/common.functions

echo ; echo "RECEIVED Parameters:"
echo "   WORKING_DIR             : ${WORKING_DIR}"
echo "   DOMINSTALL_PROPERTYFILE : ${DOMINSTALL_PROPERTYFILE}"
echo "   PARTY_ID                : ${PARTY_ID}"
echo "   DB_TYPE                 : ${DB_TYPE}"
echo "   DB_HOST                 : ${DB_HOST}"
echo "   DB_PORT                 : ${DB_PORT}"
echo "   DB_NAME                 : ${DB_NAME}"
echo "   DB_USER                 : ${DB_USER}"
echo "   DB_PASS                 : ${DB_PASS}"

function quickFix01 {
   displayFunctionBanner ${FUNCNAME[0]}

# quickFix ######################################
cef_edelivery_path="/data/domibus"

TEMP_DIR="/data/domibus/domibus/temp"
mkdir ${TEMP_DIR}


if [ "${DB_TYPE}" == "MySQL" ] ; then
   echo ; echo "Sourcing installation file: /data/domInstall/tom-mys-domibus.properties"
   . /data/domInstall/tom-mys-domibus.properties
fi
if [ "${DB_TYPE}" == "Oracle" ] ; then
   echo ; echo "Sourcing installation file: /data/domInstall/tom-ora-domibus.properties"
   . /data/domInstall/tom-ora-domibus.properties
fi
####################################################
}

function WaitForOracleDatabase {
   displayFunctionBanner ${FUNCNAME[0]}

   SQLPLUS_HOME=/usr/local/Oracle/SQLPlus
   export LD_LIBRARY_PATH=${SQLPLUS_HOME}

   echo ; echo "Wait for Oracle Database to be ready (${DB_HOST}:${DB_PORT}/${DB_NAME})"

   while [ ! "${OracleTableCheck}" == "admin" ] ; do
      OracleTableCheck=$(${SQLPLUS_HOME}/sqlplus -s ${DB_USER}/${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME} << EOF | sed 's/[  ]//g'
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

function waitForDatabase {
   displayFunctionBanner ${FUNCNAME[0]}

   if [ "${DB_TYPE}" == "MySQL" ] ; then
      waitForMySQLDatabase
      #echo "DO NOT WAIT for MySQL for now..."
   fi
   if [ "${DB_TYPE}" == "Oracle" ] ; then
      WaitForOracleDatabase
   fi
}

function configureAppServerURL {
   displayFunctionBanner ${FUNCNAME[0]}

   echo "ApplicationServer=${ApplicationServer}"
   if [ "${1}" == "Tomcat" ] ; then appServerURL="domibus" ; fi
   if [ "${1}" == "WildFly" ] ; then appServerURL="domibus-wildfly" ; fi
   if [ "${1}" == "Weblogic" ] ; then appServerURL="domibus-weblogic" ; fi
}

function configureJava {
   displayFunctionBanner ${FUNCNAME[0]}

   export JAVA_HOME=/usr/local/java/jre1.8.0_144
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

function buildDomibusStartupParams {
   displayFunctionBanner ${FUNCNAME[0]}
echo "   PARTY_ID                : ${PARTY_ID}"
echo "   DB_TYPE                 : ${DB_TYPE}"
echo "   DB_HOST                 : ${DB_HOST}"
echo "   DB_PORT                 : ${DB_PORT}"
echo "   DB_NAME                 : ${DB_NAME}"
echo "   DB_USER                 : ${DB_USER}"
echo "   DB_PASS                 : ${DB_PASS}"

if [ ! "X${PARTY_ID}" == "X" ] ; then
   echo ; echo "PARTY_ID has been provided: ${PARTY_ID}"
   DB_TYPE="MySQL"
   DB_PORT=3306
   DB_NAME="domibus"
   DB_USER="edelivery" 
   DB_PASS="edelivery"
   case "${PARTY_ID}" in
      "blue")
         DB_TYPE="MySQL"
         DB_HOST="mysql_blue"
      ;;
      "red")
         DB_TYPE="MySQL"         
         DB_HOST="mysql_red"
         DB_PORT=3306            
      ;;
      *)
         ABORT_JOB "PARTY_ID Provided but MUST BE EITHER 'blue' or 'red'"
      ;;
   esac
fi

   if [ ! "${DB_HOST}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.database.serverName=${DB_HOST}"
   fi

   if [ ! "${DB_PORT}" = "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.database.port=${DB_PORT}"
   fi

   if [ ! "${DB_USER}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.datasource.user=${DB_USER}"
      domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.property.user=${DB_USER}"
   fi

   if [ ! "${DB_PASS}" == "" ] ; then
      domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.property.password=${DB_PASS}"
      domStartupParams="${domStartupParams} -Ddomibus.datasource.password=${DB_PASS}"
   fi

   if [ ! "${DB_TYPE}" == "" ] ; then
      case "${DB_TYPE}" in
         "MySQL")
            domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.xaDataSourceClassName=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.property.url=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?pinGlobalTxToPhysicalConnection=true"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.driverClassName=com.mysql.jdbc.Driver"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.url=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false"
         ;;
         "Oracle")
            domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.xaDataSourceClassName=oracle.jdbc.xa.client.OracleXADataSource"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.xa.property.URL=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}${DB_NAME}"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.driverClassName=oracle.jdbc.OracleDriver"
            domStartupParams="${domStartupParams} -Ddomibus.datasource.url=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}${DB_NAME}"
         ;;
         *)
            ABORT_JOB "Database Type provided ({$DB_TYPE}) but MUST BE EITHER 'MySQL' or 'Oracle'"
         ;;
      esac
   fi
}

function configureDomibusProperties {
   displayFunctionBanner ${FUNCNAME[0]}

   echo ; echo "Updating COMMON PROPERTIES for MySQL and Oracle Database"
   updateJavaPropertiesFile domibus.database.serverName ${DB_HOST}		"/data/domibus/domibus/conf/domibus/domibus.properties"

   case "${DB_TYPE}" in
      "MySQL")
         echo ; echo "Updating Properties for Database: ${DB_TYPE}"
#         updateStringInFile \
#	    "domibus.datasource.xa.property.url=jdbc:mysql://\${domibus.database.serverName}:\${domibus.database.port}/domibus?pinGlobalTxToPhysicalConnection=true" \
#	    "domibus.datasource.xa.property.url=jdbc:mysql://\${domibus.database.serverName}:\${domibus.database.port}/${DB_NAME}?pinGlobalTxToPhysicalConnection=true" \
#	    "/data/domibus/domibus/conf/domibus/domibus.properties"
#         updateStringInFile \
#	    "domibus.datasource.url=jdbc:mysql://\${domibus.database.serverName}:\${domibus.database.port}/domibus?useSSL=false" \
#	    "domibus.datasource.url=jdbc:mysql://\${domibus.database.serverName}:\${domibus.database.port}/${DB_NAME}?useSSL=false" \
#	    "/data/domibus/domibus/conf/domibus/domibus.properties"
      ;;
      "Oracle")
         updateJavaPropertiesFile domibus.database.port	${DB_PORT}		"/data/domibus/domibus/conf/domibus/domibus.properties"

         echo ; echo "Updating Properties for Database: ${DB_TYPE}"
         updateStringInFile	\
	    "^domibus.datasource.xa.xaDataSourceClassName=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource" \
	    "#domibus.datasource.xa.xaDataSourceClassName=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
         updateStringInFile	\
	    "^#domibus.datasource.xa.xaDataSourceClassName=oracle.jdbc.xa.client.OracleXADataSource" \
	    "domibus.datasource.xa.xaDataSourceClassName=oracle.jdbc.xa.client.OracleXADataSource" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
         updateStringInFile \
	    "^domibus.datasource.xa.property.url=jdbc:mysql://\${domibus.database.serverName}:\${domibus.database.port}/domibus?pinGlobalTxToPhysicalConnection=true"	\
	    "#domibus.datasource.xa.property.url=jdbc:mysql://\${domibus.database.serverName}:\${domibus.database.port}/domibus?pinGlobalTxToPhysicalConnection=true"	\
	    "/data/domibus/domibus/conf/domibus/domibus.properties"              
         updateStringInFile	\
	    "^#domibus.datasource.xa.property.URL=jdbc:oracle:thin:@\${domibus.database.serverName}:\${domibus.database.port}/XE" \
	    "domibus.datasource.xa.property.URL=jdbc:oracle:thin:@\${domibus.database.serverName}:\${domibus.database.port}${DB_NAME}" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
         updateStringInFile	\
	    "^domibus.datasource.driverClassName=com.mysql.jdbc.Driver" \
	    "#domibus.datasource.driverClassName=com.mysql.jdbc.Driver" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
        updateStringInFile	\
	    "^#domibus.datasource.driverClassName=oracle.jdbc.OracleDriver" \
	    "domibus.datasource.driverClassName=oracle.jdbc.OracleDriver" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
         updateStringInFile	\
	    "domibus.datasource.url=jdbc:mysql://\${domibus.database.serverName}:\${domibus.database.port}/domibus?useSSL=false" \
	    "#domibus.datasource.url=jdbc:mysql://\${domibus.database.serverName}:\${domibus.database.port}/domibus?useSSL=false" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
         updateStringInFile	\
	    "^#domibus.datasource.url=jdbc:oracle:thin:@\${domibus.database.serverName}:\${domibus.database.port}/XE" \
	    "domibus.datasource.url=jdbc:oracle:thin:@\${domibus.database.serverName}:\${domibus.database.port}${DB_NAME}" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
         updateStringInFile	\
	    "^domibus.entityManagerFactory.jpaProperty.hibernate.connection.driver_class=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource" \
	    "#domibus.entityManagerFactory.jpaProperty.hibernate.connection.driver_class=com.mysql.jdbc.jdbc2.optional.MysqlXADataSource" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
         updateStringInFile	\
	    "^#domibus.entityManagerFactory.jpaProperty.hibernate.connection.driver_class=oracle.jdbc.xa.client.OracleXADataSource" \
	    "domibus.entityManagerFactory.jpaProperty.hibernate.connection.driver_class=oracle.jdbc.xa.client.OracleXADataSource" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
         updateStringInFile	\
	    "^domibus.entityManagerFactory.jpaProperty.hibernate.dialect=org.hibernate.dialect.MySQL5InnoDBDialect" \
	    "#domibus.entityManagerFactory.jpaProperty.hibernate.dialect=org.hibernate.dialect.MySQL5InnoDBDialect" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
         updateStringInFile	\
	    "^#domibus.entityManagerFactory.jpaProperty.hibernate.dialect=org.hibernate.dialect.Oracle10gDialect" \
	    "domibus.entityManagerFactory.jpaProperty.hibernate.dialect=org.hibernate.dialect.Oracle10gDialect" \
	    "/data/domibus/domibus/conf/domibus/domibus.properties"
#domibus.datasource.url=jdbc:oracle:thin:@${domibus.database.serverName}:${domibus.database.port}/XE
      ;;
      *)
         ABORT_JOB "Database Type (\${DB_TYPE}) but MUST BE EITHER 'MySQL' or 'Oracle': ${DB_TYPE}"
      ;;
   esac 
}

function startDomibus {
   displayFunctionBanner ${FUNCNAME[0]}

echo ; echo "Starting Domibus - Tomcat: /data/domibus/domibus/bin/catalina.sh start"
nohup /data/domibus/domibus/bin/catalina.sh start > /data/domibus/domibus/domibus.log 2>&1 &
}

function Wait4Domibus {
   displayFunctionBanner ${FUNCNAME[0]}

   while ! curl -X POST --silent --output /dev/null \
         http://localhost:8080/domibus-wildfly/rest/security/authentication \
         -i -H "Content-Type: application/json" \
         -d '{"username":"","password":""}' ; do
     sleep 1 && echo -n .
   done

   echo ; echo "Waiting 30 second for all services to be started"
   niceSleep 30

   echo ; echo "Waiting for message:"
   echo
   echo "\"org.apache.catalina.startup.Catalina.start Server startup in\""
   echo "in /data/domibus/domibus/logs/catalina.out..."
   while ! grep "org.apache.catalina.startup.Catalina.start Server startup in" /data/domibus/domibus/logs/catalina.out ; do
      echo -n . ; sleep 2
   done
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
configureAppServerURL Tomcat
configureJava
#buildDomibusStartupParams
waitForDatabase
configureDomibusProperties
startDomibus
Wait4Domibus
configurePmode4Tests Tomcat Weblogic
uploadPmode
tail -f /data/domibus/domibus/logs/catalina.out


