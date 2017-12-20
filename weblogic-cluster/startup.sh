#!/usr/bin/env bash

BASE=$(pwd)

export DOMIBUS_VERSION=4.0-SNAPSHOT
export DOMIBUS_SHORT_VERSION=4.0

# Build all images and run test docker compose project
cd ${BASE}/images && docker-compose -f docker-compose.build.yml build && \
cd ${BASE}/compose/test/ && docker-compose up -d && docker-compose logs -f
