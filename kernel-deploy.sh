#!/bin/bash
# This script helps with the deployment of the kernel image file

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

rm -f ${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE}.gz

echo "Compressing ${KERNEL_IMAGE}..." | print_info
gzip \
	-9 \
	-c ${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE} \
	> ${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE}.gz

for KERNEL_DEPLOY_DIRECTORY in ${KERNEL_DEPLOY_DIRECTORIES}; do
	echo "Deploying ${KERNEL_IMAGE} to \"${KERNEL_DEPLOY_DIRECTORY}\"..." | print_info
	cp \
		--remove-destination \
		${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE} \
		"${KERNEL_DEPLOY_DIRECTORY}"
	echo "Deploying ${KERNEL_IMAGE}.gz to \"${KERNEL_DEPLOY_DIRECTORY}\"..." | print_info
	cp \
		--remove-destination \
		${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE}.gz \
		"${KERNEL_DEPLOY_DIRECTORY}"
done
echo "All done" | print_info
