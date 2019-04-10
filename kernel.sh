#!/bin/bash -e
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

# Compile the kernel
${PROGRAM_DIRECTORY}/compile-linux.sh -t ${ENVIRONMENT_FILE} -k -K ${KERNEL_IMAGE} -b "${BUILD_DIRECTORY}"

# Deploy kernel image
${PROGRAM_DIRECTORY}/kernel-deploy.sh
