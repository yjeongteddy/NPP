#!/bin/bash
#SBATCH -J genB0314
#SBATCH -o genB0314.out
#SBATCH -e genB0314.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node10

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); CreateBogusTc('/home/user_006/01_WORK/2025/NPP/05_DATA/processed','SAEUL','0314_MAEMI',2.03); exit;"
