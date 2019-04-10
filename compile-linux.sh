#!/bin/bash -e

################################################################################
# Parameters

NUMBER_OF_CORES=$(grep -c ^proc /proc/cpuinfo)
PARALLELISM_FACTOR=$((NUMBER_OF_CORES * 2))
PROGRAM_NAME="$(basename "$0")"
COMMAND_NAME="$0"
BUILD_DIRECTORY=""

################################################################################
# Helpers

print_help() {
	cat<<-EOF

	 This script helps with the configuration and compilation of the kernel.

	 USAGE: ${COMMAND_NAME} [-t <file>] [-d <config>] [-k [-K <opts>]] \\
	           [-s] [-M] [-m <file>] [-b <dir>] [-h]

	 OPTIONS:
	 -h		Print this help and exit
	 -t <file>	Cross-toolchain filepath
	 -d <config>    defconfig to use
	 -k		Compile the kernel
	 -K <opts>	Use <opts> when compiling the kernel
	 -s		Update cscope and tags
	 -M		Run menuconfig
	 -m <file>	Compile the modules and generate a tarball.
	 -b <dir>	Build directory filepath.

	EOF
}

print_error() {
	echo " [ERROR] $@" >&2
}

print_info() {
	echo " [INFO]  $@" >&2
}

################################################################################
# Options parsing

while getopts ":t:d:kK:sMm:b:h" opt; do
	case $opt in
	t)
		if [ ! -f "${OPTARG}" ]; then
			print_error "[-f] No such file"
			exit 1
		fi
		TOOLCHAIN_ENVIRONMENT="${OPTARG}"
		;;
	d)
		DEFCONFIG="${OPTARG}"
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
	b)
		if [ ! -d "${OPTARG}" ]; then
			print_error "No such directory \"${OPTARG}\""
			print_help
			exit 1
		fi
		BUILD_DIRECTORY="$(realpath "${OPTARG}")"
		;;
	h)
		print_help
		exit 1
		;;
	\?)
		print_error "Invalid option: -$OPTARG"
		exit 1
		;;
	:)
		print_error "Option -$OPTARG requires an argument."
		exit 1
		;;
	esac
done

[ -n "${TOOLCHAIN_ENVIRONMENT}" ] || \
	{ print_error "Please, specify [-t]"; print_help; exit 1; }

################################################################################
# Main

if [ -n "${BUILD_DIRECTORY}" ]; then
	OUTPUT_OPTION="O=\"${BUILD_DIRECTORY}\""
fi

if [ -n "${TOOLCHAIN_ENVIRONMENT}" ]; then
	if [ -z "${ARCH}" ]; then
		print_info "Sourcing the environment"
		source ${TOOLCHAIN_ENVIRONMENT}
	else
		print_info "Environment already sourced"
	fi
fi

if [ -n "${DEFCONFIG}" ]; then
	print_info "Configuring the kernel"
	make ${OUTPUT_OPTION} ${DEFCONFIG}
fi

if [ -n "${RUN_MENUCONFIG}" ]; then
	make ${OUTPUT_OPTION} -j ${PARALLELISM_FACTOR} menuconfig
fi

if [ -n "${KERNEL}" ]; then
	print_info "Compiling the kernel"
	make ${OUTPUT_OPTION} -j ${PARALLELISM_FACTOR} ${KERNEL_MAKE_OPTIONS}
fi

if [ -n "${MODULES_TARBALL}" ]; then
	MODULES_DIRECTORY=$(mktemp -d)

	print_info "Compiling modules..."
	make ${OUTPUT_OPTION} -j ${PARALLELISM_FACTOR} modules
	print_info "Done"

	print_info "Installing modules..."
	make ${OUTPUT_OPTION} -j ${PARALLELISM_FACTOR} INSTALL_MOD_PATH="${MODULES_DIRECTORY}" modules_install
	print_info "Done"

	print_info "Creating modules tarball..."
	tar -pczf "${MODULES_TARBALL}" -C "${MODULES_DIRECTORY}" .
	print_info "Done"

	print_info "Cleaning up,.."
	rm -rf ${MODULES_DIRECTORY}
	print_info "Done"
fi

if [ -n "${UPDATE_SYMBOLS}" ]; then
	print_info "Updating symbols databases"
	make ${OUTPUT_OPTION} -j ${PARALLELISM_FACTOR} SRCARCH=${ARCH} SUBARCH=${SUBARCH} COMPILED_SOURCE=1 cscope tags
	rm -f cscope.* tags
fi
