#!/bin/bash
#SBATCH -J getF2.030314
#SBATCH -o getF2.030314.out
#SBATCH -e getF2.030314.err
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -w node2

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); get_fort1315('0314_MAEMI', 'SAEUL', '2.03'); exit;"
