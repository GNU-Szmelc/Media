#!/bin/bash

# STRIP AUDIO TRACS FROM MP4 FILES INSIDE SOURCE FOLDER (Create muted copy inside Target folder)

# Check if config.json exists, otherwise generate it with default folder paths
config_file="config.json"
if [ ! -e "$config_file" ]; then
  echo '{ "source_folder": "Source", "target_folder": "Target" }' > "$config_file"
  echo "config.json file has been generated with default folder paths."
fi

# Read folder paths from config.json
source_folder=$(jq -r .source_folder "$config_file")
target_folder=$(jq -r .target_folder "$config_file")

# Create target folder if it doesn't exist
mkdir -p "$target_folder"

# Loop through all files in the source folder
for file in "$source_folder"/*; do
  if [ -f "$file" ]; then
    # Get the filename without extension
    filename=$(basename "$file" | cut -d. -f1)

    # Create muted copy of the file in the target folder
    target_file="$target_folder/$filename-muted.${file##*.}"
    ffmpeg -i "$file" -c copy -an "$target_file"
    echo "Created muted copy: $target_file"
  fi
done
