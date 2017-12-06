#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Set DEBUG TO 1 to activate debugging
DEBUG=0


CATALINA_HOME=$1 #/data/tomcat
export CATALINA_HOME=$CATALINA_HOME

DOM_INSTALL=$2 #/data/domInstall
echo "--------------CATALINA_HOME: ${CATALINA_HOME}"
echo "--------------DOM_INSTALL: ${DOM_INSTALL}"

function sourceExternalFunctions {

   echo ; echo "--Sourcing External Functions:"

   . /data/domInstall/scripts/functions/common.functions
   . /data/domInstall/scripts/functions/downloadJDBC.functions
   . /data/domInstall/scripts/functions/Tomcat.functions
}

function downloadTomcat {
   displayFunctionBanner ${FUNCNAME[0]}

   TomcatVersion = "8.0.39"
   TomcatArchiveLocation = $DOM_INSTALL/tomcat

   echo "   - Downloading Apache Tomcat Software Version ${TomcatVersion}"

   TomcatMainVersion="`echo ${TomcatVersion} | cut -c1-1`"
   TomcatDownloadUrl=" http://archive.apache.org/dist/tomcat/tomcat-${TomcatMainVersion}/v${TomcatVersion}/bin/apache-tomcat-${TomcatVersion}.tar.gz"


   echo "   - Downloading: ${TomcatDownloadUrl} in $TomcatArchiveLocation"
   echo "wget -P $TomcatArchiveLocation ${TomcatDownloadUrl} --no-check-certificate"
   wget -P $TomcatArchiveLocation ${TomcatDownloadUrl} --no-check-certificate
}

function installTomcat {
   displayFunctionBanner ${FUNCNAME[0]}

   TomcatVersion = "8.0.39"
   TomcatArchiveLocation = $DOM_INSTALL/tomcat

   echo "Creating $TomcatArchiveLocation directory"
   mkdir -p ${TomcatArchiveLocation}

   echo "   - Downloading Apache Tomcat Software Version ${TomcatVersion} in ${TomcatArchiveLocation}"

   TomcatMainVersion="`echo ${TomcatVersion} | cut -c1-1`"
   TomcatDownloadUrl=" http://archive.apache.org/dist/tomcat/tomcat-${TomcatMainVersion}/v${TomcatVersion}/bin/apache-tomcat-${TomcatVersion}.tar.gz"

   echo "   - Downloading: ${TomcatDownloadUrl} in $TomcatArchiveLocation"
   echo "wget -P $TomcatArchiveLocation ${TomcatDownloadUrl} --no-check-certificate"
   wget -P $TomcatArchiveLocation ${TomcatDownloadUrl} --no-check-certificate

   echo
   echo "Creating $CATALINA_HOME directory"
   mkdir -p ${CATALINA_HOME}
   echo "Installing Tomcat Version ${TomcatVersion} in ${CATALINA_HOME}"
   tar xfz $TomcatArchiveLocation/apache-tomcat-${TomcatVersion}.tar.gz -C ${CATALINA_HOME} --strip 1
}


installTomcat
#downloadJDBC

exit

