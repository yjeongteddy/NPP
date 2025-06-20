#!/bin/bash
#SBATCH -J genB2211
#SBATCH -o genB2211.out
#SBATCH -e genB2211.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node8

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/01_WORK/2025/NPP/08_CRUCIAL')); addpath(genpath('/home/user_006/08_MATLIB')); CreateBogusHINNAMNOR('/home/user_006/01_WORK/2025/NPP/05_DATA/processed','SAEUL','2211_HINNAMNOR'); exit;"
