#!/usr/bin/env bash

BASE=$(pwd)
RESOURCES_REPO=${BASE}/images

export DOMIBUS_VERSION=4.0-SNAPSHOT
export DOMIBUS_SHORT_VERSION=4.0

# Build all images
cd ${BASE}/images
docker-compose -f docker-compose.build.yml build

# Run test docker compose project
cd ${BASE}/compose/test/
docker-compose up -d && docker-compose logs -f
