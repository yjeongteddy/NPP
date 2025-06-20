#!/bin/bash
tgt_dir="/home/user_006/01_WORK/2025/NPP/05_DATA/processed/HANBIT/1215_BOLAVEN/12_ADCIRC/MIN/1.31"
if [ -d "$tgt_dir" ]; then
        cd "$tgt_dir"
else
        mkdir -p "$tgt_dir"
        cd "$tgt_dir"
fi

[ -L "02_SCRIPT" ] || ln -sf /home/user_006/01_WORK/2025/NPP/02_SCRIPT 02_SCRIPT
[ -L "fort.15.csh" ] || ln -sf 02_SCRIPT/fort.15.csh .
[ -L "spark_adcirc_swan.csh" ] || ln -sf 02_SCRIPT/spark_adcirc_swan.csh .
[ -L "fort.14" ] || ln -sf /home/user_006/01_WORK/2025/NPP/05_DATA/processed/HANBIT/10exL/fort.14 . 
