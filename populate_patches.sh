#!/bin/bash -e
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
PATCHES=$(ls *.patch | grep -v "^POPULATED")
PATCHES_NO_COVER=$(ls *.patch | grep -v "^POPULATED" | grep -v 0000)
RECIPIENTS_FILE=$1
GENERATE_RECIPIENTS=false

if [ -z "${RECIPIENTS_FILE}" ]; then
	RECIPIENTS_FILE=$(mktemp)
	GENERATE_RECIPIENTS=true
fi

if ${GENERATE_RECIPIENTS}; then
	for CURRENT_PATCH in ${PATCHES}; do
		if [[ ${CURRENT_PATCH} == *0000* ]]; then
			"${PROGRAM_DIRECTORY}"/get_recipients.sh ${PATCHES_NO_COVER} > ${RECIPIENTS_FILE}
		else
			"${PROGRAM_DIRECTORY}"/get_recipients.sh ${CURRENT_PATCH} > ${RECIPIENTS_FILE}
		fi
		"${PROGRAM_DIRECTORY}"/populate_patch_with_recipients.sh \
			-p ${CURRENT_PATCH} \
			-k \
			-r ${RECIPIENTS_FILE} \
			> POPULATED-${CURRENT_PATCH}
	done
	rm -f ${RECIPIENTS_FILE}
else
	for CURRENT_PATCH in ${PATCHES}; do
		"${PROGRAM_DIRECTORY}"/populate_patch_with_recipients.sh \
			-p ${CURRENT_PATCH} \
			-k \
			-r ${RECIPIENTS_FILE} \
			> POPULATED-${CURRENT_PATCH}
	done
fi
