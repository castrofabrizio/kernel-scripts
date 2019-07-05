#!/bin/bash
if [ -n "${MACHINE}" ]; then
	PS1="\u@${MACHINE}\$ "
fi
