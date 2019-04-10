print_debug () {
	sed "s/^/ [DEBUG] /g"
}

print_error () {
	sed "s/^/ [ERROR] /g"
}

print_warning () {
	sed "s/^/ [WARN]  /g"
}

print_info () {
	sed "s/^/ [INFO]  /g"
}
