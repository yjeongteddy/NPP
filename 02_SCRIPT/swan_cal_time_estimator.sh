#!/bin/bash

opath='/home/user_006/01_WORK/2025/NPP/03_RERUN/SAEUL/'
cd $opath

# Run squeue and store the output in a variable
squeue_output=$(squeue)

# Extract the elapsed times using a regular expression (It should be HH:MM:SS)
ongoing_simls=$(echo "$squeue_output" | awk 'NR>1 {print $3}')
elapsed_times=$(echo "$squeue_output" | awk 'NR>1 {print $6}')

for i in ${#ongoing_simls}; do
	pattern=${ongoing_simls[$i]}
	time_elapsed=${elapsed_times[$i]}

	IFS=: read -r hours minutes seconds <<< "$time_elapsed"
	elapsed_seconds=$((hours * 3600 + minutes * 60 + seconds))
	
	tgt_dir=$(find $opath -type d -name "*$pattern*")
	
	cd $tgt_dir
		
	frst_line=$(grep "Time of computation" PRINT | head -n 1)
	last_line=$(grep "Time of computation" PRINT | tail -n 1)
	
	frst_date=$(echo "$frst_line" | awk '{print $5}')
	last_date=$(echo "$last_line" | awk '{print $5}')
	last_epch=$(echo "$last_line" | awk '{print $8}')
	
	average_time_per_epoch=$((elapsed_seconds / last_epoch))
	
	last_wind_name=$(tail -1 WIND_NAMES.dat)
	tgt_date=$(echo "$last_wind_name" | sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})_([0-9]{2})\.dat/\1\2\3.\40000/')
	
	frst_date_epoch=$(date -d "${frst_date:0:8} ${frst_date:9:2}:${frst_date:11:2}:${frst_date:13:2}" +%s)
	last_date_epoch=$(date -d "${last_date:0:8} ${last_date:9:2}:${last_date:11:2}:${last_date:13:2}" +%s)
	tgt_date_epoch=$(date -d "${tgt_date:0:8} ${tgt_date:9:2}:${tgt_date:11:2}:${tgt_date:13:2}" +%s)
	
	remaining_seconds=$((tgt_date_epoch - last_date_epoch))
	
	epoch_length=600
	remaining_epochs=$((remaining_seconds / epoch_length))
	
	total_seconds_left=$((average_time_per_epoch * remaining_epochs))
	
	minutes_left=$((total_seconds_left / 60))
	
	echo "Estimated time left ($tgt_dir): $minutes_left minutes"
	
	cd ..
done





