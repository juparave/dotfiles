#!/bin/bash

# Check if a filename parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <filename.mov>"
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

# Convert the MOV file to MP4 using ffmpeg
ffmpeg -i "$input_file" -c:v copy -c:a aac -b:a 256k "$output_file"

echo "Conversion complete. Output file: $output_file"

