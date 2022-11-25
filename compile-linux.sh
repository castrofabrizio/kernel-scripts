#!/bin/bash

################################################################################
# Parameters

PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd; )"
PROGRAM_BASENAME="$(basename "$0")"
NUMBER_OF_CORES=$(nproc)
PARALLELISM_FACTOR=$((NUMBER_OF_CORES * 1))
COMMAND_NAME="$0"
BUILD_DIRECTORY=""
UNSET_PYTHON="no"
EXIT_VALUE=0
DEFCONFIG_FILE=""
DEFCONFIG=""

################################################################################
# Helpers

if [ -z "${UTILS_LOADED+x}" ]; then
	source "${PROGRAM_DIRECTORY}/utils.sh"
fi

run_make () {
	cat<<-EOF | print_info

	########################################################################
	# Running:
	# make ${OUTPUT_OPTION} -j ${PARALLELISM_FACTOR} ${@}
	########################################################################
	EOF
	eval make \
		${OUTPUT_OPTION} \
		-j ${PARALLELISM_FACTOR} ${@} \
		2> >(print_error) > >(print_label "MAKE")
}

print_help () {
	cat<<-EOF

	 This script helps with the configuration and compilation of the kernel.

	 USAGE: ${COMMAND_NAME} [-t <file>] [(-d <config>|-D <file>)] \\
	           [-k [-K <opts>]] [-s] [-M] [-m <file>] [-b <dir>] \\
		   [-B <file>] [-v] [-p] [-h]

	 OPTIONS:
	 -h             Print this help and exit
	 -t <file>      Cross-toolchain filepath
	 -D <file>      defconfig file to use
	 -d <config>    defconfig to use
	 -k             Compile the kernel
	 -K <opts>      Use <opts> when compiling the kernel
	 -s             Update cscope and tags
	 -M             Run menuconfig
	 -m <file>      Compile the modules and generate a tarball.
	 -i <dir>       Install modules into the specified directory
	 -b <dir>       Build directory filepath.
	 -B <file>      Build the specified in-tree kernel module. This
	                option can be repeated multiple times
	 -v             Get kernel version
	 -p             Unset python specific environment variables

	EOF
}

################################################################################
# Options parsing

while getopts ":t:d:D:kK:sMm:i:b:B:vph" opt; do
	case $opt in
	t)
		if [ ! -f "${OPTARG}" ]; then
			echo "[-f] \"${OPTARG}\" No such file" | print_error
			exit 1
		fi
		TOOLCHAIN_ENVIRONMENT="${OPTARG}"
		;;
	d)
		DEFCONFIG="${OPTARG}"
		;;
	D)
		if [ ! -f "${OPTARG}" ]; then
			echo "[-D] \"${OPTARG}\" No such file" | print_error
			exit 1
		fi
		DEFCONFIG_FILE="$(realpath "${OPTARG}")"
		;;
	k)
		KERNEL="yes"
		;;
	K)
		export KERNEL_MAKE_OPTIONS="${OPTARG}"
		;;
	s)
		UPDATE_SYMBOLS="yes"
		;;
	M)
		RUN_MENUCONFIG="yes"
		;;
	m)
		MODULES_TARBALL="${OPTARG}"
		;;
	i)
		if [ ! -d "${OPTARG}" ]; then
			echo "[-i] No such directory \"${OPTARG}\"" | print_error
			print_help
			exit 1
		fi
		MODULES_INSTALL_DIRECTORY="$(realpath "${OPTARG}")"
		;;
	b)
		if [ ! -d "${OPTARG}" ]; then
			echo "[-b] No such directory \"${OPTARG}\"" | print_error
			print_help
			exit 1
		fi
		BUILD_DIRECTORY="$(realpath "${OPTARG}")"
		;;
	B)
		MODULES_LIST="${MODULES_LIST} ${OPTARG}"
		;;
	v)
		PRINT_VERSION="yes"
		;;
	p)
		UNSET_PYTHON="yes"
		;;
	h)
		print_help
		exit 1
		;;
	\?)
		echo "Invalid option: -$OPTARG" | print_error
		exit 1
		;;
	:)
		echo "Option -$OPTARG requires an argument." | print_error
		exit 1
		;;
	esac
done

if [ -n "${DEFCONFIG}" -a -n "${DEFCONFIG_FILE}" ]; then
	echo "[-d] and [-D] can't be both used" | print_error
	print_help
	exit 1
fi

################################################################################
# Main

if [ -n "${BUILD_DIRECTORY}" ]; then
	OUTPUT_OPTION="O=\"${BUILD_DIRECTORY}\""
fi

if [ -n "${TOOLCHAIN_ENVIRONMENT}" ]; then
	if [ -z "${ARCH}" ]; then
		source ${TOOLCHAIN_ENVIRONMENT}
	fi
fi

if [ "${UNSET_PYTHON}" == "yes" ]; then
	for CURRENT_VARIABLE in $(printenv | grep -i python | awk -F"=" '{print $1}'); do
		unset ${CURRENT_VARIABLE}
 		echo "Unset \"${CURRENT_VARIABLE}\"" | print_info
	done
fi

if [ -n "${PRINT_VERSION}" ]; then
	make ${OUTPUT_OPTION} kernelrelease 2> /dev/null | grep -v ^make | print_label "MAKE"
	check_exit_value ${PIPESTATUS[0]}
fi

if [ -n "${DEFCONFIG}" ]; then
	echo "Configuring the kernel with \"${DEFCONFIG}\"" | print_info
	run_make ${DEFCONFIG}
fi

if [ -n "${DEFCONFIG_FILE}" ]; then
	echo "Configuring the kernel with file \"${DEFCONFIG_FILE}\"" | print_info
	if [ -n "${BUILD_DIRECTORY}" ]; then
		mkdir -p "${BUILD_DIRECTORY}"
		cp "${DEFCONFIG_FILE}" "${BUILD_DIRECTORY}/.config"
	fi
fi

if [ -n "${DEFCONFIG}" -o -n "${DEFCONFIG_FILE}" ]; then
	echo "Running oldconfig" | print_info
	yes "" | run_make oldconfig
fi

if [ -n "${RUN_MENUCONFIG}" ]; then
	make ${OUTPUT_OPTION} -j ${PARALLELISM_FACTOR} menuconfig
fi

if [ -n "${KERNEL}" ]; then
	run_make "${KERNEL_MAKE_OPTIONS}"
fi

if [ -n "${MODULES_LIST}" ]; then
	for CURRENT_MODULE in ${MODULES_LIST}; do
		echo "Compiling module \"${CURRENT_MODULE}\"..." | print_info
		run_make $(dirname ${CURRENT_MODULE})
		run_make ${CURRENT_MODULE}
		echo "Done" | print_info
	done
fi

if [ -n "${MODULES_TARBALL}" ]; then
	MODULES_DIRECTORY=$(mktemp -d -p "${TMP_DIR}")

	echo "Compiling modules..." | print_info
	run_make modules
	echo "Done" | print_info

	echo "Installing modules..." | print_info
	run_make "INSTALL_MOD_PATH=\"${MODULES_DIRECTORY}\" modules_install"
	echo "Done" | print_info

	echo "Creating modules tarball \"${MODULES_TARBALL}\"..." | print_info
	tar --owner=root --group=root -pczf "${MODULES_TARBALL}" -C "${MODULES_DIRECTORY}" .
	echo "Done" | print_info
fi

if [ -n "${MODULES_INSTALL_DIRECTORY}" ]; then
	echo "Installing modules..." | print_info
	run_make "INSTALL_MOD_PATH=\"${MODULES_INSTALL_DIRECTORY}\" modules_install"
	echo "Done" | print_info
fi

if [ -n "${UPDATE_SYMBOLS}" ]; then
	echo "Updating symbols databases" | print_info
	run_make "SRCARCH=${ARCH} SUBARCH=${SUBARCH} COMPILED_SOURCE=1 cscope tags"
	rm -f cscope.* tags
fi

echo "All DONE" | print_info
