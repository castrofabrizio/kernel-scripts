#!/bin/bash
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

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
		echo "\"${CURRENT_DEVICE_TREE_BINARY}\" No such file. Skipping." | print_warning
		continue
	else
		echo "Compiling \"${CURRENT_DEVICE_TREE_BINARY}\"" | print_info
	fi
	${PROGRAM_DIRECTORY}/compile-linux.sh \
		-k \
		-t ${ENVIRONMENT_FILE} \
		-b "${BUILD_DIRECTORY}" \
		-K "${CURRENT_DEVICE_TREE_BINARY} W=1"
done

${PROGRAM_DIRECTORY}/dt-deploy.sh
