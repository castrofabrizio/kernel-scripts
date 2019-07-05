#!/bin/bash
# This script is to strip the timestamp from kernel log

sed "s/^\[[ ]*\?[0-9.]*\] //g"
