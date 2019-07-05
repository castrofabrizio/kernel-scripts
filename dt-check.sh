#!/bin/bash
# This script helps with the checking of the dtbs files against the dt-bindings

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

${PROGRAM_DIRECTORY}/compile-linux.sh \
	-k \
	-t ${ENVIRONMENT_FILE} \
	-b "${BUILD_DIRECTORY}" \
	-p \
	-K "dtbs_check" \
	| print_no_label
