#!/bin/bash
# This script helps with the compilation of specific device tree files

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

for CURRENT_DEVICE_TREE_BINARY in ${DEVICE_TREE_FILES}; do

	if [[ "${CURRENT_DEVICE_TREE_BINARY}" == *:* ]]; then
		CURRENT_DEVICE_TREE_BINARY="$(echo "${CURRENT_DEVICE_TREE_BINARY}" | awk -F":" '{print $2}')"
	fi

	EXTENSION="${CURRENT_DEVICE_TREE_BINARY##*.}"

	if [ "${EXTENSION}" == "dtbo" ]; then
		echo "Overlays found. Building device trees with symbols." | print_info
		export DTC_FLAGS="-@"
		break
	fi
done

for CURRENT_DEVICE_TREE_BINARY in ${DEVICE_TREE_FILES}; do
	CURRENT_OUT_OF_TREE_SOURCE=""

	if [[ "${CURRENT_DEVICE_TREE_BINARY}" == *:* ]]; then
		CURRENT_OUT_OF_TREE_SOURCE="$(echo "${CURRENT_DEVICE_TREE_BINARY}" | awk -F":" '{print $1}')"
		CURRENT_DEVICE_TREE_BINARY="$(echo "${CURRENT_DEVICE_TREE_BINARY}" | awk -F":" '{print $2}')"
	fi

	EXTENSION="${CURRENT_DEVICE_TREE_BINARY##*.}"
	FILENAME="${CURRENT_DEVICE_TREE_BINARY%.*}"

	if [ "${EXTENSION}" == "dtb" ]; then
		CURRENT_DEVICE_TREE_SOURCE="arch/${ARCH}/boot/dts/${FILENAME}.dts"
	elif [ "${EXTENSION}" == "dtbo" ]; then
		CURRENT_DEVICE_TREE_SOURCE="arch/${ARCH}/boot/dts/${FILENAME}.dtso"
	else
		cat<<-EOF | print_warning
		File:
		  "${CURRENT_DEVICE_TREE_BINARY}"
		comes with extension ".${EXTENSION}" but it should be ".dtb" or ".dtbo". Skipping.
		EOF
		continue
	fi

	# Deploy out of tree device trees
	if [ -n "${CURRENT_OUT_OF_TREE_SOURCE}" ]; then
		cp \
			"${CURRENT_OUT_OF_TREE_SOURCE}" \
			"${CURRENT_DEVICE_TREE_SOURCE}"
	fi

	# Check that the source file exists before attempting anything
	if [ ! -f "${CURRENT_DEVICE_TREE_SOURCE}" ]; then
		echo "\"${CURRENT_DEVICE_TREE_SOURCE}\" No such file. Skipping." | print_warning
		continue
	fi

	# Delete debris from previous builds
	rm -f \
		"${BUILD_DIRECTORY}/${CURRENT_DEVICE_TREE_SOURCE}" \
		"${BUILD_DIRECTORY}/${CURRENT_DEVICE_TREE_BINARY}"

	# Now generate the output binary
	echo "Compiling \"${CURRENT_DEVICE_TREE_BINARY}\"" | print_info
	${PROGRAM_DIRECTORY}/compile-linux.sh \
		-k \
		-t ${ENVIRONMENT_FILE} \
		-b "${BUILD_DIRECTORY}" \
		-K "${CURRENT_DEVICE_TREE_BINARY} W=1" | \
		print_no_label
	BUILD_EXIT_VALUE=${PIPESTATUS[0]}

	# If we have transferred the out of tree source to in-tree make sure
	# we get rid of it as soon as possible
	if [ -n "${CURRENT_OUT_OF_TREE_SOURCE}" ]; then
		rm "${CURRENT_DEVICE_TREE_SOURCE}"
	fi

	check_exit_value ${BUILD_EXIT_VALUE}

	echo "Reverse engineering ${CURRENT_DEVICE_TREE_BINARY}" | print_info
	"${BUILD_DIRECTORY}/scripts/dtc/dtc" \
		-I dtb \
		-O dts \
		-o "${BUILD_DIRECTORY}/${CURRENT_DEVICE_TREE_SOURCE}" \
		"${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_BINARY}"
	check_exit_value ${PIPESTATUS[0]}
done

${PROGRAM_DIRECTORY}/dt-deploy.sh | print_no_label
check_exit_value ${PIPESTATUS[0]}
