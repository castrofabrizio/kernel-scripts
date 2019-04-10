#!/bin/bash
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

${PROGRAM_DIRECTORY}/compile-linux.sh -t ${ENVIRONMENT_FILE} -M -b "${BUILD_DIRECTORY}"
