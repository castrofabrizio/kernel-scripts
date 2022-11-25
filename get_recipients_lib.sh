#!/bin/bash

for CURRENT_PATCH in ${@}; do
	if [[ "${CURRENT_PATCH}" != 0000* ]]; then
		PATCH_FILES="${PATCH_FILES} ${CURRENT_PATCH}"
	fi
	FILES="${FILES} ${CURRENT_PATCH}"
done

################################################################################
# Global variables
declare -a MUST_HAVE
MUST_HAVE=()

declare -a MUST_HAVE_TO
MUST_HAVE_TO=()

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
	NAME=$(echo "${RECIPIENT}" | awk -F" <" '{print $1}')
	EMAIL=$(echo "${RECIPIENT}" | awk -F">" '{print $1}')
	EMAIL=$(echo "${EMAIL}"     | awk -F"<" '{print $2}')
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

must_have() {
	local NAME="$1"
	local EMAIL="$2"
	local CURRENT_NAME
	local CURRENT_EMAIL
	local i


	for (( i=0; i <${#RECIPIENTS_FOUND[@]}; i++ )); do
		CURRENT_NAME=$(get_name_from_recipient "${RECIPIENTS_FOUND[$i]}")
		CURRENT_EMAIL=$(get_email_from_recipient "${RECIPIENTS_FOUND[$i]}")

		if [ "${NAME}" == "${CURRENT_NAME}" -a -n "${NAME}" ]; then
			return 1
		fi
		if [ "${EMAIL}" == "${CURRENT_EMAIL}" ]; then
			return 1
		fi
	done
	return 0
}

must_drop() {
	local NAME="$1"
	local EMAIL="$2"
	local CURRENT_NAME
	local CURRENT_EMAIL
	local i

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

loop_body() {
	local CURRENT_RECIPIENT="$1"
	CURRENT_RECIPIENT=$(get_recipient "${CURRENT_RECIPIENT}")
	if [ -n "${CURRENT_RECIPIENT}" ]; then
		echo "${CURRENT_RECIPIENT}"
	fi
}

process_must_add() {
	local KEY_FOUND=""
	local CURRENT_KEY=""
	local CURRENT_VALUE=""
	local CURRENT_ARGUMENT=""
	for CURRENT_KEY in "${!MUST_ADD[@]}"; do
		KEY_FOUND="false"
		for CURRENT_VALUE in ${MUST_ADD[${CURRENT_KEY}]}; do
			for CURRENT_ARGUMENT in "$@"; do
				if grep ${CURRENT_VALUE} ${CURRENT_ARGUMENT} 2>&1 > /dev/null; then
					# echo "Match for ${CURRENT_VALUE} in ${CURRENT_ARGUMENT}"
					if [ "${KEY_FOUND}" == "false" ]; then
						MUST_HAVE+=("${CURRENT_KEY}")
						KEY_FOUND="true"
					fi
				fi
			done
		done
	done
}

populate_to_list() {
	if [ -z "$TO_LIST" ]; then
		while read CURRENT_RECIPIENT; do
			CURRENT_RECIPIENT=$(loop_body "${CURRENT_RECIPIENT}")
			if [ -n "${CURRENT_RECIPIENT}" ]; then
				CURRENT_NAME=$(get_name_from_recipient "${CURRENT_RECIPIENT}")
				CURRENT_EMAIL=$(get_email_from_recipient "${CURRENT_RECIPIENT}")
				if must_have "${CURRENT_NAME}" "${CURRENT_EMAIL}"; then
					RECIPIENTS_FOUND+=("${CURRENT_RECIPIENT}")
					TO_LIST+=("${CURRENT_RECIPIENT}")
				fi
			fi
		done < <(./scripts/get_maintainer.pl ${PATCH_FILES} | grep maintainer)
	fi
	for (( i=0; i<${#MUST_HAVE_TO[@]}; i++)); do
		CURRENT_NAME=$(get_name_from_recipient "${MUST_HAVE_TO[$i]}")
		CURRENT_EMAIL=$(get_email_from_recipient "${MUST_HAVE_TO[$i]}")
		if must_have "${CURRENT_NAME}" "${CURRENT_EMAIL}"; then
			TO_LIST+=("${MUST_HAVE_TO[$i]}")
			RECIPIENTS_FOUND+=("${MUST_HAVE_TO[$i]}")
		fi
	done
}

populate_cc_list() {
	if [ -z "$CC_LIST" ]; then
		while read CURRENT_RECIPIENT; do
			CURRENT_RECIPIENT=$(loop_body "${CURRENT_RECIPIENT}")
			if [ -n "${CURRENT_RECIPIENT}" ]; then
				CURRENT_NAME=$(get_name_from_recipient "${CURRENT_RECIPIENT}")
				CURRENT_EMAIL=$(get_email_from_recipient "${CURRENT_RECIPIENT}")
				if must_have "${CURRENT_NAME}" "${CURRENT_EMAIL}"; then
					RECIPIENTS_FOUND+=("${CURRENT_RECIPIENT}")
					CC_LIST+=("${CURRENT_RECIPIENT}")
				fi
			fi
		done < <(./scripts/get_maintainer.pl ${PATCH_FILES} | grep -v maintainer)
	fi
	for (( i=0; i<${#MUST_HAVE[@]}; i++)); do
		CURRENT_NAME=$(get_name_from_recipient "${MUST_HAVE[$i]}")
		CURRENT_EMAIL=$(get_email_from_recipient "${MUST_HAVE[$i]}")
		if must_have "${CURRENT_NAME}" "${CURRENT_EMAIL}"; then
			CC_LIST+=("${MUST_HAVE[$i]}")
			RECIPIENTS_FOUND+=("${MUST_HAVE_TO[$i]}")
		fi
	done
}

print_mbox_style() {
	local TO_LIST_LAST
	local CC_LIST_LAST
	TO_LIST_LAST=${#TO_LIST[@]}
	TO_LIST_LAST=$(( TO_LIST_LAST - 1 ))
	echo "To:"
	for (( i=0; i<${#TO_LIST[@]}; i++ )); do
		echo -ne "\t${TO_LIST[$i]}"
		if [ $i -ne $TO_LIST_LAST ]; then
			echo ","
		else
			echo ""
		fi
	done

	CC_LIST_LAST=${#CC_LIST[@]}
	CC_LIST_LAST=$(( CC_LIST_LAST - 1 ))
	echo "Cc:"
	for (( i=0; i<${#CC_LIST[@]}; i++ )); do
		echo -ne "\t${CC_LIST[$i]}"
		if [ $i -ne $CC_LIST_LAST ]; then
			echo ","
		else
			echo ""
		fi
	done
}

print_send_email_style() {
	local TO_LIST_LAST
	local CC_LIST_LAST
	TO_LIST_LAST=${#TO_LIST[@]}
	TO_LIST_LAST=$(( TO_LIST_LAST - 1 ))
	for (( i=0; i<${#TO_LIST[@]}; i++ )); do
		echo -e "--to \"${TO_LIST[$i]}\" \\"
	done

	CC_LIST_LAST=${#CC_LIST[@]}
	CC_LIST_LAST=$(( CC_LIST_LAST - 1 ))
	for (( i=0; i<${#CC_LIST[@]}; i++ )); do
		echo -e "--cc \"${CC_LIST[$i]}\" \\"
	done

}

print_recipients() {
	if [ -n "$PRINT_SEND_EMAIL" ]; then
		print_send_email_style
	else
		print_mbox_style
	fi
}
