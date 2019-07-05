#!/bin/bash
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
(
	echo stdout >/dev/stdout
	echo stderr >/dev/stderr
	echo stdout >/dev/stdout
	echo stdout >/dev/stdout
	echo stderr >/dev/stderr
) 2> >(print_error) > >(print_info)
