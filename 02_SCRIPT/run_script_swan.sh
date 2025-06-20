#!/bin/bash
export start_date=20030906.060000
export end_date=20030913.170000
export CASE=RS031412 # Run SWAN 0314 1.2
export nNum=1

./INPUT.csh
./job.csh
sbatch job.sh
