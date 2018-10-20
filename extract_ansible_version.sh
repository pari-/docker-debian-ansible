#!/usr/bin/env bash

#
# returns Ansible Version found in ${DOCKERFILE}
#

DOCKERFILE="$1"

if [ "${DOCKERFILE}" == "" ]
then
    echo "usage: $0 /path/to/dockerfile"
else
    sed -ne 's/^.*ANSIBLE_VERSION="\([^"]\+\)"$/\1/p' "${DOCKERFILE}"
fi
