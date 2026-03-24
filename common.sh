#!/bin/bash
# This file contains everything that's common between scripts, with the
# exception of compile-linux.sh.
# File utils.sh includes code shared by _every_ other script, including
# compile-linux.sh and common.sh.

PROGRAM_DIRECTORY="${PROGRAM_DIRECTORY:-$(dirname "$(realpath "${BASH_SOURCE[0]}")")}"
PROGRAM_BASENAME="$(basename "$0")"
if [ -z "${UTILS_LOADED}" ]; then
	source "${PROGRAM_DIRECTORY}/utils.sh"
fi
if [ -n "${COMMON_LOADED}" ]; then
	echo "common.sh already loaded" | print_debug
	return
fi
echo "Loading common.sh" | print_debug

################################################################################
# Global variables
ENVIRONMENTS_DIRECTORY="${ENVIRONMENTS_DIRECTORY:-${HOME}/environments}"
# BUILD_DIRECTORY="${BUILD_DIRECTORY:-${PWD}/build-${MACHINE}}"
MODULES_FILENAME="modules.tar.gz"
REQUIRED_VARIABLES=" \
	MODULES_TARBALL_DEPLOY_DIRECTORY \
	MODULES_INSTALL_DIRECTORIES \
	KERNEL_DEPLOY_DIRECTORIES \
	ENVIRONMENT_FILE \
	BUILD_DIRECTORY \
	KERNEL_IMAGE \
"
# We actually don't do anuthing with this, yet, it's just for reference
OPTIONAL_VARIABLES=" \
	PATCHES \
	DEFCONFIG \
	DEFCONFIG_FILE \
	DTB_DEPLOY_DIRECTORIES \
	DEVICE_TREE_FILES \
	CONFIGURATION_FRAGMENTS \
	MENUCONFIG_ENVIRONMENT_FILE \
"

################################################################################
# Helpers

print_available_machines () {
	local CURRENT_ENVIRONMENT=""
	echo "Available options are:"
	for CURRENT_ENVIRONMENT in $(ls "${ENVIRONMENTS_DIRECTORY}/"*-environment); do
		echo "* $(basename "${CURRENT_ENVIRONMENT}" | awk -F"-environment" '{print $1}')"
	done
}

get_extended_device_tree_list () {
	local CURRENT_DEVICE_TREE=""
	local CURRENT_DEVICE_TREE_DST=""

	local EXTENDED_DEVICE_TREE_LIST="${DEVICE_TREE_FILES}"

	for CURRENT_DEVICE_TREE in ${COPY_DEVICE_TREE_FILES}; do
		CURRENT_DEVICE_TREE_DST="$(echo "${CURRENT_DEVICE_TREE}" | awk -F"=" '{print $1}')"
		EXTENDED_DEVICE_TREE_LIST="${EXTENDED_DEVICE_TREE_LIST} ${CURRENT_DEVICE_TREE_DST}"
	done

	echo "${EXTENDED_DEVICE_TREE_LIST}"
}

copy_device_trees () {
	local CURRENT_DEVICE_TREE=""

	local CURRENT_DEVICE_TREE_SRC=""
	local CURRENT_DEVICE_TREE_SRC_DTS=""
	local CURRENT_DEVICE_TREE_SRC_FILENAME=""

	local CURRENT_DEVICE_TREE_DST=""
	local CURRENT_DEVICE_TREE_DST_DTS=""
	local CURRENT_DEVICE_TREE_DST_FILENAME=""

	for CURRENT_DEVICE_TREE in ${COPY_DEVICE_TREE_FILES}; do
		CURRENT_DEVICE_TREE_DST="$(echo "${CURRENT_DEVICE_TREE}" | awk -F"=" '{print $1}')"
		CURRENT_DEVICE_TREE_SRC="$(echo "${CURRENT_DEVICE_TREE}" | awk -F"=" '{print $2}')"

		if [ -f "${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SRC}" ]; then
			echo "Copying ${CURRENT_DEVICE_TREE_SRC} to ${CURRENT_DEVICE_TREE_DST}"
			cp \
				"${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SRC}" \
				"${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_DST}"
		else
			echo "File ${CURRENT_DEVICE_TREE_SRC} not found!" | print_warning
			continue
		fi


		CURRENT_DEVICE_TREE_SRC_FILENAME="${CURRENT_DEVICE_TREE_SRC%.*}"
		CURRENT_DEVICE_TREE_SRC_DTS="${CURRENT_DEVICE_TREE_SRC_FILENAME}.dts"
		CURRENT_DEVICE_TREE_DST_FILENAME="${CURRENT_DEVICE_TREE_DST%.*}"
		CURRENT_DEVICE_TREE_DST_DTS="${CURRENT_DEVICE_TREE_DST_FILENAME}.dts"

		if [ -f "${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SRC_DTS}" ]; then
			echo "Copying ${CURRENT_DEVICE_TREE_SRC_DTS} to ${CURRENT_DEVICE_TREE_DST_DTS}"
			cp \
				"${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_SRC_DTS}" \
				"${BUILD_DIRECTORY}/arch/${ARCH}/boot/dts/${CURRENT_DEVICE_TREE_DST_DTS}"
		else
			echo "File ${CURRENT_DEVICE_TREE_SRC_DTS} not found!" | print_warning
		fi
	done
}

################################################################################
# Main

if [ -z "${MACHINE}" ]; then
	(
		echo "Please define variable MACHINE"
		echo
		print_available_machines
	) | print_error
	exit 1
fi

if [ ! -f "${ENVIRONMENTS_DIRECTORY}/${MACHINE}-environment" ]; then
	(
		echo "\"${MACHINE}\" No such machine"
		echo
		print_available_machines
	) | print_error
	exit 1
fi

source "${ENVIRONMENTS_DIRECTORY}/${MACHINE}-environment"

for CURRENT_VARIABLE in ${REQUIRED_VARIABLES}; do
	if [ -z "${!CURRENT_VARIABLE}" ]; then
		echo "Please, define variable ${CURRENT_VARIABLE}" | print_error
		exit 1
	fi
done

for CURRENT_VARIABLE in ${REQUIRED_VARIABLES}; do
	if [[ "${CURRENT_VARIABLE}" =~ .*DIRECTORY.* ]]; then
		if [ ! -d "${!CURRENT_VARIABLE}" ]; then
			echo "Creating directory \"${!CURRENT_VARIABLE}\"" | print_info
			mkdir -p ${!CURRENT_VARIABLE}
		fi
	elif [[ "${CURRENT_VARIABLE}" =~ .*DIRECTORIES.* ]]; then
		for CURRENT_DIRECTORY in ${!CURRENT_VARIABLE}; do
			if [ ! -d "${CURRENT_DIRECTORY}" ]; then
				echo "Creating directory \"${CURRENT_DIRECTORY}\"" | print_info
				mkdir -p ${CURRENT_DIRECTORY}
			fi
		done
	fi
done

if [ -z "${MENUCONFIG_ENVIRONMENT_FILE}" ]; then
	MENUCONFIG_ENVIRONMENT_FILE="${ENVIRONMENT_FILE}"
fi

COMMON_LOADED="yes"
