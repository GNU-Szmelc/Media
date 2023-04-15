#!/bin/bash

# Create 'Downloads' folder inside script's directory
downloads_folder="$(dirname "$(readlink -f "$0")")/Downloads"
mkdir -p "$downloads_folder"

# Check if config.json exists, otherwise generate it with default folder path
config_file="config.json"
if [ ! -e "$config_file" ]; then
  echo '{ "folder": "'"$downloads_folder"'" }' > "$config_file"
  echo "config.json file has been generated with the default folder path: $downloads_folder"
fi

# Read folder path from config.json
folder=$(jq -r .folder "$config_file")

# Prompt the user to enter the URL
echo " DOWNLOAD MP4 "
echo "Please paste the URL:"
read url

# Execute yt-dlp command with the provided URL and folder path
yt-dlp -o "$folder/%(title)s.%(ext)s" -S res,ext:mp4:m4a --recode mp4 "$url"
