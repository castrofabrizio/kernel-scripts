#!/bin/bash

# This script cleans up the log from a debug console by stripping prints that
# don't belong to the kernel log

sed "s|^\(.\)\+\[ |\[ |g" | \
	grep -a -v '^\[  OK  \]' | \
	grep -a -v '^\[FAILED\]' | \
	grep -a -v '^[^\[]'
