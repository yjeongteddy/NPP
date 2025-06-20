#!/bin/bash
#SBATCH -J plot2211_1.50+10
#SBATCH -o plot2211_1.50+10.out
#SBATCH -e plot2211_1.50+10.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node1

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); PostSWAN('2211_HINNAMNOR', 'SAEUL', '1.50+10', '10exL', '29%'); exit;"
