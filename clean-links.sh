#!/bin/bash

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
if [ -z "${UTILS_LOADED+x}" ]; then
	source "${PROGRAM_DIRECTORY}/utils.sh"
fi

echo "Deleting old symbolic links from the current directory" | print_info
find . -maxdepth 1 -type l -delete
echo "Done" | print_info
