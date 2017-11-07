#!/bin/bash

WORKING_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
echo "Working Directory: ${WORKING_DIR}"


echo
echo "This script will take the specified Dockerfile file(s)"
echo "and will generate a Docker Image of the same name (without the .Dockerfile extension)"
echo

function displayFunctionBanner {
   echo ;
   echo "####################################################################"
   echo "### FUNCTION: $1"
   echo "####################################################################"
}

function abortJob {
   echo
   echo "#################################################################################################"
   echo "### FATAL ERROR ABORTING: $1"
   echo "#################################################################################################"
   exit 9
}

function checkFileExists {
   displayFunctionBanner ${FUNCNAME[0]}

   file2Check="${1}"
   if [ "X${file2Check}" == "X" ]  ; then
      echo ; echo "The File/Directory parameter provided is NULL"
   else
      if [ -e ${file2Check} ] ; then
         true
      else
	 false
      fi
   fi 
}

function getAndCheckParameters {
   displayFunctionBanner ${FUNCNAME[0]}

   args="$@"

   eval set -- "${args}"

   while [ $# -ge 1 ]; do
      case "$1" in
         --)
            # No more options left.
            shift
            break
            ;;
         -dcf|--dockerComposeFile)
            dockerComposeFile="$2"
            shift
            ;;
         -acb|--alternateConfigBlue)
            alternateConfigBlue="$2"
            shift
            ;;
         -acr|--alternateConfigRed)
            alternateConfigRed="$2"
            shift
            ;;
         -h|--help)
            echo "Display HELP:"
            echo "-dcf|--dockerComposeFile	: Docker-Compose File"
            echo "-acb|--alternateConfigBlue	: Alternate Config Mount Point for Domibus Instance: Blue"
            echo "-acr|--alternateConfigRed	: Alternate Config Mount Point for Domibus Instance: Red"
            echo "-h|--help			: Display Help"
            exit 0
            ;;
        esac

        shift
   done

   echo ; echo "Starting Docker Compose with the following parameters:"
   echo "   dockerComposeFile	= ${dockerComposeFile}"
   echo "   alternateConfigBlue	= ${alternateConfigBlue}"
   echo "   alternateConfigRed	= ${alternateConfigRed}"

   echo ; echo " Checking if the Specified Docker-compose File exists: ${dockerComposeFile}"

   overrideComposeFile=false
   
   if checkFileExists "${dockerComposeFile}" ; then
      echo "   The Specified Docker-compose File exists: ${dockerComposeFile}"
   else
      echo "   The Specified Docker-compose File DOES NOT EXISTS: ${dockerComposeFile}"
      abortJob
   fi     

   if [ ! "X${alternateConfigBlue}" == "X" ] ; then
      echo "   ALTERATE CONFIGURATION MOUNT POINT Specified for Domibus Instance Blue: ${alternateConfigBlue}"
      if checkFileExists "${alternateConfigBlue}" ; then
         echo "   The specified directory exists: ${alternateConfigBlue}"
         overrideComposeFile=true
      else
         echo "   The specified for Domibus Instance Blue DOES NOT EXISTS: ${alternateConfigBlue}"
         abortJob
      fi
   else
      echo "   No Alternate Configuration mount point specified for Domibus Instance:Blue"
   fi

   if [ ! "X${alternateConfigRed}" == "X" ] ; then
      echo "   ALTERATE CONFIGURATION MOUNT POINT Specified for Domibus Instance Blue: ${alternateConfigRed}"
      if checkFileExists "${alternateConfigRed}" ; then
         echo "   The specified directory exists: ${alternateConfigRed}"
         overrideComposeFile=true
      else
         echo "   The specified Mount Point for Domibus Instance Red DOES NOT EXISTS: ${alternateConfigRed}"
         abortJob
      fi
   else
      echo "   No Alternate Configuration mount point specified for Domibus Instance:Red"
   fi
}

function createAlternateComposeFile {
   displayFunctionBanner ${FUNCNAME[0]}

   if ${overrideComposeFile} ; then
      
      filename=$(basename "${dockerComposeFile}")
      extension="${filename##*.}"
      filename="${filename%.*}"

      dockerComposeOverrideFile="${WORKING_DIR}/../${filename}.override.${extension}"

      echo  ; echo "Creating Docker-Compose override File: ${dockerComposeOverrideFile}"

      echo "version: '2'"> ${dockerComposeOverrideFile}
      echo "services:"	>> ${dockerComposeOverrideFile}

      if [ ! "X${alternateConfigBlue}" == "X" ] ; then
         echo ; echo "   Adding entries for Domibus Instance: Blue"
         echo "   domibusblue:"	>> ${dockerComposeOverrideFile}
         echo "      volumes:" 	>> ${dockerComposeOverrideFile}
         echo "         - ${alternateConfigBlue}:/data/domibus/domibus/conf/domibus" >> ${dockerComposeOverrideFile}
      fi

      if [ ! "X${alternateConfigRed}" == "X" ] ; then
         echo  ; echo "   Adding entries for Domibus Instance: Red"
         echo "   domibusred:" 	>> ${dockerComposeOverrideFile}
         echo "      volumes:"	>> ${dockerComposeOverrideFile}
         echo "         - ${alternateConfigRed}:/data/domibus/domibus/conf/domibus" >> ${dockerComposeOverrideFile}
      fi

     echo ; echo "Resulting Docker-Compose override File: ${dockerComposeOverrideFile}"
     cat ${dockerComposeOverrideFile}
   else
      echo ; echo "NO MOUNT POINT SPECIFIED FOR DOMIBUS INSTANCES BLUE OR RED"
   fi
}

function runDockerCompose {
   displayFunctionBanner ${FUNCNAME[0]}

   if !  ${overrideComposeFile} ; then
      echo ; echo "   Starting Docker-Compose: docker-compose -f ${dockerComposeFile} up -d"
      docker-compose -f ${dockerComposeFile} up -d
   else
      echo ; echo "   Starting Docker-Compose: docker-compose -f ${dockerComposeFile} -f ${dockerComposeOverrideFile} up -d"
      docker-compose -f ${dockerComposeFile} -f ${dockerComposeOverrideFile} up -d
   fi
}

#################################################################################################
##### MAIN SCRIPT STARTS HERE
#################################################################################################

getAndCheckParameters "$@"
createAlternateComposeFile
runDockerCompose

exit

