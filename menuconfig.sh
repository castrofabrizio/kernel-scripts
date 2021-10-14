#!/bin/bash
# This script helps with the configuration of the kernel

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

${PROGRAM_DIRECTORY}/compile-linux.sh \
	-t ${MENUCONFIG_ENVIRONMENT_FILE} \
	-M \
	-b "${BUILD_DIRECTORY}"
