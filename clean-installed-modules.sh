#!/bin/bash

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"

for CURRENT_DIRECTORY in ${MODULES_INSTALL_DIRECTORIES}; do
	rm -rf ${CURRENT_DIRECTORY}/lib/modules/*
done
