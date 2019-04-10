#!/bin/bash
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

for CURRENT_PATCH in ${PATCHES}; do
	cat<<-EOF | print_info

	Applying patch:
	${CURRENT_PATCH}
	EOF
	patch -p1 -d . < ${CURRENT_PATCH}
done
