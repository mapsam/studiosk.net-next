#!/usr/bin/env bash

ssk_image () {
  echo "converting image $1"

  file=$(basename -- "$1")
  EXT="${file##*.}"
  FILENAME_RAW="${file%.*}"
  FILENAME_NO_SPACES=${FILENAME_RAW// /_}
  FILENAME_ALPHANUMERIC=${FILENAME_NO_SPACES//[^_[:alnum:]]/}

  OUTPUT_DIR="out"
  mkdir -p $OUTPUT_DIR

  for size in 2000 1500 775; do
    magick "$1" -resize ${size}x "$OUTPUT_DIR/${FILENAME_ALPHANUMERIC}_w${size}.jpg"
  done 

  magick "$1" -scale 2% -blur 0x2.5 -resize 1000% "$OUTPUT_DIR/${FILENAME_ALPHANUMERIC}_blurred.jpg"
}
