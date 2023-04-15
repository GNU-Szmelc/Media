#!/bin/bash

# GENERATE LIGHTWEIGHT (UNDER 7MB) GIF FROM MEDIA INSIDE SOURCE FOLDER

# Load config.json
config_file="$(dirname "$0")/config.json"
if [ ! -f "${config_file}" ]; then
  echo "config.json not found. Exiting..."
  exit 1
fi

source_folder=$(jq -r '.source_folder' "${config_file}")
target_folder=$(jq -r '.target_folder' "${config_file}")
audio_folder=$(jq -r '.audio_folder' "${config_file}")

# Create target and audio folders if they don't exist
mkdir -p "${target_folder}"
mkdir -p "${audio_folder}"

# Iterate through files in the source folder
for file in "${source_folder}"/*.{mp4,jpeg,jpg,png,webm,mov,mkv,avi}; do
  # Get the file extension
  extension="${file##*.}"

  # Create the target file name by replacing the extension with .gif
  target_file="${target_folder}/$(basename "${file%.*}").gif"

  # Check if the target file already exists, if yes, skip
  if [ -f "${target_file}" ]; then
    echo "File already exists: ${target_file}. Skipping..."
    continue
  fi

  # Convert video and image files to GIF using ffmpeg with compression and size limit
  if [[ "${extension}" == "mp4" || "${extension}" == "webm" || "${extension}" == "mov" || "${extension}" == "mkv" || "${extension}" == "avi" ]]; then
    ffmpeg -i "${file}" -vf "fps=10,scale=320:-1:flags=lanczos" -s 320x240 -c:v gif "${target_file}"
  elif [[ "${extension}" == "jpeg" || "${extension}" == "jpg" || "${extension}" == "png" ]]; then
    ffmpeg -loop 1 -i "${file}" -vf "fps=10,scale=320:-1:flags=lanczos" -s 320x240 -c:v gif "${target_file}"
  else
    echo "Skipping unsupported file: ${file}"
    continue
  fi

  # Compress the GIF file to reduce its size
  gifsize=$(wc -c <"${target_file}")
  while [ "${gifsize}" -gt 7000000 ]; do
    ffmpeg -i "${target_file}" -vf "fps=10,scale=320:-1:flags=lanczos" -s 320x240 -c:v gif "${target_file}"
    gifsize=$(wc -c <"${target_file}")
  done

  echo "Converted: ${file} -> ${target_file}"
done

# Move audio files to the audio folder
mv "${source_folder}"/*.{mp3,wav,ogg} "${audio_folder}/" 2>/dev/null

echo "Audio files moved to: ${audio_folder}"
