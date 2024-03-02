#!/bin/bash

# Check if a filename parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <filename.mp4>"
    exit 1
fi

# Input filename with extension
input_file="$1"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found."
    exit 1
fi

# Remove the file extension from the input filename
filename="${input_file%.*}"

# Output filename with MP4 extension
output_file="${filename}.mp4"

# Set bitrate to 800k, use the -y option to automatically overwrite
ffmpeg -y -i "$input_file" -b 800k "$output_file"

echo "Conversion complete. Output file: $output_file"

