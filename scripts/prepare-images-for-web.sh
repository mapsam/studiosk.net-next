#!/usr/bin/env bash

echo "converting image $1"

file=$(basename -- "$1")
EXT="${file##*.}"
FILENAME="${file%.*}"
FILENAME_CLEANED=${FILENAME// /_}

OUTPUT_DIR="out"
mkdir -p $OUTPUT_DIR

for size in 2000 775; do
  magick "$1" -resize ${size}x "$OUTPUT_DIR/${FILENAME_CLEANED}_w${size}.$EXT"
done 

magick "$1" -scale 2% -blur 0x2.5 -resize 1000% "$OUTPUT_DIR/${FILENAME_CLEANED}_blurred.$EXT"
