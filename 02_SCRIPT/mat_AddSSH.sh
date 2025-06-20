#!/bin/bash
#SBATCH -J AddSSH2211_1.50+10
#SBATCH -o AddSSH2211_1.50+10.out
#SBATCH -e AddSSH2211_1.50+10.err
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -w node1

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); AddSSH('2211_HINNAMNOR', 'SAEUL', '1.50+10', '10exL'); exit;"
