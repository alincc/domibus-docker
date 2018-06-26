#!/bin/bash

echo ; echo "Sourcing Common Functions"
. /data/domInstall/scripts/functions/common.functions

echo ; echo "RECEIVED Parameters:"
echo "   WORKING_DIR		 : ${WORKING_DIR}"
echo "   DOMINSTALL_PROPERTYFILE : ${DOMINSTALL_PROPERTYFILE}"
echo "   PARTY_ID	 	 : ${PARTY_ID}"
echo "   DB_TYPE		 : ${DB_TYPE}"
echo "   DB_HOST		 : ${DB_HOST}"
echo "   DB_PORT		 : ${DB_PORT}"
echo "   DB_NAME		 : ${DB_NAME}"
echo "   DB_USER		 : ${DB_USER}"
echo "   DB_PASS 		 : ${DB_PASS}"

function quickFix01 {
   displayFunctionBanner ${FUNCNAME[0]}

# quickFix ######################################
cef_edelivery_path="/data/domibus"

TEMP_DIR="${cef_edelivery_path}/temp"
mkdir ${TEMP_DIR}

initialString="MySQLDatabaseHost=mysql$"
replacedString="MySQLDatabaseHost=mysql${PARTY_ID}"
targetFile="/data/domInstall/wls-mys-domibus-s.properties"
echo "   Replacing : ${initialString}"
echo "   By        : ${replacedString}"
echo "   In file   : ${targetFile}"
#sed -i -e "s#${initialString}#${replacedString}#" ${targetFile}

echo ; echo "Sourcing installation file: ${targetFile}"
. ${targetFile}
####################################################
}

function configureAppServerURL {
   displayFunctionBanner ${FUNCNAME[0]}

   echo "ApplicationServer=${ApplicationServer}"
   if [ "${1}" == "Tomcat" ] ; then appServerURL="domibus" ; fi
   if [ "${1}" == "WildFly" ] ; then appServerURL="domibus-wildfly" ; fi
   if [ "${1}" == "WebLogic" ] ; then appServerURL="domibus-weblogic" ; fi
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

function configureDomibusProperties {
   displayFunctionBanner ${FUNCNAME[0]}


echo ; echo "Configuring Domibus as PARTY_ID: ${PARTY_ID}"

echo ; echo "Configuring Private Key Alias as ${PARTY_ID}_gw"
initialString="domibus.security.key.private.alias=blue_gw"
replacedString="domibus.security.key.private.alias=${PARTY_ID}_gw"
targetFile="${DomibusInstallationDir}/${WebLogicDomainName}/conf/domibus/domibus.properties"
echo "   Replacing : ${initialString}"
echo "   By        : ${replacedString}"
echo "   In file   : ${targetFile}"
sed -i -e "s#${initialString}#${replacedString}#" ${targetFile}
}

function updateDatasourcesURL {
   displayFunctionBanner ${FUNCNAME[0]}

. /data/domInstall/domInstall.properties

   echo ; echo "Changing Datasource in a politically correct way...:"

   cat << EOF > ${TEMP_DIR}/updateDatasourcesURL.py
print("*** Trying to Connect.... *****")
connect('${WebLogicAdminUserName}','${WebLogicAdminUserPassword}','t3://localhost:${WebLogicAdminServerPort}')
print("*** Connected *****")
cd('Servers/AdminServer')
edit()
startEdit()
cd('JDBCSystemResources')
allDS=cmo.getJDBCSystemResources()

for tmpDS in allDS:
  dsName=tmpDS.getName();
  print  'Changing URL for DataSource ', dsName
  cd('/JDBCSystemResources/dsName/JDBCResource/dsName')
  cd('JDBCDriverParams/dsName')
  ls()
  cmo.setUrl('${PARTY_ID}:3306')
  print("URL has been updated for DataSource: ", dsName)
  print ('')
  print ('')

save()
activate()
EOF

   /data/domibus/temp/wlst/bin/wlst.sh --
}

function startWebLogic {
   displayFunctionBanner ${FUNCNAME[0]}

   echo ; echo "Starting Domibus - WebLogic: /data/domibus/DOCKMIBUS/runIt.sh"
   ${DomibusInstallationDir}/${WebLogicDomainName}/runIt.sh
}

function waitForMySQLDatabase {

   echo ; echo "Wait for MySQL Database to be ready"
   echo "DB_HOST" ${DB_HOST}
   echo "domibus.database.serverName" ${domibus.database.serverName}
   echo "domibus.database.port" ${domibus.database.port}

   while [ ! "${MySQLTableCheck}" == "admin" ] ; do
      MySQLTableCheck=$(mysql -sN -h${DB_HOST} -uedelivery -pedelivery domibus 2> /dev/null << EOF | sed 's/[  ]//g'
      select USER_NAME from TB_USER where ID_PK=1;
EOF
)

   sleep 1
   echo -n "."
   done
}

function waitForOracleDatabase {

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

function waitForDatabase {
   displayFunctionBanner ${FUNCNAME[0]}

   case "${DB_TYPE}" in
	"MySQL")
		waitForMySQLDatabase
	;;
	"Oracle")
		waitForOracleDatabase
	;;
	*)
                echo ; echo "Database Type (DB_TYPE) MUST BE eitheir Oracle or MySQL"
                ABORT_JOB  "This Database is not yet supported : ${DB_TYPE}"

	;;
   esac
}

function wait4Domibus {
   displayFunctionBanner ${FUNCNAME[0]}

   waitString="<Notice> <WebLogicServer> <BEA-000365> <Server state changed to RUNNING.>"
   waitFile="${DomibusInstallationDir}/${WebLogicDomainName}/${WebLogicManagedServer1Name}.log"

   echo ; echo "Waiting for  server startup..."
   echo ; echo "   Waiting for: ${waitString}"
   echo "In file        : ${waitFile}"
   while ! grep '${waitString}' ${waitFile} ; do
      echo -n . ; sleep 2
   done
}

function keepLooping {
   displayFunctionBanner ${FUNCNAME[0]}

   while true ; do sleep 1 ; done
}

function createDatasourceWeblogic {
   displayFunctionBanner ${FUNCNAME[0]}

   echo "Creating WebLogic Datasources with the following parameters:"
   echo "   DB_TYPE: ${DB_TYPE}"
   echo "   DB_HOST: ${DB_HOST}"
   echo "   DB_PORT: ${DB_PORT}"
   echo "   DB_NAME: ${DB_NAME}"
   echo "   DB_USER: ${DB_USER}"
   echo "   DB_PASS: ${DB_PASS}"

   echo ; echo "Generating Database URL for: ${DB_TYPE}"
   if [ "${DB_TYPE}" == "Oracle" ] ; then
      DB_URL="jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}${DB_NAME}"
      echo "   DB_URL set to: ${DB_URL}"
   fi
   if [ "${DB_TYPE}" == "MySQL" ] ; then
      DB_URL="jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}"
      echo "   DB_URL set to: ${DB_URL}"
   fi

   echo ; echo "   Configuring EntityManagerFactory in ${DomibusInstallationDir}/${WebLogicDomainName}/conf/domibus/domibus.properties:"
   case "${DB_TYPE}" in
      	"Oracle")
		updateJavaPropertiesFile 	domibus.entityManagerFactory.jpaProperty.hibernate.connection.driver_class \
						oracle.jdbc.xa.client.OracleXADataSource \
						"${DomibusInstallationDir}/${WebLogicDomainName}/conf/domibus/domibus.properties"
   		updateJavaPropertiesFile	domibus.entityManagerFactory.jpaProperty.hibernate.dialect \
						org.hibernate.dialect.Oracle10gDialect \
						"${DomibusInstallationDir}/${WebLogicDomainName}/conf/domibus/domibus.properties"
	;;
	"MySQL")

		updateJavaPropertiesFile	domibus.entityManagerFactory.jpaProperty.hibernate.connection.driver_class \
						com.mysql.jdbc.Driver \
						"${DomibusInstallationDir}/${WebLogicDomainName}/conf/domibus/domibus.properties"
   		updateJavaPropertiesFile	domibus.entityManagerFactory.jpaProperty.hibernate.dialect \
						org.hibernate.dialect.MySQL5InnoDBDialect \
						"${DomibusInstallationDir}/${WebLogicDomainName}/conf/domibus/domibus.properties"
	;;
	*)
		echo ; echo "Database Type (DB_TYPE) MUST BE eitheir Oracle or MySQL"
		ABORT_JOB  "This Database is not yet supported : ${DB_TYPE}"
   esac

   for dsName in `grep "^jdbc.datasource...name=" ${TEMP_DIR}/WeblogicSingleServer-JDBC-${DB_TYPE}.properties | cut -d'=' -f2` ; do
      echo ; echo "Creating WebLogic Datasource: ${dsName}"
      dsNum="`grep \"^jdbc.datasource...name=${dsName}\" ${TEMP_DIR}/WeblogicSingleServer-JDBC-${DB_TYPE}.properties | cut -d '.' -f 3`"
      echo "   Datasource Number : ${dsNum}"
      updateJavaPropertiesFile jdbc.datasource.${dsNum}.driver.url	${DB_URL}			${TEMP_DIR}/WeblogicSingleServer-JDBC-${DB_TYPE}.properties
      updateJavaPropertiesFile jdbc.datasource.${dsNum}.driver.username ${DB_USER}			${TEMP_DIR}/WeblogicSingleServer-JDBC-${DB_TYPE}.properties
      updateJavaPropertiesFile jdbc.datasource.${dsNum}.driver.password ${DB_PASS}			${TEMP_DIR}/WeblogicSingleServer-JDBC-${DB_TYPE}.properties
      updateJavaPropertiesFile jdbc.datasource.${dsNum}.targets		${WebLogicManagedServer1Name}	${TEMP_DIR}/WeblogicSingleServer-JDBC-${DB_TYPE}.properties
   done

   echo ; cat  ${TEMP_DIR}/WeblogicSingleServer-JDBC-${DB_TYPE}.properties

   echo ; echo "Prepare WLS Environment, Sourcing: . /data/WebLogic/wls_12.1.3.0.0/Oracle_Home/wlserver/server/bin/setWLSEnv.sh"
   . /data/WebLogic/wls_12.1.3.0.0/Oracle_Home/wlserver/server/bin/setWLSEnv.sh

   echo ; echo "Configuring Weblogic: Creating datasouces"
   echo "    /${TEMP_DIR}/wlst/bin/wlstapi.sh ${TEMP_DIR}/wlst/scripts/import.py --property ${TEMP_DIR}/WeblogicSingleServer.properties"
   /${TEMP_DIR}/wlst/bin/wlstapi.sh ${TEMP_DIR}/wlst/scripts/import.py --property ${TEMP_DIR}/WeblogicSingleServer-JDBC-${DB_TYPE}.properties
}

function deployWarFileWebLogic {
   displayFunctionBanner ${FUNCNAME[0]}

   DOWNLOAD_DIR="/data/domInstall/downloads"
   DOMIBUS_VERSION="$DomibusVersion"

   echo "Deploying  domibus-distribution-${DOMIBUS_VERSION}-weblogic war file"
   if [ ${DOMIBUS_VERSION:0:3} == "3.3" ]  || [ ${DOMIBUS_VERSION} == "4.0-SNAPSHOT" ] ; then
      echo "   Unzipping  domibus-distribution-${DOMIBUS_VERSION}-weblogic-war.zip"
      unzip -d ${DOWNLOAD_DIR}/Domibus/${DOMIBUS_VERSION}/ ${DOWNLOAD_DIR}/Domibus/${DOMIBUS_VERSION}/domibus-distribution-${DOMIBUS_VERSION}-weblogic-war.zip
      if [ ${DOMIBUS_VERSION} == "3.3" ] ; then
         mv ${DOWNLOAD_DIR}/Domibus/${DOMIBUS_VERSION}/domibus-MSH-weblogic-3.3.war \
            ${DOWNLOAD_DIR}/Domibus/${DOMIBUS_VERSION}/domibus-distribution-${DOMIBUS_VERSION}-weblogic.war
      fi
      if [ ${DOMIBUS_VERSION} == "4.0-SNAPSHOT" ] ; then
         echo "   Renaming domibus-MSH-weblogic-4.0-SNAPSHOT.war to: domibus-distribution-${DOMIBUS_VERSION}-weblogic.war"
         mv ${DOWNLOAD_DIR}/Domibus/${DOMIBUS_VERSION}/domibus-MSH-weblogic-4.0-SNAPSHOT.war \
            ${DOWNLOAD_DIR}/Domibus/${DOMIBUS_VERSION}/domibus-distribution-${DOMIBUS_VERSION}-weblogic.war
      fi
   fi

   echo "   Deploying domibus-distribution-${DOMIBUS_VERSION}-weblogic.war: "
   cmd="java weblogic.Deployer -adminurl t3://${WebLogicAdminServerListenAddress}:${WebLogicAdminServerPort} \
			-username ${WebLogicAdminUserName} \
			-password ${WebLogicAdminUserPassword} \
       			-deploy -name domibus-distribution-${DOMIBUS_VERSION}-weblogic.war \
			-targets ${WebLogicManagedServer1Name} \
			-source ${DOWNLOAD_DIR}/Domibus/${DOMIBUS_VERSION}/domibus-distribution-${DOMIBUS_VERSION}-weblogic.war"
   echo "cmd=${cmd}"
   eval "${cmd}"
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
    replacedString="endpoint=\"http://domibus_blue:${WebLogicManagedServer1Port}/${appServerURL}/services/msh\""
    echo "   Replacing : ${initialString}"
    echo "   By        : ${replacedString}"
    echo "   In files   : ${targetFileBlue} and ${targetFileRed}"
    sed -i -e "s#${initialString}#${replacedString}#" ${targetFileBlue}
    sed -i -e "s#${initialString}#${replacedString}#" ${targetFileRed}

    initialString="endpoint=\"http://localhost:8180/domibus/services/msh\""
    replacedString="endpoint=\"http://domibus_red:${WebLogicManagedServer1Port}/${appServerURL}/services/msh\""
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
   curl http://localhost:${WebLogicManagedServer1Port}/${appServerURL}/rest/security/authentication \
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

   curl http://localhost:${WebLogicManagedServer1Port}/${appServerURL}/rest/pmode \
   -b ${TEMP_DIR}/cookie.txt \
   -v \
   -H "X-XSRF-TOKEN: ${XSRFTOKEN}" \
   -F  file=@${pmodeFile2Upload}
}

##########################################################################
# MAIN PROGRAMM STARTS HERE
##########################################################################

quickFix01
configureAppServerURL WebLogic
#configureJava
#updateDatasourcesURL
configureDomibusProperties
waitForDatabase
startWebLogic
createDatasourceWeblogic
deployWarFileWebLogic
#wait4Domibus
configurePmode4Tests WebLogic
uploadPmode
keepLooping

