#!/bin/bash
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

${PROGRAM_DIRECTORY}/compile-linux.sh -t ${ENVIRONMENT_FILE} -k -m "${MODULES_TARBALL_DEPLOY_DIRECTORY}/${MODULES_FILENAME}" -b "${BUILD_DIRECTORY}"

${PROGRAM_DIRECTORY}/modules-install.sh
