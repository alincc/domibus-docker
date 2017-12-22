# Domibus Weblogic Cluster Test Environment on Docker

## Pre-Requisites 

In order to proceed with the project setup perform the following:

### Prepare host

Create a system user to execute this project services 
(these notes are assuming 'domibus' as the system user but it can be another existing user)
```
useradd -d /home/domibus -m -s /bin/bash domibus
```   
As the project uses Docker containers and we don't want our user to be a sudoer but want him to be able to issue Docker commands, we'll add him to the docker system group, which grants permissions on docker daemon:
```
usermod -a -G docker domibus
```
Define the following environment on host environment (via ~/.bashrc for example)
```
export USER_ID=$(id -u $USER)
```

### Download image external resources

Download the following resources to images/edelivery-weblogic-cluster/resources/:
```
   https://github.com/jwilder/dockerize/releases/download/v0.6.0/dockerize-linux-amd64-v0.6.0.tar.gz
   http://download.oracle.com/otn/nt/middleware/12c/wls/1213/fmw_12.1.3.0.0_wls.jar
   http://download.oracle.com/otn/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.tar.gz
```
Download the following resources to RESOURCES_REPO/weblogic-cluster-domibus/resources/:
```
   https://ec.europa.eu/cefdigital/artifact/content/repositories/eDelivery/eu/europa/ec/digit/ipcis/wslt-api/1.9.1/wslt-api-1.9.1.zip
```

Image resources repository structure:
```
images
├── edelivery-weblogic-cluster
│   └── resources
│       ├── dockerize-linux-amd64-v0.6.0.tar.gz
│       ├── fmw_12.1.3.0.0_wls.jar
│       └── jdk-8u144-linux-x64.tar.gz
├── oraclexe-domibus
│   └── resources
│       └── domibus-distribution-${DOMIBUS_VERSION}-sql-scripts.zip
└── weblogic-cluster-domibus
    └── resources
        ├── domibus-distribution-${DOMIBUS_VERSION}-default-fs-plugin.zip
        ├── domibus-distribution-${DOMIBUS_VERSION}-default-jms-plugin.zip
        ├── domibus-distribution-${DOMIBUS_VERSION}-default-ws-plugin.zip
        ├── domibus-distribution-${DOMIBUS_VERSION}-sample-configuration-and-testing.zip
        ├── domibus-distribution-${DOMIBUS_VERSION}-weblogic-configuration.zip
        ├── domibus-distribution-${DOMIBUS_VERSION}-weblogic-war.zip
        └── wslt-api-1.9.1.zip
```

__wslt-api fix__

The WLST API doesn’t support yet the waitTimeInMillis parameter. We can create a request to the team responsible for
developing it but it will take some time, so I would not rely on this to have it fast.
In the meantime you can modify locally for your specific case the python scripts(in the jar WSLT/lib/wlstscripts.jar
modify the WlsUtilities.py script ) that the WLST uses to import the properties file.

Procedure:
* Extract wslt-api-1.9.1.zip
* Go to /wslt-api-1.9.1/lib/
* Extract wlstscripts.jar
* Open file /eu/cec/digit/wlst/utils/WlsUtilities.py
* Modify line 244 changing "wlst.startEdit()" to "wlst.startEdit(waitTimeInMillis=60000)"
* Repackage wslt-api-1.9.1.zip according to the original

## Build images

Build if the images were not built yet, please build all images:
* oraclexe-domibus
* edelivery-weblogic-cluster
* weblogic-cluster-domibus
* edelivery-httpd

```
cd images
docker-compose -f docker-compose.build.yml build
```

## Run Test Corner2 and Corner3

Initialize the correspondent Docker Compose project:
```
cd compose/test/
docker-compose up -d && docker-compose logs -f
```
