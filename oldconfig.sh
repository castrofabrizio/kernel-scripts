#!/bin/bash
# This script runs make oldconfig

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

yes '' | \
	${PROGRAM_DIRECTORY}/compile-linux.sh \
		-t ${ENVIRONMENT_FILE} \
		-k -K oldconfig \
		-b "${BUILD_DIRECTORY}" \
	| print_no_label
check_exit_value ${PIPESTATUS[1]}
