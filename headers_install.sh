#!/bin/bash

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

if [ -z "${HEADERS_INSTALL_DIRECTORY}" ]; then
	echo "Please define variable HEADERS_INSTALL_DIRECTORY in your environment"
	exit 1
fi

rm -rf "${HEADERS_INSTALL_DIRECTORY}"
mkdir "${HEADERS_INSTALL_DIRECTORY}"

COMMAND="headers_install INSTALL_HDR_PATH=${HEADERS_INSTALL_DIRECTORY}"

${PROGRAM_DIRECTORY}/compile-linux.sh \
	-k \
	-t ${ENVIRONMENT_FILE} \
	-b "${BUILD_DIRECTORY}" \
	-K "${COMMAND}" \
	-p \
	| print_no_label
check_exit_value ${PIPESTATUS[0]}
