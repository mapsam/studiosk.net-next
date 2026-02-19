ssk_image () {
  INPUT="$1"
  OUTPUT_DIR="out"

  if [ -z "$INPUT" ]; then
    echo "Usage: ssk_image <file-or-directory>"
    return 1
  fi

  mkdir -p "$OUTPUT_DIR"

  process_file () {
    local filepath="$1"

    echo "Converting image: $filepath"

    file=$(basename -- "$filepath")
    EXT="${file##*.}"
    FILENAME_RAW="${file%.*}"
    FILENAME_NO_SPACES="${FILENAME_RAW// /_}"
    FILENAME_ALPHANUMERIC="${FILENAME_NO_SPACES//[^_[:alnum:]]/}"

    for size in 2000 1500 775; do
      # JPEG version
      magick "$filepath" -resize "${size}x" \
        "$OUTPUT_DIR/${FILENAME_ALPHANUMERIC}_w${size}.jpg"

      # WebP version
      magick "$filepath" -resize "${size}x" \
        "$OUTPUT_DIR/${FILENAME_ALPHANUMERIC}_w${size}.webp"
    done 

    # Blurred variant (JPEG)
    magick "$filepath" -scale 2% -blur 0x2.5 -resize 1000% \
      "$OUTPUT_DIR/${FILENAME_ALPHANUMERIC}_blurred.jpg"

    # Blurred variant (WebP)
    magick "$filepath" -scale 2% -blur 0x2.5 -resize 1000% \
      "$OUTPUT_DIR/${FILENAME_ALPHANUMERIC}_blurred.webp"
  }

  if [ -d "$INPUT" ]; then
    # Process directory recursively
    find "$INPUT" -type f \( \
      -iname "*.jpg" -o \
      -iname "*.jpeg" -o \
      -iname "*.png" -o \
      -iname "*.webp" \
    \) ! -path "*/$OUTPUT_DIR/*" | while read -r file; do
      process_file "$file"
    done

  elif [ -f "$INPUT" ]; then
    process_file "$INPUT"

  else
    echo "Error: '$INPUT' is not a valid file or directory."
    return 1
  fi
}