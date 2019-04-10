#!/bin/bash -e
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

# Deploy kernel image
rm -f \
	${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE}.gz \
	"${KERNEL_DEPLOY_DIRECTORY}/${KERNEL_IMAGE}.gz" \
	"${KERNEL_DEPLOY_DIRECTORY}/${KERNEL_IMAGE}"
echo "Compressing ${KERNEL_IMAGE}..." | print_info
gzip -9 -c ${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE} > ${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE}.gz
echo "Deploying ${KERNEL_IMAGE}..." | print_info
cp ${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE}    "${KERNEL_DEPLOY_DIRECTORY}"
echo "Deploying ${KERNEL_IMAGE}.gz..." | print_info
cp ${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE}.gz "${KERNEL_DEPLOY_DIRECTORY}"
