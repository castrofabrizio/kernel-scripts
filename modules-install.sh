#!/bin/bash
# This script installs the modules in the desired directories

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

for CURRENT_DIRECTORY in ${MODULES_INSTALL_DIRECTORIES}; do
	echo "Installing modules within directory \"${CURRENT_DIRECTORY}\"..." | print_info
	sudo tar \
		-xf "${MODULES_TARBALL_DEPLOY_DIRECTORY}/${MODULES_FILENAME}" \
		-C "${CURRENT_DIRECTORY}"
	sudo chmod 755 "${CURRENT_DIRECTORY}"
	echo "done" | print_info
done
