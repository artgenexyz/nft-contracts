#!/bin/sh

export INPUT=$1

npx terser -m --ecma 8 $INPUT | gzip -c $OUTPUT | xxd -p | tr -d '\n'


