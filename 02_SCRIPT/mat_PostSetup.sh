#!/bin/bash
#SBATCH -J plot2211
#SBATCH -o plot2211.out
#SBATCH -e plot2211.err
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -w node8

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); PostSetup('2211_HINNAMNOR', 'SAEUL', '1.50+10', '29%', '/home/user_006/01_WORK/2025/NPP'); exit;"
