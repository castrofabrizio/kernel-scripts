#!/bin/bash
# This script is to select a machine to work with, and has to be sourced.
# It requires a parameter: the machine name. If run without parameters, it'll
# print the available machines

PROGRAM_DIRECTORY="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${PROGRAM_DIRECTORY}/helpers.sh"
MACHINE="$1"
DEFAULT_BUILD_DIRECTORY="${PWD}/build-${MACHINE}"

get_build_directory () {
	local TO_RETURN=""
	if [ -z "${BUILD_DIRECTORY+x}" ]; then
		TO_RETURN="${DEFAULT_BUILD_DIRECTORY}"
	else
		TO_RETURN="${BUILD_DIRECTORY}"
	fi
	echo "${TO_RETURN}"
}

# Have we been sourced?
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "Please, source me" | print_error
	exit 1
fi

(
	export BUILD_DIRECTORY=$(get_build_directory)
	export MACHINE
	# Is the configuration correct?
	if ! ${PROGRAM_DIRECTORY}/common.sh; then
		exit 1
	fi
)
if [ $? -ne 0 ]; then
	unset MACHINE
	return 1
fi

export BUILD_DIRECTORY=$(get_build_directory)
export MACHINE

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
