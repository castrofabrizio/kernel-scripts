#!/bin/bash
# This script purges all the symbolic links from the current directory, and
# creates new symbolic links in the current working directory for files found
# in the directory specified through the command line

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
PROGRAM_BASENAME="$(basename "$0")"
if [ -z "${UTILS_LOADED+x}" ]; then
	source "${PROGRAM_DIRECTORY}/utils.sh"
fi

if [ "$#" -ne 1 ]; then
	echo "Please give me the name of the directory from which we should take the files from" | print_error
	exit 1
fi
if [ ! -d "$1" ]; then
	echo "\"${1}\" No such directory" | print_error
	exit 1
fi
DIRECTORY="$1"

echo "Deleting old symbolic links from the current directory" | print_info
find . -maxdepth 1 -type l -delete
echo "Done" | print_info

while read CURRENT_FILE; do
	echo "Creating symbolic link for file ${CURRENT_FILE}" | print_info
	ln -sf "${CURRENT_FILE}" "$(basename "${CURRENT_FILE}")"
done < <(find "${DIRECTORY}" -maxdepth 1 -type f)
echo "Done" | print_info
