#!/bin/bash
# This script helps with the configuration of the Linux kernel

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

if [ -n "${DEFCONFIG_FILE}" -a -n "${DEFCONFIG}" ]; then
	echo "Please, either unset DEFCONFIG or unset DEFCONFIG_FILE" | print_error
	exit 1
elif [ -n "${DEFCONFIG_FILE}" ]; then
	DEFCONFIG_OPTION="-D ${DEFCONFIG_FILE}"
elif [ -n "${DEFCONFIG}" ]; then
	DEFCONFIG_OPTION="-d ${DEFCONFIG}"
else
	echo "Please, either define DEFCONFIG or define DEFCONFIG_FILE" | print_error
	exit 1
fi

echo "Using \"${DEFCONFIG}\"" | print_info
${PROGRAM_DIRECTORY}/compile-linux.sh \
	-t "${ENVIRONMENT_FILE}" \
	-b "${BUILD_DIRECTORY}" \
	   "${DEFCONFIG_OPTION}" \
	| print_no_label
check_exit_value ${PIPESTATUS[0]}

for CURRENT_FRAGMENT in ${CONFIGURATION_FRAGMENTS}; do
	cat ${CURRENT_FRAGMENT} >> "${BUILD_DIRECTORY}/.config"
	echo "Added \"${CURRENT_FRAGMENT}\" to configuration" | print_info
done
${PROGRAM_DIRECTORY}/oldconfig.sh | print_no_label
check_exit_value ${PIPESTATUS[0]}
