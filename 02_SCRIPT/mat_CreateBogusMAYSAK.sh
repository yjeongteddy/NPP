#!/bin/bash
#SBATCH -J genB2009
#SBATCH -o genB2009.out
#SBATCH -e genB2009.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node9

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/01_WORK/2025/NPP/08_CRUCIAL')); addpath(genpath('/home/user_006/08_MATLIB')); CreateBogusMAYSAK('/home/user_006/01_WORK/2025/NPP/05_DATA/processed','SAEUL','2009_MAYSAK'); exit;"
