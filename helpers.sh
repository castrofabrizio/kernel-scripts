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
