#!/usr/bin/env bash

source common.sh
setDomibusVersion

# Run test docker compose project
cd compose/test && docker-compose down
