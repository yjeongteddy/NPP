#!/bin/bash
tgt_dir="/home/user_006/01_WORK/2025/NPP/05_DATA/processed/SAEUL/0314_MAEMI/09_WRF/2.03-10"
if [ -d "$tgt_dir" ]; then
        cd "$tgt_dir"
else
        mkdir -p "$tgt_dir"
fi
ln -sf /home/user_006/04_CODE/library/BASE_WRF BASE_WRF
ln -sf BASE_WRF/* .
[ -e namelist.input ] && rm -f namelist.input
[ -e job.sh ] && rm -f job.sh
[ -e longitude.dat ] && rm -f longitude.dat
[ -e latitude.dat ] && rm -f latitude.dat

ln -sf /home/user_006/01_WORK/2025/NPP/05_DATA/processed/SAEUL/0314_MAEMI/08_BOGUS/2.03-10 2.03-10
ln -sf 2.03-10/merge*.nc .
