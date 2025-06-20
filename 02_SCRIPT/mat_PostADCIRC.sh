#!/bin/bash
#SBATCH -J plot0314_2.03-10
#SBATCH -o plot0314_2.03-10.out
#SBATCH -e plot0314_2.03-10.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node10

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); PostADCIRC('0314_MAEMI', 'SAEUL', '2.03-10', '10exH+SLR', '0%'); exit;"
