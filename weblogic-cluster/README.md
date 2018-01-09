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
├── jdbcdrivers
│   └── ojdbc7.jar
├── Oracle
│   ├── Java
│   │   └── jdk-8u144-linux-x64.tar.gz
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

## Build Domibus

Build Domibus artifacts. 

```
1_build_Domibus.sh
```

## Build Docker Images

Build docker images containing Domibus distribution.
* oraclexe-domibus
* edelivery-weblogic-cluster
* weblogic-cluster-domibus
* edelivery-httpd

```
2_buildImages_WeblogicClusterOracle.sh
```

## Startup containers

Startup docker compose containers for C2 and C3 running Weblogic Cluster with Oracle Database.

```
3_startup_C2C3_WeblogicClusterOracle.sh
```

## Run Integration Tests

Run Soap UI integration tests for C2 and C3.

```
4_test_C2C3_WeblogicClusterOracle.sh
```

## Shutdown

Shutdown and remove docker compose containers for C2 and C3.

```
4_test_C2C3_WeblogicClusterOracle.sh
```

## Cleanup

Prune docker system.

```
6_cleanup_C2C3_WeblogicClusterOracle.sh
```