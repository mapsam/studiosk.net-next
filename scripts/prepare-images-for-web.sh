ssk_image () {
  INPUT="$1"

  if [ -z "$INPUT" ]; then
    echo "Usage: ssk_image <file-or-directory>"
    return 1
  fi

  process_file () {
    local filepath="$1"
    local dirpath="$2"

    echo "Converting image: $filepath"

    file=$(basename -- "$filepath")
    EXT="${file##*.}"
    FILENAME_RAW="${file%.*}"
    FILENAME_NO_SPACES="${FILENAME_RAW// /_}"
    FILENAME_ALPHANUMERIC="${FILENAME_NO_SPACES//[^_[:alnum:]]/}"

    local output_dir="$dirpath/out"
    mkdir -p "$output_dir"

    for size in 2000 1500 775; do
      # JPEG version (good fallback format)
      magick "$filepath" \
        -resize "${size}x" \
        -quality 100 \
        "$output_dir/${FILENAME_ALPHANUMERIC}_w${size}.jpg"

      # WebP version (smaller, modern format)
      magick "$filepath" \
        -resize "${size}x" \
        -quality 100 \
        "$output_dir/${FILENAME_ALPHANUMERIC}_w${size}.webp"
    done 

    # Blurred placeholder (JPEG)
    magick "$filepath" \
      -resize 40x \
      -blur 0x8 \
      "$output_dir/${FILENAME_ALPHANUMERIC}_blurred.jpg"

    # Blurred placeholder (WebP)
    magick "$filepath" \
      -resize 40x \
      -blur 0x8 \
      "$output_dir/${FILENAME_ALPHANUMERIC}_blurred.webp"
  }

  if [ -d "$INPUT" ]; then
    find "$INPUT" -type f \( \
      -iname "*.jpg" -o \
      -iname "*.jpeg" -o \
      -iname "*.png" -o \
      -iname "*.webp" -o \
      -iname "*.tif" -o \
      -iname "*.tiff" \
    \) ! -path "*/out/*" | while read -r file; do
      dirpath=$(dirname "$file")
      process_file "$file" "$dirpath"
    done

  elif [ -f "$INPUT" ]; then
    dirpath=$(dirname "$INPUT")
    process_file "$INPUT" "$dirpath"

  else
    echo "Error: '$INPUT' is not a valid file or directory."
    return 1
  fi
}