#!/bin/bash

# MERGE MEDIA IN SOURCE TO SINGLE MP4 (RESCALE ALL TO 1280X720)

# Load configuration from config.json
config_file="config.json"
if [ ! -f "$config_file" ]; then
  echo "Error: config.json not found!"
  exit 1
fi

source_folder=$(jq -r '.source_folder' "$config_file")
target_folder=$(jq -r '.target_folder' "$config_file")
audio_folder=$(jq -r '.audio_folder' "$config_file")

# Create temporary folder with unique name based on current timestamp
temp_folder="$target_folder/temp_$(date +%s)"
mkdir -p "$temp_folder"

# Get the resolution of the first input video
resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$source_folder"/input_video_001.mp4)

# If resolution is not available, use default values
if [ -z "$resolution" ]; then
  resolution="1280x720"
fi

# Loop through all video files in the source folder
for file in "$source_folder"/*.mp4; do
  # Resize the video to the common resolution, set SAR, and save to temporary folder
  filename=$(basename "$file")
  output_filepath="$temp_folder/${filename%.mp4}_resized.mp4"
  ffmpeg -i "$file" -vf "scale=$resolution:flags=bicubic,setsar=1:1" -c:v libx264 -c:a copy -y "$output_filepath"
done

# Run FFmpeg to merge the resized videos
merged_filename="merged_video.mp4"
input_string=""
for file in "$temp_folder"/*.mp4; do
  input_string+=" -i '$file'"
done
ffmpeg_command="ffmpeg $input_string -filter_complex 'concat=n=$(ls -1 "$temp_folder"/*.mp4 | wc -l):v=1:a=1[outv][outa]' -map '[outv]' -map '[outa]' '$target_folder/$merged_filename'"
eval $ffmpeg_command

echo "Merged video saved as: $target_folder/$merged_filename"

# Clean up temporary folder
rm -rf "$temp_folder"
