#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Set DEBUG TO 1 to activate debugging
DEBUG=0

DomibusInstallationDir=/data/domibus
echo "--------------DomibusInstallationDir: ${DomibusInstallationDir}"

function displayBanner {
   cat ${SCRIPTPATH}/scripts/textBanner.txt
}

function sourceExternalFunctions {

   echo ; echo "--Sourcing External Functions:"

   . ../../../../domInstall/scripts/functions/common.functions
   . ../../../../domInstall/scripts/functions/downloadJDBC.functions
   . ../../../../domInstall/scripts/functions/getDomibus.functions
   . ../../../../domInstall/scripts/functions/Tomcat.functions
}

function getDomibusInstallProperties {
   displayFunctionBanner ${FUNCNAME[0]}

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

   echo "TomcatInstallType $DefaultValuesTomcatInstallType      : $TomcatInstallType"
   echo "TomcatVersion $DefaultValuesTomcatVersion                : ${TomcatVersion}"
   echo
}

function initInstallation {
   displayFunctionBanner ${FUNCNAME[0]}

   # Domibus Directory
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
   fi

    # Temporary Directory; used for storing the cookie.txt
  export TEMP_DIR=${DomibusInstallationDir}/temp
  echo "Creating Temporary Directory: \${TEMP_DIR}"
  echo " - mkdir ${TEMP_DIR}"
  mkdir $TEMP_DIR


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
}

#####################################################################################################################
##### MAIN PROGRAMM START HERE
####################################################################################################################

clear

displayBanner
sourceExternalFunctions
getDomibusInstallProperties
initInstallation
downloadJDBC
getDomibus "${DomibusVersion}" "${ApplicationServer}" "${DomibusInstallationType}" "${DOWNLOAD_DIR}/Domibus/${DomibusVersion}"
echo $'\n\nStarting Domibus Installation'
installDomibusTomcatSingle

exit

