#!/usr/bin/env bash

if [[ -v "${bamboo_buildNumber}" ]]; then
    # When ${bamboo_buildNumber} is set on the environment
    echo "Using bamboo environment variables..."
    REPO=$bamboo_REPO
    DOMIBUS_BRANCH=$bamboo_DOMIBUS_BRANCH
else
    echo "Using local environment variables..."

    # Please set the following variables on your environment
    # Image External Resources Path, e.g.:
    # export REPO=/datadrive/repo
    #
    # Domibus build branch name, e.g.:
    # export DOMIBUS_BRANCH=development
fi

echo "REPO=${REPO}"
echo "DOMIBUS_BRANCH=${DOMIBUS_BRANCH}"
