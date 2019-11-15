#!/bin/bash
# This script helps with the checking of the dtbs files against the dt-bindings

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

COMMAND="dtbs_check"
if [ $# -ne 0 ]; then
	COMMAND="${COMMAND} DT_SCHEMA_FILES=${1}"
fi

${PROGRAM_DIRECTORY}/compile-linux.sh \
	-k \
	-t ${ENVIRONMENT_FILE} \
	-b "${BUILD_DIRECTORY}" \
	-K "${COMMAND}" \
	-p \
	| print_no_label
check_exit_value ${PIPESTATUS[0]}
