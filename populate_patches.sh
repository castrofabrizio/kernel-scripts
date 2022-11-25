#!/bin/bash -e
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
PATCHES=$(ls *.patch | grep -v "^POPULATED")
RECIPIENTS_FILE=$1

for CURRENT_PATCH in ${PATCHES}; do
	"${PROGRAM_DIRECTORY}"/populate_patch_with_recipients.sh \
		-p ${CURRENT_PATCH} \
		-k \
		-r ${RECIPIENTS_FILE} \
		> POPULATED-${CURRENT_PATCH}
done
