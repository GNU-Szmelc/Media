#!/bin/bash

# CREATE NEW MP4 CUT [FROM / TO] INITIAL MEDIA (IN SECONDS)

# Read the configuration from config.json file
config_file="config.json"
source_folder=$(jq -r '.source_folder' "$config_file")
target_folder=$(jq -r '.target_folder' "$config_file")
audio_folder=$(jq -r '.audio_folder' "$config_file")

# Prompt the user to specify the input file
read -p "Enter the input file name (including .mp4 extension): " source_file

# Check if the input file exists
if [ ! -f "$source_folder/$source_file" ]; then
  echo "File not found. Exiting..."
  exit 1
fi

# Prompt the user to specify the start and end times for the media to keep
read -p "Enter the start time in seconds (e.g., 30 for 30 seconds): " start_time
read -p "Enter the end time in seconds (e.g., 60 for 60 seconds): " end_time

# Create the target folder if it doesn't exist
mkdir -p "$target_folder"

# Set initial output file number to 1
output_file_number=1

# Loop to find the next available output file number
while [ -f "$target_folder/output${output_file_number}.mp4" ]; do
  ((output_file_number++))
done

# Construct the output file name with the next available number
output_file="$target_folder/output${output_file_number}.mp4"

# Use ffmpeg with complex filtergraph to discard video and audio outside the specified timeframe
ffmpeg -i "$source_folder/$source_file" -filter_complex "[0:v]trim=start=$start_time:end=$end_time,setpts=PTS-STARTPTS[v];[0:a]atrim=start=$start_time:end=$end_time,asetpts=PTS-STARTPTS[a]" -map "[v]" -map "[a]" -c:v libx264 -c:a aac "$output_file"

echo "Media trimmed successfully! Saved as $output_file in the Target folder."
