#!/bin/bash

cd docker/dockerbuild/build/domibus/domibus-mysql
export DOMIBUS_VERSION=4.0-SNAPSHOT
DOMIBUS_DISTRIBUTION=/c/Work/Devel/Java/Project/Source/domibus/Domibus-MSH-distribution/target
./go.sh ${DOMIBUS_DISTRIBUTION}