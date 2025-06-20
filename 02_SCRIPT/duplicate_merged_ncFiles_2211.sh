#!/bin/bash
#SBATCH -J DplMrgNF_2211      # JOB_NAME
#SBATCH -o DplMrgNF_2211.out  # JOB_STDOUT
#SBATCH -e DplMrgNF_2211.err  # JOB_STDOUT
#SBATCH -N 1          		     # NODE
#SBATCH -n 96         		     # PROC [CPU]
#SBATCH -w node1

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath('/home/user_006/08_MATLIB'); DuplicateMergedNcFile('2211_HINNAMNOR'); "
