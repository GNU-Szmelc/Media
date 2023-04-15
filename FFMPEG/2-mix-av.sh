#!/bin/bash

# MIX MP4 WITH WAV

# Prompt user for audio file name and extension
read -p "Enter the name of the audio file (without extension): " audio_name
read -p "Enter the extension of the audio file (e.g., wav, mp3): " audio_ext

# Prompt user for video file name and extension
read -p "Enter the name of the video file (without extension): " video_name
read -p "Enter the extension of the video file (e.g., mp4, mov): " video_ext

# Generate a unique output file name with a number suffix
output_file="Target/output-1.mp4"
count=1
while [ -f "$output_file" ]; do
  ((count++))
  output_file="Target/output-$count.mp4"
done

# Combine video and audio using ffmpeg, remove original audio, and save output in numbered output file
ffmpeg -i "Source/${video_name}.${video_ext}" -i "Audio/${audio_name}.${audio_ext}" -c:v copy -c:a aac -map 0:v -map 1:a -shortest -movflags +faststart "$output_file"

echo "Combined video and audio into $output_file with replaced audio"
