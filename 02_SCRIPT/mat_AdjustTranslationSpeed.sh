#!/bin/bash
#SBATCH -J adTSMPH0314
#SBATCH -o adTSMPH0314.out
#SBATCH -e adTSMPH0314.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node8

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); AdjustTranslationSpeed('/home/user_006/01_WORK/2025/NPP/05_DATA/processed','SAEUL','0314_MAEMI','2.62'); exit;"
