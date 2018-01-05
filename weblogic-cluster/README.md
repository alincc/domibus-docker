# Domibus Weblogic Cluster Test Environment on Docker

## Pre-Requisites 

In order to proceed with the project setup perform the following:

### Prepare host

As the project uses Docker containers and we don't want our user to be a sudoer but want him to be able to issue Docker commands, we'll add him to the docker system group, which grants permissions on docker daemon:
```
usermod -a -G docker domibus
```

### Download image external resources

Download the following external resources into $REPO:
```
   https://github.com/jwilder/dockerize/releases/download/v0.6.0/dockerize-linux-amd64-v0.6.0.tar.gz
   http://download.oracle.com/otn/nt/middleware/12c/wls/1213/fmw_12.1.3.0.0_wls.jar
   http://download.oracle.com/otn/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.tar.gz
   https://ec.europa.eu/cefdigital/artifact/content/repositories/eDelivery/eu/europa/ec/digit/ipcis/wslt-api/1.9.1/wslt-api-1.9.1.zip
```
With the following structure:
```
$REPO
├── dockerize-linux-amd64-v0.6.0.tar.gz
├── fmw_12.1.3.0.0_wls.jar
├── Oracle
│   ├── Java
│   │   ├── jdk-8u144-linux-x64.tar.gz
│   └── wslt-api-1.9.1.zip

```
__wslt-api fix__

The WLST API doesn’t support yet the waitTimeInMillis parameter.

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
