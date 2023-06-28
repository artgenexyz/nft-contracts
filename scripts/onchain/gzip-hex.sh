#!/bin/sh

gzip -c $1 | xxd -p | tr -d '\n'
