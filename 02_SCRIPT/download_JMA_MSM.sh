#!/bin/bash

# Target ds
tgt_ds=('MSM-S') # Replace with desired one (P or S)

# Define the base URL
BASE_URL="https://database.rish.kyoto-u.ac.jp/arch/jmadata/data/gpv/netcdf/${tgt_ds}"

# Target TC
tgt_tc=('2211_HINNAMNOR') # Replace with desired typhoon

# Define the years, months, and days you want to navigate
YEARS=(2022) # Replace with desired year

MONTHS_DAYS=(
	"08:27" # Replace with desired date
	"09:07 08 09"
	)

# Directory to save downloaded files
OUTPUT_DIR="/home/user_006/01_WORK/2025/NPP/05_DATA/raw/JMA-${tgt_ds}/${tgt_tc}/" # Replace with desired path
mkdir -p "$OUTPUT_DIR"

# Loop through years, months, and days
for month_days in "${MONTHS_DAYS[@]}"; do
    IFS=':' read -r month days <<< "$month_days"
    for day in $days; do
        # Construct the full URL for the directory
        DIR_URL="$BASE_URL/$YEARS"

        # Generate the target date dynamically
        TARGET_DATE="${month}${day}"

        # Define the target file name
        FILE_NAME="${TARGET_DATE}.nc"

        # Full URL to the target file
        FILE_URL="$DIR_URL/$FILE_NAME"

        # Download the file
        echo "Downloading $FILE_URL..."
        curl -O "$FILE_URL" --output-dir "$OUTPUT_DIR" 2>/dev/null

	# Check if the download was successful
        if [[ $? -eq 0 ]]; then
            echo "Successfully downloaded: $FILE_NAME"
        else
            echo "Failed to download: $FILE_NAME"
        fi
    done
done

echo "Download process completed. Files are saved in $OUTPUT_DIR."

