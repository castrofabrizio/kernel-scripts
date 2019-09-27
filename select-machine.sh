#!/bin/bash
# This script is to select a machine to work with, and has to be sourced.
# It requires a parameter: the machine name. If run without parameters, it'll
# print the available machines

PROGRAM_DIRECTORY="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
if [ -z "${UTILS_LOADED}" ]; then
	source "${PROGRAM_DIRECTORY}/utils.sh"
fi
export MACHINE="$1"

# Let's take care of the build directory
DEFAULT_BUILD_DIRECTORY="${PWD}/build-${MACHINE}"
if [ -z "${BUILD_DIRECTORY+x}" ]; then
	BUILD_DIRECTORY="${DEFAULT_BUILD_DIRECTORY}"
fi
export BUILD_DIRECTORY

# Have we been sourced?
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "Please, source me" | print_error
	exit 1
fi

set +e
# Is the configuration correct?
if ! ${PROGRAM_DIRECTORY}/common.sh; then
	unset MACHINE
	return 1
fi
set -e

# Time to change the shell prompt
. "${PROGRAM_DIRECTORY}/select-prompt.sh"

# Confirm the parameters with the user
cat<<EOF | print_info

#################
# Configuration #
#################

Machine: "${MACHINE}"
Selected build directory: "${BUILD_DIRECTORY}"

EOF

if [ "${BUILD_DIRECTORY}" != "${DEFAULT_BUILD_DIRECTORY}" ]; then
	cat<<-EOF | print_info
	(the default build directory is: "${DEFAULT_BUILD_DIRECTORY}", if you rather
	use the default build directory unset BUILD_DIRECTORY and then select the
	machine again)

	EOF
fi
