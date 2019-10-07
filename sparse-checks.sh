#!/bin/bash

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

find "${BUILD_DIRECTORY}" -iname "*.dt[bs]" -delete
${PROGRAM_DIRECTORY}/compile-linux.sh \
	-k \
	-t ${ENVIRONMENT_FILE} \
	-b "${BUILD_DIRECTORY}" \
	-K "C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'" \
	-p \
	| print_no_label
check_exit_value ${PIPESTATUS[0]}
