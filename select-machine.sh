#!/bin/bash
# This is to select a machine to work with

PROGRAM_DIRECTORY="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
if [ -z "${UTILS_LOADED}" ]; then
	source "${PROGRAM_DIRECTORY}/utils.sh"
fi
export MACHINE=$1

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "Please, source me" | print_error
	exit 1
fi

set +e
if ! ${PROGRAM_DIRECTORY}/common.sh; then
	unset MACHINE
	return 1
fi
set -e

BUILD_DIRECTORY="${BUILD_DIRECTORY:-${PWD}/build-${MACHINE}}"
export CSCOPE_DB="${CSCOPE_DB:-${BUILD_DIRECTORY}/cscope.out ${BUILD_DIRECTORY}}"

. "${PROGRAM_DIRECTORY}/select-prompt.sh"
echo "Machine \"${MACHINE}\" configured" | print_info
