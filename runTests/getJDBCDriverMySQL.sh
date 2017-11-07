#!/bin/bash

MySQL_JDBCDriverVersion="${1}"
MySQL_JDBCDriverDestination="${2}"

MySQL_JDBCDriverDownloadURL="https://dev.mysql.com/get/Downloads/Connector-J"
MySQL_JDBCDriverDefaultVersion="5.1.40"

# Install MySQL JDBC Driver needed for the SoapUI Tests

if [ "x${MyQSL_JDBCDriverVersion}" == "x" ] ; then
   MySQL_JDBCDriver="mysql-connector-java-${MySQL_JDBCDriverDefaultVersion}"
else
   MySQL_JDBCDriver="mysql-connector-java-${MySQL_JDBCDriverVersion}"
fi

echo
echo "   Downloading: ${MySQL_JDBCDriver}.zip"
echo "   From	 : ${MySQL_JDBCDriverDownloadURL}"
wget ${MySQL_JDBCDriverDownloadURL}/${MySQL_JDBCDriver}.zip 

echo ; echo "   Unzipping ${MySQL_JDBCDriver}.zip"
unzip -o ${MySQL_JDBCDriver}.zip

echo ; echo "   Coying	: ${MySQL_JDBCDriver}/${MySQL_JDBCDriver}-bin.jar"
echo "   To	: ${MySQL_JDBCDriverDestination}"
cp ${MySQL_JDBCDriver}/${MySQL_JDBCDriver}-bin.jar ${MySQL_JDBCDriverDestination}
