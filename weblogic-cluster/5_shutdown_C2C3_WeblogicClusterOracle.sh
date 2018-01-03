#!/usr/bin/env bash

BASE=$(pwd)

# Run test docker compose project
cd ${BASE}/compose/test/
docker-compose down

# Prune docker system
docker system prune -f
