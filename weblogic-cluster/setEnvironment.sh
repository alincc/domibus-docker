#!/usr/bin/env bash

if [ "${DOMIBUS_DOCKER_LOCAL_ENV}" = "true"  ]; then
    echo "Using local environment variables..."

    # Please set the following variables on your environment
    # export DOMIBUS_DOCKER_LOCAL_ENV=true
    #
    # Image external resources path, e.g.:
    # export REPO=/datadrive/repo
else
    echo "Using bamboo environment variables..."
    REPO=$bamboo_REPO
fi

echo "REPO=${REPO}"
