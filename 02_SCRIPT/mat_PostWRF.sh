#!/bin/bash
#SBATCH -J plot2009_1.70
#SBATCH -o plot2009_1.70.out
#SBATCH -e plot2009_1.70.err
#SBATCH -N 1
#SBATCH -n 96

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); PostWRF('2009_MAYSAK', 'SAEUL', '1.70', '29%', '0%'); exit;"
