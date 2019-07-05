#!/bin/bash
# This script prints the kernel version

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

${PROGRAM_DIRECTORY}/compile-linux.sh \
	-t ${ENVIRONMENT_FILE} \
	-b "${BUILD_DIRECTORY}" \
	-v \
	| print_no_label
check_exit_value ${PIPESTATUS[0]}
