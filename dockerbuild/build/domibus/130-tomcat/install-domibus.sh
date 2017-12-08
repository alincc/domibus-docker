#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Set DEBUG TO 1 to activate debugging
DEBUG=0

CATALINA_HOME=$1 #/data/tomcat
export CATALINA_HOME=$CATALINA_HOME

DOM_INSTALL=$2 #/data/domInstall
JDBC_DRIVER_DIR=$3


echo "--------------CATALINA_HOME: ${CATALINA_HOME}"
echo "--------------DOM_INSTALL: ${DOM_INSTALL}"
echo "--------------JDBC_DRIVER_DIR: ${JDBC_DRIVER_DIR}"

function sourceExternalFunctions {

   echo ; echo "--Sourcing External Functions:"

   ls -la $DOM_INSTALL

   . $DOM_INSTALL/scripts/functions/common.functions
   . $DOM_INSTALL/scripts/functions/downloadJDBC.functions
}

function installTomcat {
   displayFunctionBanner ${FUNCNAME[0]}

   local TomcatVersion="8.0.39"
   local TomcatArchiveLocation="$DOM_INSTALL/tomcat"
   local TomcatMainVersion=`echo ${TomcatVersion} | cut -c1-1`
   local TomcatDownloadUrl="http://archive.apache.org/dist/tomcat/tomcat-${TomcatMainVersion}/v${TomcatVersion}/bin/apache-tomcat-${TomcatVersion}.tar.gz"

   echo "Creating $TomcatArchiveLocation directory"
   mkdir -p ${TomcatArchiveLocation}

   echo "   - Downloading Apache Tomcat Software Version ${TomcatVersion} in ${TomcatArchiveLocation}"

   echo "   - Downloading: ${TomcatDownloadUrl} in $TomcatArchiveLocation"
   echo "wget -P $TomcatArchiveLocation ${TomcatDownloadUrl} --no-check-certificate"
   wget -P $TomcatArchiveLocation ${TomcatDownloadUrl} --no-check-certificate

   echo
   echo "Creating $CATALINA_HOME directory"
   mkdir -p ${CATALINA_HOME}
   echo "Installing Tomcat Version ${TomcatVersion} in ${CATALINA_HOME}"
   tar xfz $TomcatArchiveLocation/apache-tomcat-${TomcatVersion}.tar.gz -C ${CATALINA_HOME} --strip 1
}

function installJdbcDrivers {
   echo "Listing $JDBC_DRIVER_DIR directory"
   ls -la ${JDBC_DRIVER_DIR}
   cp ${JDBC_DRIVER_DIR}/* ${CATALINA_HOME}/lib
}
sourceExternalFunctions
installTomcat
installJdbcDrivers

rm -r ${DOM_INSTALL}

exit

