#!/bin/bash

# Check if the data directory parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <data_dir>"
    exit 1
fi

DATA_DIR=$1
URL="https://openslide.cs.cmu.edu/download/openslide-testdata/Aperio/CMU-1-Small-Region.svs"

# Create the data directory if it doesn't exist
mkdir -p "$DATA_DIR"
if [ ! -f "$DATA_DIR/sample_1.svs" ]; then
    # Download the file and rename it to sample_1.svs
    echo "Downloading sample file..."
    wget -O "$DATA_DIR/sample_1.svs" "$URL"
else
    echo "Data files already exist. Skipping download."
fi

# Duplicate the file
cp "$DATA_DIR/sample_1.svs" "$DATA_DIR/sample_2.svs"

# Create the input.csv file
cat <<EOL > "$DATA_DIR/input.csv"
slide,feature1,feature2
sample_1.svs,1,a
sample_2.svs,2,b
EOL

echo "Setup complete. Files are in $DATA_DIR"