#!/bin/bash
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

for CURRENT_DEVICE_TREE_BINARY in ${DEVICE_TREE_FILES}; do
	EXTENSION="${CURRENT_DEVICE_TREE_BINARY##*.}"
	FILENAME="${CURRENT_DEVICE_TREE_BINARY%.*}"
	CURRENT_DEVICE_TREE_SOURCE="${FILENAME}.dts"
	if [ "${EXTENSION}" != "dtb" ] || [ ! -f "arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SOURCE}" ]; then
		continue
	fi
	echo "Deploying ${CURRENT_DEVICE_TREE_BINARY}..." | print_info
	rm -f "${DTB_DEPLOY_DIRECTORY}/$(basename ${CURRENT_DEVICE_TREE_BINARY})"
	cp "${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_BINARY}" "${DTB_DEPLOY_DIRECTORY}"
done
