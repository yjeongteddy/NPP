#!/bin/bash
export CASE=ncl1.70-102009
export NUMN=96
export TDIR=/home/user_006/01_WORK/2025/NPP/05_DATA/processed/SAEUL/2009_MAYSAK/09_WRF/1.70-10/
export nNum=6
./job_ncl.csh
sbatch job_ncl.sh
