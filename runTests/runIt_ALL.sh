
#/bin/bash

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ; echo "WORKING_DIR=${WORKING_DIR}"

function displayFunctionBanner {
   echo ;
   echo "####################################################################"
   echo "### FUNCTION: $1"
   echo "####################################################################"
}

function ABORT_JOB {
   displayFunctionBanner ${FUNCNAME[0]}

   message="${1}"
   echo
   echo "#################################################################################################"
   echo "### FATAL ERROR ABORTING: ${message}"
   echo "#################################################################################################"
   exit 9
}

function parseParameters {

args="$@"

eval set -- "${args}"

while [ $# -ge 1 ]; do
        case "$1" in
		--)
                        # No more options left.
                        shift
                        break
                        ;;
		-b|--build)
                        BUILD_DOMIBUS="build"
                        shift
                        ;;
		-B|--BUILD)
                        BUILD_DOMIBUS="BUILD"
                        shift
                        ;;
		-t|--tests)
                        RUNSOAPUITESTS="YES"
                        shift
                        ;;
		-h|--help)
                        echo "Display some help:"
                        echo "-b --build	: build Domibus without Unit Tests"
                        echo "-B --BUILD	: build Domibus WITH Unit Tests (Takes longer time)"
                        echo "-t --test	: Run SoapUI Automated Tests"
                        echo "-h --help	: Domibus Server User and Password"
                        exit 0
                        ;;
        esac

        shift
done
}

function getDomibus {
   rm -rf ${WORKING_DIR}/domibus
   git clone https://ec.europa.eu/cefdigital/code/scm/edelivery/domibus.git ${WORKING_DIR}/domibus
   cd ${WORKING_DIR}/domibus
   git fetch

   if [ ! "$1" == "" ] ; then
      git checkout origin/$1
   fi
}

function getDocker {
	rm -rf ${WORKING_DIR}/docker
	git clone https://ec.europa.eu/cefdigital/code/scm/edelivery/docker.git
	cd ${WORKING_DIR}/docker

   if [ ! "$1" == "" ] ; then
      git checkout origin/$1
   fi
}

function buildDomibus {
   if [ ! "X${BUILD_DOMIBUS}" == "X" ] ; then
      cd ${WORKING_DIR}/domibus
      if [ "${BUILD_DOMIBUS}" == "build" ] ; then
         echo; echo "Domibus Build requested WITHOUT Unit Tests (-b or --build)"
         mvn clean install -Ptomcat -Pweblogic -Pwildfly -Pdefault-plugins -Pdatabase -Psample-configuration -Pdistribution -DskipITs=true -DskipTests=true
         [ $? -ne 0 ] && ABORT_JOB "ERROR during Domibus Build"
      else
         echo ; echo "Domibus Build requested WITH Unit Tests (-B or --BUILD)"
         mvn clean install -Ptomcat -Pwildfly -Pweblogic -Pdefault-plugins -Pdatabase -Psample-configuration -Pdistribution
         [ $? -ne 0 ] && ABORT_JOB "ERROR during Domibus Build"
      fi
   else
      echo ; echo "Domibus Build NOT REQUESTED"
   fi
}

function buildCentOS7Image {
   cd ${WORKING_DIR}/docker/dockerbuild/build/100-Centos7
   ./go.sh "$@"
}

function buildMySQLImage {
   cd ${WORKING_DIR}/docker/dockerbuild/build/105-c7mys7
   ./go.sh ${WORKING_DIR}/domibus/Domibus-MSH-distribution/target
   #./go.sh 3.3-RC1
}

function buildOracleImage {
   cd ${WORKING_DIR}/docker/dockerbuild/build/125-OracleDB
   ./go.sh "$@"
}

function buildC7WebLogicImage {
   cd ${WORKING_DIR}/docker/dockerbuild/build/110-centos7-weblogic
   ./go.sh "$@"
}

function buildDomibusTomcatImage {
   cd ${WORKING_DIR}/docker/dockerbuild/build/domibus/130-c7-domibus-tomcat
   ./dockerBuild.sh "$@"
}

function buildWilMysImage {
   cd ${WORKING_DIR}/docker/dockerbuild/build/domibus/140-c7-wil-mys-domibus
   ./go.sh
}

function buildWilOraImage {
   cd ${WORKING_DIR}/docker/dockerbuild/build/domibus/150-c7-wil-ora-domibus
   ./go.sh
}

function buildWebLogicImage {
   cd ${WORKING_DIR}/docker/dockerbuild/build/domibus/200-c7-wls-mys-domibus
   ./go.sh
}

function StartCompose {
   cd ${WORKING_DIR}/docker/dockerbuild/compose
   echo $@
   ./scripts/runCompose.sh $@
}

function runSoapUITests {

   cd "${WORKING_DIR}/domibus/Domibus-MSH-soapui-tests"

   ADMIN_USER="admin"
   ADMIN_PASSW="123456"


   DOMIBUS_ARTEFACTS="$1"

   if [ "X${2}" == "X" ] ; then
      ABORT_JOB "Parameter ${2} CANNOT BE EMPTY"
   else
      applicationServer="`echo ${2} | tr '[:upper:]' '[:lower:]'`"
      echo ${applicationServer}
      if [ ! "${applicationServer}" == "tomcat" ] && [ ! "${applicationServer}" == "wildfly" ] && [ ! "${applicationServer}" == "weblogic" ] ; then
         ABORT_JOB "\${applicationServer} must be [Tomcat|WildFly|WebLogic] (${applicationServer})"
      else
         urlExtension=""
         if [ "${applicationServer}" == "wildfly" ] ||  [ "${applicationServer}" == "weblogic" ]; then
            urlExtension="-${applicationServer}"
         fi
      fi
   fi

   if [ "X${3}" == "X" ] ; then
      ABORT_JOB "Parameter ${3} CANNOT BE EMPTY"
   else
      databaseType="`echo ${3} | tr '[:upper:]' '[:lower:]'`"
      if [ ! "${databaseType}" == "mysql" ] && [ ! "${databaseType}" == "oracle" ] ; then
         ABORT_JOB "\${databaseType} must be [MySQL|Oracle] (${databaseType})"
      fi
   fi

   # Install  JDBC Driver needed for the SoapUI Tests
   if [ "${databaseType}" == "mysql" ] ; then
      ${WORKING_DIR}/docker/runTests/getJDBCDriverMySQL.sh 5.1.40 ./src/main/soapui/lib
   else
      echo ; echo "Copying Oracle JDBC Drivers: cp /datadrive/bamboo-repo/Oracle/jdbc/* ./src/main/soapui/lib"
      cp /datadrive/bamboo-repo/Oracle/jdbc/* ./src/main/soapui/lib
   fi

   SOURCE_CODE="${WORKING_DIR}/domibus/Domibus-MSH-distribution"

   case "${databaseType}" in
      "mysql") echo ; echo "Starting Tests for ${databaseType}"
         ${WORKING_DIR}/docker/runTests/runTests.sh			\
         ${DOMIBUS_ARTEFACTS}						\
         "localUrl=http://localhost:18081/domibus${urlExtension}"	\
         "remoteUrl=http://localhost:18082/domibus${urlExtension}"	\
         "jdbcUrlBlue=jdbc:mysql://127.0.0.1:13306/domibus"		\
         "jdbcUrlRed=jdbc:mysql://127.0.0.1:23306/domibus"		\
         "driverBlue=com.mysql.jdbc.Driver"				\
         "driverRed=com.mysql.jdbc.Driver"				\
         "databaseBlue=mysql"						\
         "databaseRed=mysql"						\
         "blueDbUser=root"						\
         "blueDbPassword=123456"					\
         "redDbUser=root"						\
         "redDbPassword=123456"
      ;;
      "oracle") echo ; echo "Starting Tests for ${databaseType}"
         ${WORKING_DIR}/docker/runTests/runTests_oracle.sh		\
         ${DOMIBUS_ARTEFACTS}						\
         "localUrl=http://localhost:18081/domibus${urlExtension}"	\
         "remoteUrl=http://localhost:18082/domibus${urlExtension}"	\
         "jdbcUrlBlue=jdbc:oracle:thin:@127.0.0.1:11521/XE"		\
         "jdbcUrlRed=jdbc:oracle:thin:@127.0.0.1:21521/XE"		\
         "driverBlue=oracle.jdbc.OracleDriver"				\
         "driverRed=oracle.jdbc.OracleDriver"				\
         "databaseBlue=oracle"						\
         "databaseRed=oracle"						\
         "blueDbUser=edelivery"						\
         "redDbUser=edelivery"						\
         "blueDbPassword=edelivery"					\
         "redDbPassword=edelivery"
      ;;
   esac
}

#####################################################
# MAIN PROGRAM STARTS HERE
#####################################################

parseParameters "$@"

#export DOMIBUS_VERSION=3.3
#export REPO=/Users/idragusa/work/run_docker/repo/
#export ORACLE_REPO=${REPO}/Oracle/OracleDatabase
echo "REPO=$REPO"
echo "DOMIBUS_VERSION=$DOMIBUS_VERSION"

getDomibus tags/3.3
buildDomibus

getDocker EDELIVERY-2784-docker

buildCentOS7Image ${REPO}
buildC7WebLogicImage ${REPO}

buildMySQLImage
buildOracleImage ${ORACLE_REPO}/11.2.0.1

buildDomibusTomcatImage Oracle
buildWebLogicImage
buildWilMysImage
buildWilOraImage

docker-compose -f ${WORKING_DIR}/docker/dockerbuild/compose/compose-projects/C2TomcatMySql-C3TomcatMySqlConfigRed.yml up -d
echo "sleep 400"
sleep  400
runSoapUITests ${WORKING_DIR}/domibus/Domibus-MSH-distribution/target tomcat mysql
docker rm -f -v $(docker ps -a -q)

docker-compose -f ${WORKING_DIR}/docker/dockerbuild/compose/compose-projects/C2WeblogicMySql-C3WeblogicMySql.yml up -d
echo "sleep 400"
sleep  400
runSoapUITests ${WORKING_DIR}/domibus/Domibus-MSH-distribution/target weblogic mysql
docker rm -f -v $(docker ps -a -q)

docker-compose -f ${WORKING_DIR}/docker/dockerbuild/compose/compose-projects/C2WildflyMySql-C3WildflyMysql.yml up
echo "sleep 400"
sleep  400
runSoapUITests ${WORKING_DIR}/domibus/Domibus-MSH-distribution/target wildfly mysql
docker rm -f -v $(docker ps -a -q)

#docker-compose -f ${WORKING_DIR}/docker/dockerbuild/compose/compose-projects/C2TomcatMySqlConfig1-C3TomcatMySqlConfig2.yml up
#docker-compose -f ${WORKING_DIR}/docker/dockerbuild/compose/compose-projects/C2TomcatOracleConfig1-C3TomcatOracleConfig2.yml up
#docker-compose -f ${WORKING_DIR}/docker/dockerbuild/compose/compose-projects/C2TomcatMySql-C3WeblogicOracle.yml up

exit

