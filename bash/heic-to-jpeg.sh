#!/bin/bash

# Script to convert HEIC files to JPEG and remove metadata
# Based on sips, works on macOS
# Usage: ./heic_to_jpeg.sh <input_folder> <output_folder>

# Check if correct number of arguments provided
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments"
    echo "Usage: $0 <input_folder> <output_folder>"
    exit 1
fi

INPUT_FOLDER="$1"
OUTPUT_FOLDER="$2"

# Check if input folder exists
if [ ! -d "$INPUT_FOLDER" ]; then
    echo "Error: Input folder '$INPUT_FOLDER' does not exist"
    exit 1
fi

# Create output folder if it doesn't exist
if [ ! -d "$OUTPUT_FOLDER" ]; then
    echo "Creating output folder: $OUTPUT_FOLDER"
    mkdir -p "$OUTPUT_FOLDER"
fi

# Check if exiftool is installed
if ! command -v exiftool &> /dev/null; then
    echo "Error: exiftool is not installed"
    echo "Install it with: brew install exiftool"
    exit 1
fi

# Counter for processed files
count=0
failed=0

echo "Starting conversion..."
echo "Input folder: $INPUT_FOLDER"
echo "Output folder: $OUTPUT_FOLDER"
echo ""

# Process all HEIC files (case insensitive)
shopt -s nocaseglob
for heic_file in "$INPUT_FOLDER"/*.heic; do
    # Check if any HEIC files exist
    if [ ! -e "$heic_file" ]; then
        echo "No HEIC files found in $INPUT_FOLDER"
        break
    fi
    
    # Get the base filename without extension
    filename=$(basename "$heic_file")
    basename_no_ext="${filename%.*}"
    
    # Output JPEG path
    output_file="$OUTPUT_FOLDER/${basename_no_ext}.jpg"
    
    echo "Processing: $filename"
    
    # Convert HEIC to JPEG
    if sips -s format jpeg -s formatOptions best "$heic_file" --out "$output_file" > /dev/null 2>&1; then
        # Remove metadata from the JPEG
        if exiftool -all= -overwrite_original "$output_file" > /dev/null 2>&1; then
            echo "  ✓ Converted and metadata removed: ${basename_no_ext}.jpg"
            ((count++))
        else
            echo "  ✗ Failed to remove metadata from: ${basename_no_ext}.jpg"
            ((failed++))
        fi
    else
        echo "  ✗ Failed to convert: $filename"
        ((failed++))
    fi
done
shopt -u nocaseglob

echo ""
echo "Conversion complete!"
echo "Successfully processed: $count files"
if [ $failed -gt 0 ]; then
    echo "Failed: $failed files"
fi
