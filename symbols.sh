#!/bin/bash
# This is to create the database with the symbols

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

${PROGRAM_DIRECTORY}/compile-linux.sh \
	-t ${ENVIRONMENT_FILE} \
	-s \
	-b "${BUILD_DIRECTORY}" \
	| print_no_label
check_exit_value ${PIPESTATUS[0]}
