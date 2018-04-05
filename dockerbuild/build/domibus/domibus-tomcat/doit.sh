#!/bin/bash

#cd docker/dockerbuild/build/domibus/domibus-tomcat
export DOMIBUS_VERSION=4.0-SNAPSHOT
DOMIBUS_DISTRIBUTION=/c/Work/Devel/Java/Project/Source/domibus/Domibus-MSH-distribution/target
./dockerBuild.sh ${DOMIBUS_DISTRIBUTION}