#!/usr/bin/env bash

#
# returns the ${N}'s (top-down) Ansible Version found in ${DOCKERFILE}
#

DOCKERFILE="$1"
N="$2"

if [ "${DOCKERFILE}" == "" ] || [ "${N}" == "" ]
then
    echo "usage: $0 /path/to/dockerfile <N>"
else
    grep "RUN virtualenv" "${DOCKERFILE}" | head -n "${N}" | tail -n1 | sed -n -e 's/^RUN virtualenv ansible-\(.*\)$/\1/p'
fi
