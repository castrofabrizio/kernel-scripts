#!/bin/bash

INPUT="$1"

COMMIT_HASH=$(git log --format=%H -n 1 "${INPUT}")
COMMIT_MESSAGE=$(git log --format=%s -n 1 "${INPUT}")
COMMIT_HASH=${COMMIT_HASH:0:12}

echo "${COMMIT_HASH} (\"${COMMIT_MESSAGE}\")"
