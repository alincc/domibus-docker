#!/usr/bin/env bash
#
# Shutdown and remove docker compose containers for C2 and C3.
#

source common.sh
setDomibusVersion

# Run test docker compose project
cd compose/test && docker-compose down
