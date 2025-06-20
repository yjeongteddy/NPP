#!/bin/bash
#SBATCH -J getMSSH_2.03
#SBATCH -o getMSSH_2.03.out
#SBATCH -e getMSSH_2.03.err
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -w node2

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); get_maxSSH('0314_MAEMI', 'SAEUL', '2.03', '10exH+SLR'); exit;"
