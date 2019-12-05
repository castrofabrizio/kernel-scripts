#!/bin/bash
# This script helps with the deployment of the kernel image file

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
source "${PROGRAM_DIRECTORY}/common.sh"
source "${ENVIRONMENT_FILE}"

case ${KERNEL_IMAGE} in
	*Image)
		IMAGE_FILEPATH="${BUILD_DIRECTORY}/arch/${ARCH}/boot/${KERNEL_IMAGE}"
		;;
	*)
		IMAGE_FILEPATH="${BUILD_DIRECTORY}/${KERNEL_IMAGE}"
		;;
esac

rm -f "${IMAGE_FILEPATH}.gz"

echo "Compressing ${KERNEL_IMAGE}..." | print_info
gzip -9 -c ${IMAGE_FILEPATH} > ${IMAGE_FILEPATH}.gz

for KERNEL_DEPLOY_DIRECTORY in ${KERNEL_DEPLOY_DIRECTORIES}; do
	echo "Deploying ${KERNEL_IMAGE} to \"${KERNEL_DEPLOY_DIRECTORY}\"..." | print_info
	cp --remove-destination ${IMAGE_FILEPATH} "${KERNEL_DEPLOY_DIRECTORY}"
	echo "Deploying ${KERNEL_IMAGE}.gz to \"${KERNEL_DEPLOY_DIRECTORY}\"..." | print_info
	cp --remove-destination ${IMAGE_FILEPATH}.gz "${KERNEL_DEPLOY_DIRECTORY}"
done
echo "All done" | print_info
