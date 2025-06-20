#!/bin/bash

# Define the base URL
BASE_URL="https://database.rish.kyoto-u.ac.jp/arch/jmadata/data/gpv/original"

# Target TC
tgt_tc=('2211_HINNAMNOR')

# Define the years, months, and days you want to navigate
YEARS=(2022) # Replace with desired year

MONTHS_DAYS=(
	"08:28 29 30 31" # Replace with desired date
	"09:01 02 03 04 05 06"
	)

HOURS=('000000' '060000' '120000' '180000')

# Directory to save downloaded files
OUTPUT_DIR="/home/user_006/01_WORK/2025/NPP/05_DATA/raw/JMA-GSM/${tgt_tc}/" # Replace with desired path
mkdir -p "$OUTPUT_DIR"

# Loop through years, months, and days
for month_days in "${MONTHS_DAYS[@]}"; do
    IFS=':' read -r month days <<< "$month_days"
    for day in $days; do
	for hour in "${HOURS[@]}"; do
            # Construct the full URL for the directory
            DIR_URL="$BASE_URL/$YEARS/$month/$day"

            # Generate the target date dynamically
            TARGET_DATE="${YEARS}${month}${day}${hour}"

            # Define the target file name
            FILE_NAME="Z__C_RJTD_${TARGET_DATE}_GSM_GPV_Rgl_FD0000_grib2.bin"

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
done

echo "Download process completed. Files are saved in $OUTPUT_DIR."

