#!/bin/bash
# This script helps with the deployment of the device tree blobs and sources

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

for CURRENT_DEVICE_TREE_BINARY in ${DEVICE_TREE_FILES}; do
	EXTENSION="${CURRENT_DEVICE_TREE_BINARY##*.}"
	FILENAME="${CURRENT_DEVICE_TREE_BINARY%.*}"
	CURRENT_DEVICE_TREE_SOURCE="${FILENAME}.dts"
	if [ "${EXTENSION}" != "dtb" ] || [ ! -f "arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SOURCE}" ]; then
		echo "Skipping ${CURRENT_DEVICE_TREE_SOURCE}" | print_warning
		continue
	fi
	for DTB_DEPLOY_DIRECTORY in ${DTB_DEPLOY_DIRECTORIES}; do
		echo "Deploying ${CURRENT_DEVICE_TREE_BINARY}..." | print_info
		cp \
			--remove-destination \
			"${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_BINARY}" \
			"${DTB_DEPLOY_DIRECTORY}" \
			| print_error
		check_exit_value ${PIPESTATUS[0]}

		echo "Deploying ${CURRENT_DEVICE_TREE_SOURCE}..." | print_info
		cp \
			--remove-destination \
			"${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SOURCE}" \
			"${DTB_DEPLOY_DIRECTORY}" \
			| print_error
		check_exit_value ${PIPESTATUS[0]}
	done
done
echo "All done" | print_info
