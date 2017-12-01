#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

dominstallproperties="$1"
domibusproperties="$2"

# Set DEBUG TO 1 to activate debugging
DEBUG=0

function displayBanner {
   cat ${SCRIPTPATH}/scripts/textBanner.txt
}

function sourceExternalFunctions {
#displayFunctionBanner ${FUNCNAME[0]}

   echo ; echo "Sourcing External Functions:"

   . ${SCRIPTPATH}/scripts/functions/common.functions
   . ${SCRIPTPATH}/scripts/functions/initDatabaseMySQL.functions
   . ${SCRIPTPATH}/scripts/functions/initDatabaseOracle.functions
   . ${SCRIPTPATH}/scripts/functions/initDatabaseMsSQL.functions
   . ${SCRIPTPATH}/scripts/functions/downloadJDKJRE.functions
   . ${SCRIPTPATH}/scripts/functions/downloadJDBC.functions
   . ${SCRIPTPATH}/scripts/functions/downloadSoftware.functions
   . ${SCRIPTPATH}/scripts/functions/getDomibus.functions
   . ${SCRIPTPATH}/scripts/functions/configureDomibus.functions
   . ${SCRIPTPATH}/scripts/functions/Tomcat.functions
   . ${SCRIPTPATH}/scripts/functions/WildFly.functions
   . ${SCRIPTPATH}/scripts/functions/WebLogic.functions
}

function defineColors {
   displayFunctionBanner ${FUNCNAME[0]}

   #export COLOR_LIGHT_RED='\e[1;31m'
   #fail_color='\033[1;31m'
   #pass_color="\033[32;1m\]"
   #color_end="\033[0m\]"
   echo
}

function checkDomInstallPropertiesFiles {
   displayFunctionBanner ${FUNCNAME[0]}

   if [ "${dominstallproperties}" == "" ] ; then
      ABORT_JOB "The MANDATORY 'domInstall.properties' properties file is not specified..."
   else
      if [ ! -f ${dominstallproperties} ] ; then
         ABORT_JOB "The mentioned \"domInstall.properties\" (${domibusproperties}) properties file DOES NOT EXIST..."
      else
         echo
         echo "   DOMIBUS INSTALLATION WILL BE PERFORMED WITH THE FOLLOWING FILE:"
         echo
         echo "   - ${dominstallproperties}"
         echo
      fi
   fi
}

function checkDomibusPropertiesFiles {
   displayFunctionBanner ${FUNCNAME[0]}

   if [ "${domibusproperties}" == "" ] ; then
      echo
      echo "The mentioned \"dominstall.properties\" (${dominstallproperties}) properties file is NOT SPECIFIED"
      echo
      echo "   PERFORMING A DEFAULT INSTALLATION"
      echo
   else
      if [ ! -f "${domibusproperties}" ] ; then
         ABORT_JOB "The mentioned \"domibus.properties\" (${domibusproperties}) properties file DOES NOT EXIST..."
      else
         echo
         echo "   DOMIBUS CONFIGURATION WILL BE PERFORMED WITH THE FOLLOWING FILE:"
         echo
         echo "   - ${domibusproperties}"
         echo
      fi
   fi
}

function getDomibusInstallProperties {
   displayFunctionBanner ${FUNCNAME[0]}

   source ${dominstallproperties}
   #source ${domibusproperties}

   echo "DownloadJAVA					: ${DownloadJAVA}"
   echo "DownloadJDBC					: ${DownloadJDBC}"
   echo "DownloadDomibus				: ${DownloadDomibus}"
   echo
   echo "DomibusInstallationDir				: $DomibusInstallationDir"
   echo
   echo "DomibusDownloadLocation			: ${DomibusDownloadLocation}"
   echo "DomibusDirectoryLocation			: ${DomibusDirectoryLocation}"

   echo "DomibusVersion $DefaultValuesDomibusVersion           : $DomibusVersion"
   echo "ApplicationServer $DefaultValuesApplicationServer  : $ApplicationServer"
   echo "DatabaseType $DefaultValuesDatabaseType                  : $DatabaseType"
   echo
   if [ "${DatabaseType}" == "MySQL" ] ; then
      echo "MySQLDatabaseHost                            : ${MySQLDatabaseHost}"
      echo "MySQLDatabasePort                            : ${MySQLDatabasePort}"
      echo "MySQLDatabaseName                            : ${MySQLDatabaseName}"
      echo "MySQLDatabaseUserId                          : ${MySQLDatabaseUserId}"
      echo "MySQLDatabaseUserPassword                    : ${MySQLDatabaseUserPassword}"
   fi
   if [ "${DatabaseType}" == "Oracle" ] ; then
      echo "OracleDatabaseHost                           : ${OracleDatabaseHost}"
      echo "OracleDatabasePort                           : ${OracleDatabasePort}"
      echo "OracleDatabaseSID                            : ${OracleDatabaseSID}"
      echo "OracleDatabaseUserId                         : ${OracleDatabaseUserId}"
      echo "OracleDatabaseUserPassword                   : ${OracleDatabaseUserPassword}"
   fi

   echo
   echo "DatabaseInit                                 : ${DatabaseInit}"
   if [ "${DatabaseType}" == "MySQL" ] ; then
      echo "MySQLDatabaseAdminUser                       : ${MySQLDatabaseAdminUser}"
      echo "MySQLDatabaseAdminPwd                        : *********** (\${MySQLDatabaseAdminPwd})"
   fi
   if [ "${DatabaseType}" == "Oracle" ] ; then
      echo "OracleDatabaseSYSPassword                    : ${OracleDatabaseSYSPassword}"
   fi

   echo
   if [ "${ApplicationServer}" == "WebLogic" ] ; then
      echo "WebLogicDomainName                           : $WebLogicDomainName"
      echo "WebLogicAdminServerName                      : ${WebLogicAdminServerName}"
      echo "WebLogicAdminServerListenAddress             : ${WebLogicAdminServerListenAddress}"
      echo "WebLogicAdminServerPort                      : ${WebLogicAdminServerPort}"
      echo "WebLogicAdminUserName                        : ${WebLogicAdminUserName}"
      echo "WebLogicAdminUserPassword                    : ${WebLogicAdminUserPassword}"
      echo "WebLogicManagedServer1Name                   : ${WebLogicManagedServer1Name}"
      echo "WebLogicManagedServer1Port                   : ${WebLogicManagedServer1Port}"
      echo "WebLogicManagedServer2Name                   : ${WebLogicManagedServer2Name}"
      echo "WebLogicManagedServer2Port                   : ${WebLogicManagedServer2Port}"
   fi

   if [ "${ApplicationServer}" == "Tomcat" ] ; then
      echo "TomcatInstallType $DefaultValuesTomcatInstallType      : $TomcatInstallType"
      echo "TomcatVersion $DefaultValuesTomcatVersion                : ${TomcatVersion}"
      echo
      echo "TomcatHTTPPort                               : ${TomcatHTTPPort}"
      echo "TomcatRedirectPort                           : ${TomcatRedirectPort}"
      echo "TomcatAJPPort                                : ${TomcatAJPPort}"
      echo "TomcatShutdownPort                           : ${TomcatShutdownPort}"
      echo "TomcatTransportConnector                     : ${TomcatTransportConnector}"
      echo "TomcatConnectorPort                          : ${TomcatConnectorPort}"
      echo "TomcatRmiServerPort                          : ${TomcatRmiServerPort}"
   fi

   if [ "${ApplicationServer}" == "WildFly" ] ; then
      echo "WildFlyInstallType $DefaultValuesWildFlyInstallType     : $WildFlyInstallType"
      echo "WildFlyServerConfig                          : $WildFlyServerConfig"
      echo "WildFlyAdminUser                             : $WildFlyAdminUser"
      echo "WildFlyAdminPwd                              : $WildFlyAdminPwd"
      echo "WildFlyNetPublicInterface                    : $WildFlyNetPublicInterface:$WildFlyNetPublicPort"
      echo "WildFlyNetManagementInterface                : $WildFlyNetManagementInterface:$WildFlyNetManagementPort"
      echo "WildFlyNetUnsecureInterface                  : $WildFlyNetUnsecureInterface:$WilfFlyNetUnsecurePort"
   fi

   echo
   echo "DOMIBUS CONFIGURATION"
   echo "====================="
   echo "domibus.security.key.private.alias		: ${domibus_security_key_private_alias}"
   echo "domibus.msh.messageid.suffix			: ${domibus_msh_messageid_suffix}"
   echo
   echo "domibus.security.keystore.location		: ${domibus_security_keystore_location}"
   echo "domibus.security.keystore.type			: ${domibus_security_keystore_type}"
   echo "domibus.security.keystore.password		: ${domibus_security_keystore_password}"
   echo "domibus.security.key.private.alia		: ${domibus_security_key_private_alias}"
   echo "domibus.security_key.private.password		: ${domibus_security_key_private_password}"
   echo
   echo "domibus.security.truststore.location		: ${domibus_security_truststore_location}"
   echo "domibus.security.truststore.type		: ${domibus_security_truststore_type}"
   echo "domibus.security.truststore.password		: ${domibus_security_truststore_password}"

   echo "activeMQ.broker.host				: ${activeMQ_broker_host}"
   echo "activeMQ.brokerName				: ${activeMQ_brokerName}"
   echo "activeMQ.embedded.configurationFile		: ${activeMQ_embedded_configurationFile}"
   echo "activeMQ.JMXURL					: ${activeMQ_JMXURL}"
   echo "activeMQ.connectorPort				: ${activeMQ_connectorPort}"
   echo "activeMQ.rmiServerPort				: ${activeMQ_rmiServerPort}"
   echo "activeMQ.transportConnector.uri			: ${activeMQ_transportConnector_uri}"
   echo "activeMQ.username				: ${activeMQ_username}"
   echo "activeMQ.password				: ${activeMQ_password}"

   echo "TLSEnabled                                   : $TLSEnabled"
   echo "disableCNCheck                               : $disableCNCheck"
   echo "singleAuthentication                         : $singleAuthentication"
   echo
   echo "KeystoreName                                 : ${KeystoreName}"
   echo "domibus.security.keystore.password                             : ${domibus_security_keystore_password}"
   echo "KeystorePrivateKeyAlias                      : ${KeystorePrivateKeyAlias}"
   echo "KeystorePrivateKeyPassword                   : ${KeystorePrivateKeyPassword}"
   echo "TruststoreName                               : ${TruststoreName}"
   echo "TruststorePassword                           : ${TruststorePassword}"
   echo
   echo "JMSQueuesPassword                            : $JMSQueuesPassword"
   echo "WebConsoleAdminPassword                      : $WebConsoleAdminPassword"
   echo "WebConsoleUserPassword                       : $WebConsoleUserPassword"
   echo "WSPluginAdminPassword                        : $WSPluginAdminPassword"
   echo "WSPluginUserPassword                         : $WSPluginUserPassword"
   echo "JMSPluginAdminPassword                       : $JMSPluginAdminPassword"
   echo "JMSPluginUserPassword                        : $JMSPluginUserPassword"

}

function killAllWildFlyInstance {
   displayFunctionBanner ${FUNCNAME[0]}

   # Killing all WildFly Running Instance if any
   echo ; echo "Killing  all WildFly Running Instance if any..."
   for pid in `ps -ef | grep wildflyc | grep Djboss | grep  Dlogging.configuration | sed 's/  / /g' | cut -d" " -f2` ; do echo Killing Pid: $pid ; kill $pid ; done
   #for pid in `ps -ef | grep Djboss | grep  Dlogging.configuration | sed 's/  / /g' | cut -d" " -f3` ; do echo Killing Pid: $pid ; kill $pid ; done
}

function initInstallation {
   displayFunctionBanner ${FUNCNAME[0]}

   export REPO_DIR="$SCRIPTPATH"

   echo $'\n\n\n' ; echo "Installation Source Directory is : $REPO_DIR"

   # Domibus Directory
   #export DOMIBUS_DIR="$REPO_DIR/domibus"
   export DOMIBUS_DIR=${DomibusInstallationDir}/domibus

   echo ; echo "Setting \${cef_edelivery_path} to ${DomibusInstallationDir}"
   export cef_edelivery_path=${DomibusInstallationDir}
   
   # Checking if the installation dir exists or is not empty
   if [ ! -d ${DomibusInstallationDir} ]; then
      echo ; echo "Creating \${DomibusInstallationDir}: mkdir ${DomibusInstallationDir}"
      mkdir -p ${DomibusInstallationDir}
   else
      echo
      echo "The directory ${DomibusInstallationDir} EXISTS... "
      ls -la
      #echo
      #echo "Please remove content manually by executing the statement below and retry..."
      #echo "chmod -R 700 ${DomibusInstallationDir} ; rm -rf  ${DomibusInstallationDir}"
      #chmod -R 700 /data/dhenech/domibus321_C ; rm -rf  /data/dhenech/domibus321_C
      #ABORT_JOB "The directory ${DomibusInstallationDir} EXISTS... ABORTING !!!"
   fi

    # Temporary Directory
  export TEMP_DIR=${DomibusInstallationDir}/temp
  echo "Creating Temporary Directory: \${TEMP_DIR}"
  echo " - mkdir ${TEMP_DIR}"
  mkdir $TEMP_DIR

  # Download Directories
  #20170812
  #export DOWNLOAD_DIR=${TEMP_DIR}/downloads
  export DOWNLOAD_DIR="${SCRIPTPATH}/downloads"
  echo "Creating Temporary Download Directories: \${DOWNLOAD_DIR}"
  echo " - mkdir -p ${DOWNLOAD_DIR}"
  mkdir -p ${DOWNLOAD_DIR}
  echo " - mkdir -p ${DOWNLOAD_DIR}/Domibus/${DomibusVersion}"
  mkdir -p ${DOWNLOAD_DIR}/Domibus/${DomibusVersion}

   DOMIBUS_VERSIONS=""
   for domibus_version in `ls -1 $DOWNLOAD_DIR/Domibus` ; do
      DOMIBUS_VERSIONS="$DOMIBUS_VERSIONS|$domibus_version"
   done

   DOMIBUS_VERSION=$DomibusVersion

   if [ "$DOMIBUS_VERSION" == "3.1.1" ] ; then
      DOMIBUS_PREFIX="distribution-${DOMIBUS_VERSION}"
   fi
   if [ "$DOMIBUS_VERSION" == "3.2.0" ] ; then
      DOMIBUS_PREFIX=`echo MSH-${DOMIBUS_VERSION}  | cut -c1-7`
   fi
   if [ "$DOMIBUS_VERSION" == "3.2.1" ] ; then
      DOMIBUS_PREFIX=`echo MSH-${DOMIBUS_VERSION}  | cut -c1-9`
   fi
   if [ "$DOMIBUS_VERSION" == "3.2.2" ] ; then
      DOMIBUS_PREFIX=`echo MSH-${DOMIBUS_VERSION}  | cut -c1-18`
   fi
   if [ "$DOMIBUS_VERSION" == "3.2.3-SNAPSHOT" ] ; then
      DOMIBUS_PREFIX=`echo MSH-$DOMIBUS_VERSION-SNAPSHOT  | cut -c1-18`
   fi
   if [ "$DOMIBUS_VERSION" == "3.2.3" ] ; then
      DOMIBUS_PREFIX=`echo MSH-${DOMIBUS_VERSION}  | cut -c1-18`
   fi
   if [ "$DOMIBUS_VERSION" == "3.2.4" ] ; then
      DOMIBUS_PREFIX=`echo MSH-${DOMIBUS_VERSION}  | cut -c1-18`
   fi
   if [ "$DOMIBUS_VERSION" == "3.2.5" ] ; then
      DOMIBUS_PREFIX=`echo MSH-${DOMIBUS_VERSION}  | cut -c1-18`
   fi
   if [ "$DOMIBUS_VERSION" == "3.3" ] ; then
      DOMIBUS_PREFIX="distribution-${DOMIBUS_VERSION}"
   fi
   if [ "$DOMIBUS_VERSION" == "4.0-SNAPSHOT" ] ; then
      DOMIBUS_PREFIX="distribution-${DOMIBUS_VERSION}"
   fi

   echo ; echo "\$DOMIBUS_PREFIX=$DOMIBUS_PREFIX"
}

function initDatabase {
   displayFunctionBanner ${FUNCNAME[0]}

   if [ "${DatabaseType}" == "MySQL" ] ; then
      echo "Initialazing Database : Calling initDatabaseMySQL"
      initDatabaseMySQL
   fi
   if [ "${DatabaseType}" == "Oracle" ] ; then
      echo "Initialazing Database: Calling initDatabaseOracle"
      initDatabaseOracle
   fi
}

function checkMD5Signatures {
   displayFunctionBanner ${FUNCNAME[0]}

   echo $'\nDisplaying & Controlling MD5 signature'
   for file in $DOWNLOAD_DIR/Domibus/$DOMIBUS_VERSION/* ; do md5sum $file ; done
}

function createDomibusConfDir {
   displayFunctionBanner ${FUNCNAME[0]}

   echo  ; echo "Creating Directory: ${cef_edelivery_path}/domibus/conf/domibus"
   [ -d ${cef_edelivery_path}/domibus/conf/domibus ] || mkdir -p ${cef_edelivery_path}/domibus/conf/domibus
}

function installDomibusConfiguration {
   displayFunctionBanner ${FUNCNAME[0]}

   echo ; echo "unzip -q \$DOWNLOAD_DIR/Domibus/$DOMIBUS_VERSION/domibus-$DOMIBUS_PREFIX-wildfly-configuration.zip -d ${cef_edelivery_path}//domibus/conf/domibus"
   unzip -q $DOWNLOAD_DIR/Domibus/$DOMIBUS_VERSION/domibus-$DOMIBUS_PREFIX-wildfly-configuration.zip -d ${cef_edelivery_path}/domibus/conf/domibus
}

function extractStandAloneFromFull {
   displayFunctionBanner ${FUNCNAME[0]}

echo ; echo "Extracting standalone-full.xml from $DOWNLOAD_DIR/domibus-$DOMIBUS_VERSION-wildfly-full.zip to \$TEMP_DIR/standalone-full.xml_FROM_FULL"
unzip -p $DOWNLOAD_DIR/Domibus/$DOMIBUS_VERSION/domibus-$DOMIBUS_PREFIX-wildfly-full.zip domibus/standalone/configuration/standalone-full.xml > $TEMP_DIR/standalone-full.xml_FROM_FULL
}

function generateKeystore {
   displayFunctionBanner ${FUNCNAME[0]}

   echo "   Generating \" ${KeystoreName}\" Keystore in ${cef_edelivery_path}/domibus/conf/domibus/keystores"
   keytool -genkey -keyalg RSA -alias ${KeystorePrivateKeyAlias} -keypass ${KeystorePrivateKeyPassword} \
      -keystore ${cef_edelivery_path}/domibus/conf/domibus/keystores/${KeystoreName} -storepass ${KeystorePassword} -validity 360 \
      -keysize 2048 \
      -dname "CN=${LocalPartnerId}, OU=CEF Support, O=B4, L=Brussels, ST=Unknown, C=BE"
}

function installKeystore {
   displayFunctionBanner ${FUNCNAME[0]}

   if  [ ! ${DOMIBUS_VERSION:0:3} == "3.3" ] && [ ! ${DOMIBUS_VERSION:0:3} == "4.0" ] && [ ! ${DOMIBUS_VERSION} == "LATEST" ] ; then
   echo ; echo "Installing keystore \" ${KeystoreName}\" in \${cef_edelivery_path}/domibus/conf/domibus/keystores"
   if [ ! -d  ${cef_edelivery_path}/domibus/conf/domibus/keystores ] ; then
      mkdir ${cef_edelivery_path}/domibus/conf/domibus/keystores
   fi
   
#   generateKeystore
#
#   echo "   Configuring Keystore Private Key Alias and Password"
#   initialString="<entry key=\"blue_gw\" value=\"test123\"/>"
#   replacedString="<entry key=\"${domibus_security_key_private_alias}\" value=\"${domibus_security_key_private_password}\"/>"
#   targetFile="${cef_edelivery_path}/domibus/conf/domibus/domibus-security.xml"
#   echo "   Replacing : ${initialString}"
#   echo "   By        : ${replacedString}"
#   echo "   In file   : ${targetFile}"
#   sed -i -e "s#${initialString}#${replacedString}#" ${targetFile}
#
#   echo ; echo "   Configuring Keystore Name in \${cef_edelivery_path}/domibus/conf/domibus/domibus-security.xml"
#   initialString="<prop key=\"org.apache.ws.security.crypto.merlin.keystore.password\">"
#   sed -i -e "/${initialString}/!b;n;c           ${KeystorePassword}" ${cef_edelivery_path}/domibus/conf/domibus/domibus-security.xml
#   echo "   Configuring keystore Password in ${cef_edelivery_path}/domibus/conf/domibus/domibus-security.xml"
#   initialString="<prop key=\"org.apache.ws.security.crypto.merlin.file\">"
#   sed -i -e "/${initialString}/!b;n;c${KeystoreName}" ${cef_edelivery_path}/domibus/conf/domibus/domibus-security.xml
#   echo "   Configuring Private Key Password"
#   searchString="<prop key=\"org.apache.ws.security.crypto.merlin.keystore.private.password\">"
#   sed -i -e "/${searchString}/!b;n;c${KeystorePrivateKeyPassword}" ${cef_edelivery_path}/domibus/conf/domibus/domibus-security.xml
#   else
#      echo ; echo "PROVIDED BY DOMIBUS.PROPERTIES:"
#      echo
#      echo "domibus.security.keystore.location             : ${domibus_security_keystore_location}"
#      echo "domibus.security.keystore.type                 : ${domibus_security_keystore_type}"
#      echo "domibus.security.keystore.password             : ${domibus_security_keystore_password}"
#      echo "domibus.security.key.private.alia              : ${domibus_security_key_private_alias}"
#      echo "domibus.security_key.private.password          : ${domibus_security_key_private_password}"
   fi
}

function compareXML {
   displayFunctionBanner ${FUNCNAME[0]}

   diff ${cef_edelivery_path}/domibus/standalone/configuration/${WildFlyServerConfig}.xml $TEMP_DIR/${WildFlyServerConfig}.xml_FROM_FULL
}

function deployDomibusWarFile {
   displayFunctionBanner ${FUNCNAME[0]}

   echo ; echo "Deploying domibus-${DOMIBUS_PREFIX}-wildfly.war: ${cef_edelivery_path}/domibus}/bin/jboss-cli.sh <<EOF"
   ${cef_edelivery_path}/domibus/bin/jboss-cli.sh <<EOF

embed-server --server-config=${WildFlyServerConfig}.xml

deploy --force ${DOWNLOAD_DIR}/Domibus/${DOMIBUS_VERSION}/domibus-${DOMIBUS_PREFIX}-wildfly.war

exit
EOF
}

function startDomibus {
   displayFunctionBanner ${FUNCNAME[0]}

   echo ; echo "Starting Domibus-wildfly: nohup ${cef_edelivery_path}/domibus/bin/standalone.sh --server-config=${WildFlyServerConfig}.xml > ${cef_edelivery_path}/domibus/domibus-wildfly.log 2>&1 &"
   nohup ${cef_edelivery_path}/domibus/bin/standalone.sh --server-config=${WildFlyServerConfig}.xml > ${cef_edelivery_path}/domibus/domibus-wildfly.log 2>&1 &
}

function setJVMParamsTomcat {
   displayFunctionBanner ${FUNCNAME[0]}

   echo
   echo "Setting JVM Parameters in \${cef_edelivery_path}/domibus/bin/catalina.sh"
   #MyLine='"\nexport CATALINA_HOME=\""$DOMIBUS_DIR\/domibus\""\nexport JAVA_OPTS=\""\$JAVA_OPTS -Xms128m -Xmx1024m -XX:MaxPermSize=256m\""\nexport JAVA_OPTS=\""\$JAVA_OPTS -Ddomibus.config.location=\$CATALINA_HOME\/conf\/domibus\""\n'"
   MyLine='\nexport JAVA_OPTS="$JAVA_OPTS -Xms128m -Xmx1024m -XX:MaxPermSize=256m"\nexport JAVA_OPTS="$JAVA_OPTS -Ddomibus.config.location=$CATALINA_HOME\/conf\/domibus"\n'
   #MyLine="\nexport CATALINA_HOME=$DOMIBUS_DIR\/domibus\n"
   #echo $MyLine
   #MyLine="${MyLine}export JAVA_OPTS=\"""\$JAVA_OPTS –Xms128m -Xmx1024m -XX:MaxPermSize=256m\"""\n\""
   #echo $MyLine
   #MyLine="${MyLine}export JAVA_OPTS=\"""\$JAVA_OPTS -Ddomibus.config.location=\$CATALINA_HOME\/conf\/domibus\"""\n\""
   #echo $MyLine
   sed -i "249s/.*/${MyLine}/" ${cef_edelivery_path}/domibus/bin/catalina.sh
   #sed -i "2s/.*/totoleHero/" $DOMIBUS_DIR/domibus/bin/catalina.sh
   #cat $DOMIBUS_DIR/domibus/bin/catalina.sh >> $TEMP_DIR/catalina.sh 
   #mv $TEMP_DIR/catalina.sh  $DOMIBUS_DIR/domibus/bin/catalina.sh

   echo ; echo "Setting \${cef_edelivery_path}/domibus/bin/*.sh as executacle: chmod +x \${cef_edelivery_path}/domibus/bin/*.sh"
   chmod +x ${cef_edelivery_path}/domibus/bin/*.sh
}


#####################################################################################################################
##### MAIN PROGRAMM START HERE
####################################################################################################################

clear

displayBanner
sourceExternalFunctions
checkDomInstallPropertiesFiles
getDomibusInstallProperties
initInstallation
downloadJavaJDKJRE
downloadJDBC
getDomibus "${DomibusVersion}" "${ApplicationServer}" "${DomibusInstallationType}" "${DOWNLOAD_DIR}/Domibus/${DomibusVersion}"
initDatabase

echo $'\n\nStarting Domibus Installation'

case "$ApplicationServer" in
   "WebLogic") echo "Installing Domibus on WebLogic..."
      case "${DomibusInstallationType}" in
         "Full")  echo "WebLogic Pre-Configure Full Deployment is not supported."
            ;;
         "Single")  echo  "Domibus Oracle WebLogic Single Server Deployment"
            installDomibusWebLogicSingle
            ;;
         "Cluster")  echo  "Domibus Oracle WebLogic Clustered Server Deployment"
            installDomibusWebLogicCluster
            ;;
      esac
      ;;
   "Tomcat") echo ; echo "Installing Tomcat"
       installDomibusTomcatSingle
      ;;
   "WildFly") echo ; echo "Installing Wildfly"
      case "${DomibusInstallationType}" in
         "Full")  echo "Pre-configured Full Deployment"
            installDomibusWildFlyFull 
            ;;
         "Single")  echo  "Single Server Deployment"
            installDomibusWildFlySingle
            ;;
         "Cluster")  echo  "Clustered Server Deployment"
            installDomibusWildFlyCluster
            ;;
      esac
      ;;
esac

exit

