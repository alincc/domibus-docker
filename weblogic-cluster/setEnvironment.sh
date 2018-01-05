#!/usr/bin/env bash

if [ "${DOMIBUS_DOCKER_LOCAL_ENV}" = "true"  ]; then
    echo "Using local environment variables..."

    # Please set the following variables on your environment
    # export DOMIBUS_DOCKER_LOCAL_ENV=true
    #
    # Image External Resources Path, e.g.:
    # export REPO=/datadrive/repo
    #
    # Domibus build branch name, e.g.:
    # export DOMIBUS_BRANCH=development
else
    echo "Using bamboo environment variables..."
    REPO=$bamboo_REPO
    DOMIBUS_BRANCH=$bamboo_DOMIBUS_BRANCH
fi

echo "REPO=${REPO}"
echo "DOMIBUS_BRANCH=${DOMIBUS_BRANCH}"
