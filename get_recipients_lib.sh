#!/bin/bash

PATCH_FILES="$@"

################################################################################
# Global variables
declare -a MUST_HAVE
MUST_HAVE=()

declare -A MUST_ADD
MUST_ADD=()

declare -a MUST_DROP
MUST_DROP=()

declare -a RECIPIENTS_FOUND
RECIPIENTS_FOUND=()

declare -a TO_LIST
TO_LIST=()

declare -a CC_LIST
CC_LIST=()

################################################################################
# Utils
get_email_from_recipient() {
	local RECIPIENT="$1"
	local EMAIL
	local NAME

	NAME=$(echo "${RECIPIENT}"  | awk -F" <" '{print $1}')
	EMAIL=$(echo "${RECIPIENT}" | awk -F">"  '{print $1}' | awk -F"<"  '{print $2}')

	if [ -z "${EMAIL}" ]; then
		echo "${NAME}"
	else
		echo "${EMAIL}"
	fi
}

get_name_from_recipient() {
	local RECIPIENT="$1"
	local NAME

	echo "RECIPIENT ${RECIPIENT}"
	NAME=$(echo "${RECIPIENT}" | awk -F" <" '{print $1}')
	echo "${NAME}"
}

already_a_recipient() {
	local i
	local NAME="$1"
	local EMAIL="$2"
	local CURRENT_NAME
	local CURRENT_EMAIL

	for (( i=0; i <${#RECIPIENTS_FOUND[@]}; i++ )); do
		CURRENT_NAME=$(get_name_from_recipient "${RECIPIENTS_FOUND[$i]}")
		CURRENT_EMAIL=$(get_email_from_recipient "${RECIPIENTS_FOUND[$i]}")

		if [ "${NAME}" == "${CURRENT_NAME}" -a -n "${NAME}" ]; then
			return 0
		fi
		if [ "${EMAIL}" == "${CURRENT_EMAIL}" ]; then
			return 0
		fi
	done

	return 1
}

must_drop() {
	local i
	local NAME="$1"
	local EMAIL="$2"
	local CURRENT_NAME
	local CURRENT_EMAIL

	for (( i=0; i<${#MUST_DROP[@]}; i++ )); do
		CURRENT_NAME=$(get_name_from_recipient "${MUST_DROP[$i]}")
		CURRENT_EMAIL=$(get_email_from_recipient "${MUST_DROP[$i]}")

		if [ "${NAME}" == "${CURRENT_NAME}" -a -n "${NAME}" ]; then
			return 0
		fi
		if [ "${EMAIL}" == "${CURRENT_EMAIL}" ]; then
			return 0
		fi
	done

	return 1
}

process_must_add() {
	local KEY_FOUND
	local CURRENT_KEY=""
	local CURRENT_VALUE=""
	local CURRENT_ARGUMENT=""

	for CURRENT_KEY in "${!MUST_ADD[@]}"; do
		KEY_FOUND=false

		for CURRENT_VALUE in ${MUST_ADD[${CURRENT_KEY}]}; do
			for CURRENT_ARGUMENT in "$@"; do
				if grep -q ${CURRENT_VALUE} ${CURRENT_ARGUMENT}; then
					if ! ${KEY_FOUND}; then
						MUST_HAVE+=("${CURRENT_KEY}")
						KEY_FOUND="true"
						break
					fi
				fi
			done
			if ${KEY_FOUND}; then
				break
			fi
		done
	done
}

get_recipient() {
	local FULL_STRING="$1"
	local RECIPIENT
	local EMAIL
	local NAME

	RECIPIENT=$(echo "${FULL_STRING}" | awk -F" \\\(" '{print $1}')
	NAME=$(get_name_from_recipient "${RECIPIENT}")
	EMAIL=$(get_email_from_recipient "${RECIPIENT}")
	if [ -z "${EMAIL}" ]; then
		EMAIL="${NAME}"
		NAME=""
	fi

	if ! must_drop "${NAME}" "${EMAIL}"; then
		echo "${RECIPIENT}"
	fi
}

get_filtered_recipient() {
	local CURRENT_RECIPIENT="$1"

	CURRENT_RECIPIENT=$(get_recipient "${CURRENT_RECIPIENT}")
	if [ -n "${CURRENT_RECIPIENT}" ]; then
		echo "${CURRENT_RECIPIENT}"
	fi
}

populate_to_list() {
	local CURRENT_RECIPIENT
	local CURRENT_EMAIL
	local CURRENT_NAME
	local i

	if [ -z "$TO_LIST" ]; then
		while read CURRENT_RECIPIENT; do
			CURRENT_RECIPIENT=$(get_filtered_recipient "${CURRENT_RECIPIENT}")
			CURRENT_NAME=$(get_name_from_recipient "${CURRENT_RECIPIENT}")
			CURRENT_EMAIL=$(get_email_from_recipient "${CURRENT_RECIPIENT}")
			if already_a_recipient "${CURRENT_NAME}" "${CURRENT_EMAIL}"; then
				continue
			fi
			if [ -n "${CURRENT_RECIPIENT}" ]; then
				RECIPIENTS_FOUND+=("${CURRENT_RECIPIENT}")
				TO_LIST+=("${CURRENT_RECIPIENT}")
			fi
		done < <(./scripts/get_maintainer.pl ${PATCH_FILES} | grep maintainer)
	fi

	for (( i=0; i<${#MUST_HAVE_TO[@]}; i++)); do
		CURRENT_NAME=$(get_name_from_recipient "${MUST_HAVE_TO[$i]}")
		CURRENT_EMAIL=$(get_email_from_recipient "${MUST_HAVE_TO[$i]}")
		if ! already_a_recipient "${CURRENT_NAME}" "${CURRENT_EMAIL}"; then
			RECIPIENTS_FOUND+=("${MUST_HAVE_TO[$i]}")
			TO_LIST+=("${MUST_HAVE_TO[$i]}")
		fi
	done
}

populate_cc_list() {
	local CURRENT_RECIPIENT
	local CURRENT_EMAIL
	local CURRENT_NAME
	local i

	if [ -z "$CC_LIST" ]; then
		while read CURRENT_RECIPIENT; do
			CURRENT_RECIPIENT=$(get_filtered_recipient "${CURRENT_RECIPIENT}")
			CURRENT_NAME=$(get_name_from_recipient "${CURRENT_RECIPIENT}")
			CURRENT_EMAIL=$(get_email_from_recipient "${CURRENT_RECIPIENT}")
			if already_a_recipient "${CURRENT_NAME}" "${CURRENT_EMAIL}"; then
				continue
			fi
			if [ -n "${CURRENT_RECIPIENT}" ]; then
				RECIPIENTS_FOUND+=("${CURRENT_RECIPIENT}")
				CC_LIST+=("${CURRENT_RECIPIENT}")
			fi
		done < <(./scripts/get_maintainer.pl ${PATCH_FILES} | grep -v maintainer)
	fi

	for (( i=0; i<${#MUST_HAVE[@]}; i++)); do
		CURRENT_NAME=$(get_name_from_recipient "${MUST_HAVE[$i]}")
		CURRENT_EMAIL=$(get_email_from_recipient "${MUST_HAVE[$i]}")
		if ! already_a_recipient "${CURRENT_NAME}" "${CURRENT_EMAIL}"; then
			RECIPIENTS_FOUND+=("${MUST_HAVE[$i]}")
			CC_LIST+=("${MUST_HAVE[$i]}")
		fi
	done
}

print_mbox_style() {
	local i

	if [ ${#TO_LIST[@]} -gt 0 ]; then
		echo "To:"
		for (( i=0; i<${#TO_LIST[@]} - 1; i++ )); do
			echo -e "\t${TO_LIST[$i]},"
		done
		if [ $i -lt ${#TO_LIST[@]} ]; then
			echo -e "\t${TO_LIST[$i]}"
		fi
	fi

	if [ ${#CC_LIST[@]} -gt 0 ]; then
		echo "Cc:"
		for (( i=0; i<${#CC_LIST[@]} - 1; i++ )); do
			echo -e "\t${CC_LIST[$i]},"
		done
		if [ $i -lt ${#CC_LIST[@]} ]; then
			echo -e "\t${CC_LIST[$i]}"
		fi
	fi
}

print_send_email_style() {
	local i

	for (( i=0; i<${#TO_LIST[@]}; i++ )); do
		echo -e "--to \"${TO_LIST[$i]}\" \\"
	done

	for (( i=0; i<${#CC_LIST[@]}; i++ )); do
		echo -e "--cc \"${CC_LIST[$i]}\" \\"
	done
}

print_recipients() {
	local STYLE="$1"

	if [ "${STYLE}" == "email" ]; then
		print_send_email_style
	elif [ "${STYLE}" == "mbox" ]; then
		print_mbox_style
	fi
}
