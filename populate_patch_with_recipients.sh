#!/bin/bash

################################################################################
# Parameters
PROGRAM_DIRECTORY="$(cd "$(dirname "$0")"; pwd)"
PROGRAM_NAME="$(basename "$0")"
COMMAND_NAME="$0"

################################################################################
# Options
PATCH_FILE=""
RECIPIENTS_FILE=""
OUTPUT_FILE=""

################################################################################
# Helpers

print_help() {
cat<<EOF

 This script fits recipients into the specified patch file and
 prints it all on the standard output

 USAGE: ${COMMAND_NAME} -p <file> [-k] [-r <file>] [-h]

 OPTIONS:
 -p <file>	The desired patch file to fit with recipients
 -k             Do not drop the kernel mailing list from the list of recipients
 -r <file>	Use the recipients provided by the specified file. This
 		parameter is optional, the recipients will be automatically
		generated when this parameter is missing
 -h		Print this help and exit

EOF
}

print_error () {
	echo " [ERROR] $@" >&2
}

print_info () {
	echo " [INFO] $@" >&2
}

get_filepath () {
	local CURRENT_FILE="$1"
	echo "$(cd "$(dirname "${CURRENT_FILE}")"; pwd)/$(basename "${CURRENT_FILE}")"
}

################################################################################
# Options parsing

while getopts ":p:r:kh" opt; do
	case $opt in
	p)
		if [ ! -f "${OPTARG}" ]; then
			print_error "\"${OPTARG}\" No such file"
			print_help
			exit 1
		fi
		PATCH_FILE="$(get_filepath "${OPTARG}")"
		;;
	r)
		if [ ! -f "${OPTARG}" ]; then
			print_error "\"${OPTARG}\" No such file"
			print_help
			exit 1
		fi
		RECIPIENTS_FILE="$(get_filepath "${OPTARG}")"
		;;
	k)
		export KEEP_KERNEL_ML=true
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

if [ -z "${PATCH_FILE}" ]; then
	print_error "Please, specify option -p"
	print_help
	exit 1
fi

################################################################################
# Main

STATE=HEADER
CURRENT_LINE_NUMBER=0
RECIPIENTS_LINE_NUMBER=
while read CURRENT_LINE; do
	((CURRENT_LINE_NUMBER++))
	case ${STATE} in
		HEADER)
			if echo "${CURRENT_LINE}" | grep "^Subject: " > /dev/null 2>&1; then
				STATE=SUBJECT
			fi
			;;
		SUBJECT)
			if [ -z "${CURRENT_LINE}" ]; then
				RECIPIENTS_LINE_NUMBER="${CURRENT_LINE_NUMBER}"
				STATE=TAIL
			fi
			;;
		TAIL)
			;;
	esac
done < "${PATCH_FILE}"

if [ -n "${RECIPIENTS_LINE_NUMBER}" ]; then
	head -n $((${RECIPIENTS_LINE_NUMBER} - 1)) "${PATCH_FILE}"
	if [ -z "${RECIPIENTS_FILE}" ]; then
		"${PROGRAM_DIRECTORY}"/get_recipients.sh "${PATCH_FILE}"
	else
		cat "${RECIPIENTS_FILE}"
	fi
	tail -n +${RECIPIENTS_LINE_NUMBER} "${PATCH_FILE}"
fi
