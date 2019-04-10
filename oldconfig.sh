#!/bin/bash

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
yes '' | ${PROGRAM_DIRECTORY}/compile-linux.sh -t ${ENVIRONMENT_FILE} -k -K oldconfig -b "${BUILD_DIRECTORY}"
