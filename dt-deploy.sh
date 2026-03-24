#!/bin/bash
# This script helps with the deployment of the device tree blobs and sources

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

copy_device_trees
EXTENDED_DEVICE_TREE_LIST="$(get_extended_device_tree_list)"

for CURRENT_DEVICE_TREE_BINARY in ${EXTENDED_DEVICE_TREE_LIST}; do

	if [[ "${CURRENT_DEVICE_TREE_BINARY}" == *:* ]]; then
		CURRENT_DEVICE_TREE_BINARY="$(echo "${CURRENT_DEVICE_TREE_BINARY}" | awk -F":" '{print $2}')"
	fi

	EXTENSION="${CURRENT_DEVICE_TREE_BINARY##*.}"
	FILENAME="${CURRENT_DEVICE_TREE_BINARY%.*}"

	if [ "${EXTENSION}" == "dtb" ]; then
		CURRENT_DEVICE_TREE_SOURCE="${FILENAME}.dts"
	elif [ "${EXTENSION}" == "dtbo" ]; then
		CURRENT_DEVICE_TREE_SOURCE="${FILENAME}.dtso"
	else
		cat<<-EOF | print_warning
		File:
		  "${CURRENT_DEVICE_TREE_BINARY}"
		comes with extension ".${EXTENSION}" but it should be ".dtb" or ".dtbo". Skipping.
		EOF
		continue
	fi

	if [ ! -f "${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SOURCE}" ]; then
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
