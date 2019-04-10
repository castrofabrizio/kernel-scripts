#!/bin/bash

BUILD_DIRECTORY="build-dt_binding_check"
OUTPUT_OPTION="O=\"${BUILD_DIRECTORY}\""

rm -rf ${BUILD_DIRECTORY}
make ${OUTPUT_OPTION} defconfig
make ${OUTPUT_OPTION} dt_binding_check
