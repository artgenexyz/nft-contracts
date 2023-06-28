#!/bin/sh

export DIRNAME=$(dirname $0)
export INPUT=$DIRNAME/artgene.js
export OUTPUT=$DIRNAME/artgene.min.js
export OUTPUT_GZ=$DIRNAME/artgene.min.js.gz

npx terser -m --ecma 8 $INPUT -o $OUTPUT
echo "Minified! $OUTPUT"

gzip -c $OUTPUT | xxd -p | tr -d '\n' > $OUTPUT_GZ
echo "Compressed and encoded! $OUTPUT_GZ"

cat $OUTPUT_GZ | pbcopy
echo "Copied to clipboard!"
