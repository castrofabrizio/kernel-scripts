#!/bin/bash
# This script helps with the compilation of device tree files

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

echo "Compiling device trees" | print_info
"${PROGRAM_DIRECTORY}"/compile-linux.sh \
	-k \
	-t "${ENVIRONMENT_FILE}" \
	-b "${BUILD_DIRECTORY}" \
	-K "dtbs W=1" | \
	print_no_label
check_exit_value ${PIPESTATUS[0]}

for CURRENT_DEVICE_TREE_BINARY in ${DEVICE_TREE_FILES}; do
	EXTENSION="${CURRENT_DEVICE_TREE_BINARY##*.}"
	FILENAME="${CURRENT_DEVICE_TREE_BINARY%.*}"
	CURRENT_DEVICE_TREE_SOURCE="${FILENAME}.dts"
	if [ "${EXTENSION}" != "dtb" ]; then
		cat<<-EOF | print_warning
		File:
		  "${CURRENT_DEVICE_TREE_BINARY}"
		comes with extension ".${EXTENSION}" but it should be ".dtb". Skipping.
		EOF
		continue
	fi
	if [ ! -f "arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SOURCE}" ]; then
		echo "\"arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SOURCE}\" No such file. Skipping." | print_warning
		continue
	fi
	echo "Reverse engineering ${CURRENT_DEVICE_TREE_BINARY}" | print_info
	"${BUILD_DIRECTORY}/scripts/dtc/dtc" \
		-I dtb \
		-O dts \
		-o "${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SOURCE}" \
		"${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_BINARY}"
	check_exit_value ${PIPESTATUS[0]}
done

${PROGRAM_DIRECTORY}/dt-deploy.sh | print_no_label
check_exit_value ${PIPESTATUS[0]}
