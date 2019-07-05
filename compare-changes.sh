#!/bin/bash
# This script compares the changes from two different commits

diff <(git show $1) <(git show $2) | less
