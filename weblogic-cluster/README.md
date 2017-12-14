# Domibus Weblogic Cluster Test Environment on Docker

## Overview

This project consists of the following directories:

* images 
* compose

## Pre-Requisites 

In order to proceed with the project setup perform the following:

### Prepare Host User

* Create a system user to execute this project services 
(these notes are assuming 'domibus' as the system user but it can be another existing user)
```
useradd -d /home/domibus -m -s /bin/bash domibus
```   
* As the project uses Docker containers and we don't want our user to be a sudoer but want him to be able to issue Docker commands, we'll add him to the docker system group, which grants permissions on docker daemon:
```
usermod -a -G docker domibus
```

### Prepare local file share mount directories

* Prepare local file share mount directories to be used by the Domibus FS Plugin

* Create the following directories for each eDelivery corner, under domibus user home dir as we use this user to manage all the domibus instances:
```
mkdir -p ~/domibus-files-wlc_c2/fs_plugin_data/MAIN
mkdir -p ~/domibus-files-wlc_c3/fs_plugin_data/MAIN
mkdir -p ~/domibus-files-wlc_c2/persistent_filestore
mkdir -p ~/domibus-files-wlc_c3/persistent_filestore
```

### Build images

Download resources:

* Download the following resources to images/edelivery-weblogic-cluster/resources/:
```
   https://github.com/jwilder/dockerize/releases/download/v0.6.0/dockerize-linux-amd64-v0.6.0.tar.gz
   http://download.oracle.com/otn/nt/middleware/12c/wls/1213/fmw_12.1.3.0.0_wls.jar
   http://download.oracle.com/otn/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.tar.gz
```

* Download the following resources to images/weblogic-cluster-domibus/resources/:
```
   https://ec.europa.eu/cefdigital/artifact/content/repositories/eDelivery/eu/europa/ec/digit/ipcis/wslt-api/1.9.1/wslt-api-1.9.1.zip
   https://ec.europa.eu/cefdigital/artifact/service/local/repositories/eDelivery/content/eu/domibus/domibus-distribution/3.3/domibus-distribution-3.3-weblogic-war.zip
   https://ec.europa.eu/cefdigital/artifact/service/local/repositories/eDelivery/content/eu/domibus/domibus-distribution/3.3/domibus-distribution-3.3-default-fs-plugin.zip
   https://ec.europa.eu/cefdigital/artifact/service/local/repositories/eDelivery/content/eu/domibus/domibus-distribution/3.3/domibus-distribution-3.3-default-ws-plugin.zip
   https://ec.europa.eu/cefdigital/artifact/service/local/repositories/eDelivery/content/eu/domibus/domibus-distribution/3.3/domibus-distribution-3.3-sample-configuration-and-testing.zip
   https://ec.europa.eu/cefdigital/artifact/service/local/repositories/eDelivery/content/eu/domibus/domibus-distribution/3.3/domibus-distribution-3.3-default-jms-plugin.zip
   https://ec.europa.eu/cefdigital/artifact/service/local/repositories/eDelivery/content/eu/domibus/domibus-distribution/3.3/domibus-distribution-3.3-weblogic-configuration.zip
   https://ec.europa.eu/cefdigital/artifact/service/local/repositories/eDelivery/content/eu/domibus/domibus-distribution/3.3/domibus-distribution-3.3-sql-scripts.zip
```

Build if the images were not built yet, please build all images:
* oraclexe-domibus
* edelivery-weblogic-cluster
* weblogic-cluster-domibus

```
cd images
docker-compose -f docker-compose.build.yml build
```

### Run Test Corner2 and Corner3

Initialize the correspondent Docker Compose project:
```
cd compose/test/
docker-compose up -d && docker-compose logs -f
```
Notes:
- You'll need to adapt some build arguments and environment variables defined on docker-compose.yml in order to reflect your environment hostnames and ports;
- You'll need to define the following on domibus user environment (via ~/.bashrc for example) before being able to use docker-compose: export USER_ID=$(id -u $USER)

* Right after the first project startup you must delete Oracle DB initialization scripts as its container image will always execute any scripts that finds on startup:
* See if the container logs show that the initialization scripts were executed (if they have you'l see output about db inserts, updates, etc):
```
docker-compose logs oraclexe
```
* Remove the initialization scripts:
```
docker-compose exec oraclexe sh -c 'rm -rf /docker-entrypoint-initdb.d/*'
```

* TODO AUTOMATED: Save the message filter configuration:
* Access Corner 2 Domibus URL: http://<VHOST_C2_HOSTNAME>/domibus-weblogic/
* Authenticate with the admin user;
* Access the "Message Filter";
* Modify the filters order so that the FS Plugin is in the first position;
* Click on "Save".
   
## Setup Network File Shares (On Host machine)

Setup the network file shares to be used by Domibus FS Plugin.

### Samba Share

* Make sure you have Samba installed on your Host (adapt the command and package name to your OS):
```
apt-get install samba
```
* Set a password for the domibus user in Samba credentials store:
```
smbpasswd -a domibus
```
* Create the following directories for each eDelivery corner, under domibus user home dir as we use this user to manage all the domibus instances:
```   
mkdir -p /home/domibus/domibus-files-wlc_c2/smb_plugin_data/OUT
mkdir -p /home/domibus/domibus-files-wlc_c3/smb_plugin_data/OUT
```
* Copy the correspondent metadata.xml file, available on this project "conf" directory:
```
cp conf/metadata_samples/smb_c2_metadata.xml ~/domibus-files-wlc_c2/smb_plugin_data/OUT/metadata.xml
cp conf/metadata_samples/smb_c3_metadata.xml ~/domibus-files-wlc_c3/smb_plugin_data/OUT/metadata.xml
```
* Add the following to the end of the file "/etc/samba/smb.conf":
```
[wlc_smb_plugin_data_c2]
  path = /home/domibus/domibus-files-wlc_c2/smb_plugin_data
  valid users = domibus
  read only = no
[wlc_smb_plugin_data_c3]
  path = /home/domibus/domibus-files-wlc_c3/smb_plugin_data
  valid users = domibus
  read only = no
```
* Restart Samba service:
```
service smbd restart
```

### SFTP Share

* If you already have an SSH server configured on the Host, as is typical, add a password to the domibus user so that he can connect through SSH:
```
passwd domibus
```
* Create the following directories for each eDelivery corner, under domibus user home dir as we use this user to manage all the domibus instances:
```
mkdir -p /home/domibus/domibus-files-wlc_c2/sftp_plugin_data/OUT
mkdir -p /home/domibus/domibus-files-wlc_c3/sftp_plugin_data/OUT
```
* Copy the correspondent metadata.xml file, available on this project "conf" directory:
   $> cp conf/metadata_samples/sftp_c2_metadata.xml ~/domibus-files-wlc_c2/sftp_plugin_data/OUT/metadata.xml
   $> cp conf/metadata_samples/sftp_c3_metadata.xml ~/domibus-files-wlc_c3/sftp_plugin_data/OUT/metadata.xml

### FTP Share

* Make sure you have FTP installed on your Host (adapt the command and package name to your OS):
```
apt-get install vsftpd
```
* Change the following configurations on "/etc/vsftpd.conf":
```
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
```
* Restart FTP service:
```
service vsftpd restart
```
* Create the following directories for each eDelivery corner, under domibus user home dir as we use this user to manage all the domibus instances:
```
mkdir -p /home/domibus/domibus-files-wlc_c2/ftp_plugin_data/OUT
mkdir -p /home/domibus/domibus-files-wlc_c3/ftp_plugin_data/OUT
```
* Copy the correspondent metadata.xml file, available on this project "conf" directory:
```
cp conf/metadata_samples/ftp_c2_metadata.xml ~/domibus-files-wlc_c2/ftp_plugin_data/OUT/metadata.xml
cp conf/metadata_samples/ftp_c3_metadata.xml ~/domibus-files-wlc_c3/ftp_plugin_data/OUT/metadata.xml
```

# Note on wslt-api-1.9.1

The WLST API doesn’t support yet the waitTimeInMillis parameter. We can create a request to the team responsible for
developing it but it will take some time, so I would not rely on this to have it fast.
In the meantime you can modify locally for your specific case the python scripts(in the jar WSLT/lib/wlstscripts.jar
modify the WlsUtilities.py script ) that the WLST uses to import the properties file.

Quick Fix Procedure:
* Extract wslt-api-1.9.1.zip
* Go to /wslt-api-1.9.1/lib/
* Extract wlstscripts.jar
* Open file /eu/cec/digit/wlst/utils/WlsUtilities.py
* Modify line 244 changing "wlst.startEdit()" to "wlst.startEdit(waitTimeInMillis=60000)"
* Repackage wslt-api-1.9.1.zip according to the original

# Soap UI Test

TODO:
* Automate test execution
* Confirm ojdbc7 dependency on Domibus-MSH-soapui-tests
<dependency>
    <groupId>com.oracle</groupId>
    <artifactId>ojdbc7</artifactId>
    <version>12.1.0</version>
</dependency>

mvn com.smartbear.soapui:soapui-pro-maven-plugin:5.1.2:test \
-DlocalUrl="http://localhost:7002/domibus-weblogic" \
-DremoteUrl="http://localhost:7102/domibus-weblogic" \
-DjdbcUrlBlue="jdbc:oracle:thin:@127.0.0.1:49161/XE" \
-DjdbcUrlRed="jdbc:oracle:thin:@127.0.0.1:49261/XE" \
-DdriverBlue="oracle.jdbc.OracleDriver" \
-DdriverRed="oracle.jdbc.OracleDriver" \
-DdatabaseBlue="oracle" \
-DdatabaseRed="oracle" \
-DblueDbUser="domibus" \
-DredDbUser="domibus" \
-DblueDbPassword="XXXXXX" \
-DredDbPassword="XXXXXX"

### Run Load Balancer

TODO Update

Start the Apache httpd reverse proxy (and load balancer) Docker container which will serve both corners:
* Navigate to this project Apache image directory:
```
cd docker/apache/
```
* Build the image:
```
docker build -t httpd_domibusfs:2.4 .
```
Note: You'll need to adapt some argument variables defined on Dockerfile in order to reflect your environment hostnames and ports.
* Create a container for our image:
```
docker run --name httpd -p 80:80 --restart=always -d httpd_domibusfs:2.4
```

