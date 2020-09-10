#!/bin/bash

BOOTDIR="$1"

if [ -z "${BOOTDIR}" ]; then
	echo "Please, give the path to the boot directory so that I can create symbolic links" 1>&2
	exit 1
fi

if [ ! -d "${BOOTDIR}" ]; then
	echo "\"${BOOTDIR}\" No such directory" 1>&2
	exit 1
fi

BOOTDIR="$(realpath "${BOOTDIR}")"

cd ${BOOTDIR}/..

while read CURRENT_ITEM; do
	rm -f "$(basename ${CURRENT_ITEM})"
	ln -sf "${CURRENT_ITEM}" "$(basename "${CURRENT_ITEM}")"
done < <(ls $(basename "${BOOTDIR}")/*)
