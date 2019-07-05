if [ -n "${UTILS_LOADED+x}" ]; then
	return
fi

check_exit_value () {
	local EXIT_VALUE=$1
	if [ ${EXIT_VALUE} -ne 0 ]; then
		exit ${EXIT_VALUE}
	fi
}

get_time_from_seconds () {
	local _SECONDS="$1"
	printf '%02d:%02d:%02d' $(($_SECONDS/3600)) $(($_SECONDS%3600/60)) $(($_SECONDS%60))
}

get_timestamp_seconds () {
	date +%s
}

get_timestamp_date () {
	date +"%Y-%m-%d %H:%M:%S"
}

get_timestamp_seconds_since_start () {
	expr $(get_timestamp_seconds) "-" ${START_TIME}
}

print_label () {
	local LABEL=""
	if [ -z "${QUIET+x}" ]; then
		if [ -n "$1" ]; then
			LABEL="[$1] "
		fi
		if [ -n "${PROGRAM_BASENAME}" ]; then
			LABEL="[${PROGRAM_BASENAME}]${LABEL}"
		fi
		sed -u "s/^/${LABEL}/g" || true
	fi
}

print_debug () {
	if [ -n "${DEBUG+x}" ]; then
		print_label "DEBUG"
	fi
}

print_error () {
	print_label "ERROR"
}

print_warning () {
	print_label "WARN"
}

print_info () {
	print_label "INFO"
}

print_no_label () {
	print_label
}

if [ -n "${DEBUG+x}" ]; then
	echo "Enabling debug prints and tracing" | print_info
	set -x
fi

register_cleanup_function () {
	if [ -z "$1" ]; then
		echo "You must provide a function name when invoking register_cleanup_function" | print_error
		return 1
	fi
	if [ "$1" == "__cleanup__" -o "$1" == "__failure__" ]; then
		echo "Please, rename your script specific cleanup function to something that won't cause any problems" | print_error
		return 1
	fi
	SCRIPT_SPECIFIC_CLEANUP_FUNCTION="$1"
}

__cleanup__ () {
	local END_TIME=$(get_timestamp_seconds)
	if [ -n "${SCRIPT_SPECIFIC_CLEANUP_FUNCTION}" ]; then
		(
			echo "Running script specific cleanup function..."
			${SCRIPT_SPECIFIC_CLEANUP_FUNCTION}
			echo "All done"
		) | print_info
	fi
	(
		echo "Cleaning temporary directory..."
		rm -rf "${TMP_DIR}"
		echo "Done"
	) | print_info
	echo "Execution time: $(get_time_from_seconds $((END_TIME - START_TIME)))" | print_label "$(get_timestamp_date)"
}

__failure__ () {
	local lineno=$1
	local msg=$2
	__cleanup__
	echo "Failed at $lineno: $msg" | print_error
}
trap '__failure__ ${LINENO} "$BASH_COMMAND"' ERR
trap '__cleanup__' EXIT SIGINT SIGTERM KILL
#set -e -o functrace -o pipefail
set -e -o functrace

START_TIME=$(get_timestamp_seconds)
TMP_DIR=$(mktemp -d)
UTILS_LOADED="yes"
