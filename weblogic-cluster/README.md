# Domibus Weblogic Cluster Test Environment on Docker

## Overview

This project allows the build of the required docker images in order to launch and execute the existing Domibus integration tests. The project structure contains the following folders:
* __images__: contains the resources to build the required docker images
* __compose__: contains the test environment configuration

Several scripts are available in order to sequentially build and run the integration tests as described in the following chapters.

## Pre-Requisites 

In order to proceed with the project setup perform the following:

### Check docker configuration

Please check that docker and docker compose tools are available on the host machine:
```
docker --version
```
Check at least: "Docker version 17.12.0-ce, build c97c6d6"
```
docker-compose --version
```
Check at least: "docker-compose version 1.16.1, build 6d1ac21"

As the project uses Docker containers and we don't want our user to be a sudoer but want him to be able to issue Docker commands, we'll add him to the docker system group, which grants permissions on docker daemon:
```
usermod -a -G docker domibus
```

### Download external image resources

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

## Usage

In order to startup Domibus Weblogic Cluster corner 2 and corner 3 and execute the integration tests please execute the following steps. After test execution please shutdown and cleanup the environment.

### Build Domibus

Build Domibus artifacts. 

```
./1_build_Domibus.sh
```

### Build Docker Images

Build docker images containing Domibus distribution.
* oraclexe-domibus
* edelivery-weblogic-cluster
* weblogic-cluster-domibus
* edelivery-httpd

```
./2_buildImages_WeblogicClusterOracle.sh
```

### Startup containers

Startup docker compose containers for C2 and C3 running Weblogic Cluster with Oracle Database.

```
./3_startup_C2C3_WeblogicClusterOracle.sh
```

### Run Integration Tests

Run Soap UI integration tests for C2 and C3.

```
./4_test_C2C3_WeblogicClusterOracle.sh
```

### Shutdown

Shutdown and remove docker compose containers for C2 and C3.

```
./5_shutdown_C2C3_WeblogicClusterOracle.sh
```

### Cleanup

Prune docker system.

```
./6_cleanup_C2C3_WeblogicClusterOracle.sh
```

## Configuration Extension

The default configuration can be changed or extended in the following hooks.

__setEnvironment.sh__

```
# Please set the following variables on your environment
# export DOMIBUS_DOCKER_LOCAL_ENV=true
#
# Image external resources path, e.g.:
# export REPO=/datadrive/repo
```
    
__1_build_Domibus.sh__

```
# Select the Domibus repository branch to build
# e.g.: DOMIBUS_BRANCH=development
DOMIBUS_BRANCH=development
```

__images/docker-compose.build.yml__

This is the compose file used to build the test environment docker images.

```
# Configuration:
#
#   oraclexe-domibus:
#   ORACLE_SYS_PASSWORD   - Oracle password for SYS and SYSTEM users
#   DOMIBUS_PASSWORD      - Oracle password for domibus user
#   DOMIBUS_VERSION       - Domibus project version. (Define this value as an environment variable, e.g.: 4.0-SNAPSHOT)
#   DOMIBUS_SHORT_VERSION - Domibus project short version
#                           (Removing -SNAPSHOT suffix. Define this value as an environment variable, e.g.: 4.0)
#
#   edelivery-weblogic-cluster
#   USER_ID               - The host user id
#                           (Define this value as an environment variable, e.g.: export USER_ID=$(id -u $USER))
#   ADMIN_PASSWORD        - Weblogic admin console password
```

__compose/test/docker-compose.yml__

This is the compose file used to startup the test environment.

```
# Configuration:
#   This file represents the architecture of the Domibus Weblogic Cluster test environment containing both C2 and C3
#   weblogic cluster instances:
#
#   Corner 2 (C2)
#     - oraclexec2: Oracle XE Database with Domibus schema
#     - wlsadminc2: Weblogic Admin Server
#     - serverc2i1: Weblogic Managed Server (with domibus.war deployed)
#     - serverc2i2: Weblogic Managed Server (with domibus.war deployed)
#     - httpdc2:    Apache HTTPD Load Balancer
#
#   Corner 2 (C3)
#     - oraclexec3: Oracle XE Database with Domibus schema
#     - wlsadminc3: Weblogic Admin Server
#     - serverc3i1: Weblogic Managed Server (with domibus.war deployed)
#     - serverc3i2: Weblogic Managed Server (with domibus.war deployed)
#     - httpdc3:    Apache HTTPD Load Balancer
#
#   Corner configuration variables:
#     oraclexecX:
#     ORACLE_ALLOW_REMOTE - Allow the database to be connected remotely
#
#     wlsadmincX:
#     DB_HOST           - Database host name
#     ADMIN_HOST        - Admin server host name
#     ADMIN_PASSWORD    - Admin server password
#     DOMIBUS_PASSWORD  - Oracle password for domibus user
#     DOMIBUS_VERSION   - Domibus project version. (Define this value as an environment variable, e.g.: 4.0-SNAPSHOT)
#
#     servercXiN:
#     INSTANCE_NAME   - Server instance name, e.g.: c2i1
#     DB_HOST         - Database host name
#     ADMIN_HOST      - Admin server host name
#     PARTY_NAME      - Party name to be used used in domibus configuration, e.g.: blue_gw
#
#     httpdcX:
#     VHOST_CORNER_HOSTNAME     - domibus corner host name
#     CORNER_WL_NODE1_HOSTNAME  - managed server instance 1 host name, e.g.: ${COMPOSE_PROJECT_NAME}_serverc2i1_1
#     CORNER_WL_NODE1_PORT      - managed server instance 1 port
#     CORNER_WL_NODE2_HOSTNAME  - managed server instance 2 host name, e.g.: ${COMPOSE_PROJECT_NAME}_serverc2i1_1
#     CORNER_WL_NODE2_PORT      - managed server instance 2 port
```