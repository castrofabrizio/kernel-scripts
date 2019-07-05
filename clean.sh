#!/bin/bash
# This script deletes the build directory

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

echo "Deleting \"${BUILD_DIRECTORY}\"..." | print_info
rm -rf "${BUILD_DIRECTORY}" 2>&1 | print_error
if [ ${PIPESTATUS[0]} -ne 0 ]; then
	echo "Deleting \"${BUILD_DIRECTORY}\"...ERROR" | print_error
	exit 1
fi
echo "Deleting \"${BUILD_DIRECTORY}\"...done" | print_info
