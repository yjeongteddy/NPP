#!/bin/bash
#SBATCH -J mrgeGMSM_2009
#SBATCH -o mrgeGMSM_2009.out
#SBATCH -e mrgeGMSM_2009.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node7

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); mergeGSMData('2009_MAYSAK','SAEUL','/home/user_006/01_WORK/2025/NPP/05_DATA/'); exit;"
