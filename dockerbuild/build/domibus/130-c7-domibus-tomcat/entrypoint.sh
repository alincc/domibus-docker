#!/bin/bash

echo ; echo "Sourcing domInstall Common Functions"
. /data/domInstall/scripts/functions/common.functions
. /data/domInstall/scripts/functions/database.functions

echo ; echo "RECEIVED Parameters:"
echo "   WORKING_DIR             : ${WORKING_DIR}"
echo "   PARTY_ID                : ${PARTY_ID}"
echo "   DB_TYPE                 : ${DB_TYPE}"
echo "   DB_HOST                 : ${DB_HOST}"
echo "   DB_PORT                 : ${DB_PORT}"
echo "   DB_NAME                 : ${DB_NAME}"
echo "   DB_USER                 : ${DB_USER}"
echo "   DB_PASS                 : ${DB_PASS}"


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

echo "   DB_TYPE                 : ${DB_TYPE}"
echo "   DB_HOST                 : ${DB_HOST}"
echo "   DB_PORT                 : ${DB_PORT}"
echo "   DB_NAME                 : ${DB_NAME}"
echo "   DB_USER                 : ${DB_USER}"
echo "   DB_PASS                 : ${DB_PASS}"


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


##########################################################################
# MAIN PROGRAMM STARTS HERE
##########################################################################

waitForDatabase
configureDomibusProperties
startDomibus
Wait4Domibus