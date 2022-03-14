#!/bin/sh


# Remove duplicate lines from a csv file
#
# Usage:
#   remove_dups.sh <file>
#

cat $1 | sort | uniq > $1.tmp

