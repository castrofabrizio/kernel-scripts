#!/bin/bash -e
# This script helps with compilation and installation of the kernel modules.
#
# With no parameters it creates a tarball with the modules first, and then it
# installs the modules within the desired directories.
#
# When specified, the parameters list the single kernel modules to (re)-compile,
# after that it installs the modules within the desired directories, without
# creating the tarball.

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

if [ $# -gt 0 ]; then
	MODULES_OPTION=""
	for CURRENT_PARAMETER in "$@"; do
		if [ -d "${BUILD_DIRECTORY}" ]; then
			pushd "${BUILD_DIRECTORY}"
			for CURRENT_FILE in $(find "${CURRENT_PARAMETER}" -iname "*.ko"); do
				MODULES_OPTION="${MODULES_OPTION} -B ${CURRENT_FILE}"
			done
			popd
		else
			MODULES_OPTION="${MODULES_OPTION} -B ${CURRENT_PARAMETER}"
		fi
	done
	${PROGRAM_DIRECTORY}/compile-linux.sh \
		-t ${ENVIRONMENT_FILE} \
		-b "${BUILD_DIRECTORY}" \
		${MODULES_OPTION} \
		| print_no_label
	check_exit_value ${PIPESTATUS[0]}

	for CURRENT_INSTALL_DIRECTORY in ${MODULES_INSTALL_DIRECTORIES}; do
		rm -rf ${CURRENT_INSTALL_DIRECTORY}/$(${PROGRAM_DIRECTORY}/kernelrelease.sh)
		${PROGRAM_DIRECTORY}/compile-linux.sh \
			-t ${ENVIRONMENT_FILE} \
			-b "${BUILD_DIRECTORY}" \
			-i ${CURRENT_INSTALL_DIRECTORY} \
			| print_no_label
		check_exit_value ${PIPESTATUS[0]}
	done
else
	${PROGRAM_DIRECTORY}/compile-linux.sh \
		-t ${ENVIRONMENT_FILE} \
		-m "${MODULES_TARBALL_DEPLOY_DIRECTORY}/${MODULES_FILENAME}" \
		-b "${BUILD_DIRECTORY}" \
		| print_no_label
	check_exit_value ${PIPESTATUS[0]}

	${PROGRAM_DIRECTORY}/modules-install.sh \
		| print_no_label
	check_exit_value ${PIPESTATUS[0]}
fi
