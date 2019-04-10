#!/bin/bash

PROGRAM_DIRECTORY="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${PROGRAM_DIRECTORY}/utils.sh"
export MACHINE=$1

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "Please, source me" | print_error
	exit 1
fi

if ! ${PROGRAM_DIRECTORY}/common.sh; then
	unset MACHINE
	return 1
fi
PS1="\u@${MACHINE} "
echo "Machine \"${MACHINE}\" configured" | print_info
