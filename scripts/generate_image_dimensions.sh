#!/usr/bin/env bash

# Usage:
# ./generate_image_dimensions.sh img/

INPUT_DIR="$1"
OUTPUT_FILE="_data/image_dimensions.yml"

if [ -z "$INPUT_DIR" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

if [ ! -d "$INPUT_DIR" ]; then
  echo "Error: '$INPUT_DIR' is not a directory."
  exit 1
fi

mkdir -p "_data"
echo "Generating $OUTPUT_FILE ..."
echo "" > "$OUTPUT_FILE"

find "$INPUT_DIR" -type f -name "*_w2000.jpg" | sort | while read -r file; do

  filename=$(basename "$file")
  base="${filename%_w2000.*}"

  # Get dimensions
  dimensions=$(magick identify -format "%w %h" "$file")
  width=$(echo "$dimensions" | cut -d' ' -f1)
  height=$(echo "$dimensions" | cut -d' ' -f2)

  # Build clean path key
  dirpath=$(dirname "$file")
  dirpath_no_out="${dirpath%/out}"
  full_key="/img/${dirpath_no_out#*/}/$base"

  cat >> "$OUTPUT_FILE" <<EOF
"${full_key}":
  width: ${width}
  height: ${height}

EOF

  echo "Processed: $full_key (${width}x${height})"
done

echo "Done."