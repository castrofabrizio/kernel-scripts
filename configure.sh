#!/bin/bash
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
${PROGRAM_DIRECTORY}/compile-linux.sh -t ${ENVIRONMENT_FILE} -d ${DEFCONFIG} -b "${BUILD_DIRECTORY}"
for CURRENT_FRAGMENT in ${CONFIGURATION_FRAGMENTS}; do
	cat ${CURRENT_FRAGMENT} >> "${BUILD_DIRECTORY}/.config"
done
${PROGRAM_DIRECTORY}/oldconfig.sh
