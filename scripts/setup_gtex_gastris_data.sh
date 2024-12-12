#!/bin/bash

# Check if the data directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <data_directory>"
    exit 1
fi

DATA_DIR=$1
SCRIPT_DIR=$(dirname "$0")
CSV_FILE="$SCRIPT_DIR/gtex_input.txt"

# Check if the CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "CSV file not found: $CSV_FILE"
    exit 1
fi

# Create the data directory if it doesn't exist
mkdir -p "$DATA_DIR"

# Copy the CSV file to the data directory
cp "$CSV_FILE" "$DATA_DIR/input.csv"

# Read the slide_id column and download the slides in parallel
cat "$CSV_FILE" | awk -F, 'NR>1 {print $1}' | xargs -n 1 -P 4 -I {} sh -c '
    SLIDE_ID="$1"
    DATA_DIR="$2"
    SLIDE_URL="https://brd.nci.nih.gov/brd/imagedownload/$SLIDE_ID"
    echo "Downloading slide: $SLIDE_ID"

    # Download the file with the determined filename
    wget --content-disposition -P "$DATA_DIR" "$SLIDE_URL" || wget -O "$DATA_DIR/$FILENAME" "$SLIDE_URL"
' _ {} "$DATA_DIR"

