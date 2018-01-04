#!/usr/bin/env bash

if [ "${DOMIBUS_DOCKER_SET_ENV}" = "true"  ]; then
    echo "Setting Environment..."
    # Image Resources Path
    REPO=~/project/domibus/docker_work/repo
    # Domibus build branch name
    DOMIBUS_BRANCH=development
else
    echo "Using external environment"
fi

echo "REPO=${REPO}"
echo "DOMIBUS_BRANCH=${DOMIBUS_BRANCH}"


