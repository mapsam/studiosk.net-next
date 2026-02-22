#!/usr/bin/env bash

# Usage:
# ./generate_image_dimensions.sh path/to/images

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

# Find all _w2000.jpg images
find "$INPUT_DIR" -type f -name "*_w2000.jpg" | sort | while read -r file; do

  # Extract base filename
  filename=$(basename "$file")           # e.g. 1_STUDIO_SK_NS_044_w2000.jpg
  base="${filename%_w2000.*}"           # e.g. 1_STUDIO_SK_NS_044

  # Get width & height
  dimensions=$(magick identify -format "%w %h" "$file")
  width=$(echo "$dimensions" | cut -d' ' -f1)
  height=$(echo "$dimensions" | cut -d' ' -f2)

  # Build clean YAML key based on full path (remove /out/ and suffix)
  dirpath=$(dirname "$file")             # e.g. img/projects/nsb/out
  dirpath_no_out="${dirpath%/out}"       # e.g. img/projects/nsb
  full_key="/img/${dirpath_no_out#*/}/$base" # e.g. /img/projects/nsb/1_STUDIO_SK_NS_044

  # Locate blurred image
  blurred_image="$dirpath/${base}_blurred.jpg"
  if [ ! -f "$blurred_image" ]; then
    echo "Warning: blurred image not found for $file"
    continue
  fi

  # Convert blurred image to Base64 (safe for macOS & Linux)
  if [[ "$OSTYPE" == "darwin"* ]]; then
      blur_base64=$(base64 -i "$blurred_image" | tr -d '\n')
  else
      blur_base64=$(base64 -w 0 "$blurred_image")
  fi

  # Write YAML entry
  cat >> "$OUTPUT_FILE" <<EOF
  "${full_key}":
    width: ${width}
    height: ${height}
    blur_base64: "data:image/jpeg;base64,${blur_base64}"

EOF

  echo "Processed: $full_key (${width}x${height})"

done

echo "Done."