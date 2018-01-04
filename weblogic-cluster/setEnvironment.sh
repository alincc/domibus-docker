#!/usr/bin/env bash

if [ "${DOMIBUS_DOCKER_LOCAL_ENV}" = "true"  ]; then
    echo "Using local environment variables..."
    # Image Resources Path
    REPO=~/project/domibus/docker_work/repo
    # Domibus build branch name
    DOMIBUS_BRANCH=development
else
    echo "Using bamboo environment variables..."
    REPO=$bamboo_REPO
    DOMIBUS_BRANCH=$bamboo_DOMIBUS_BRANCH
fi

echo "REPO=${REPO}"
echo "DOMIBUS_BRANCH=${DOMIBUS_BRANCH}"


