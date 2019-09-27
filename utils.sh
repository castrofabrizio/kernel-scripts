if [ -n "${UTILS_LOADED+x}" ]; then
	return
fi

PROGRAM_DIRECTORY="${PROGRAM_DIRECTORY:-$(dirname "$(realpath "${BASH_SOURCE[0]}")")}"
source "${PROGRAM_DIRECTORY}/helpers.sh"

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
