#!/bin/bash
#SBATCH -J ch0314Hs   	# JOB_NAME
#SBATCH -o ch0314Hs.out # JOB_STDOUT
#SBATCH -e ch0314Hs.err # JOB_STDOUT
#SBATCH -N 1          	# NODE
#SBATCH -n 96         	# PROC [CPU]
#SBATCH -w node10

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "run('/home/user_006/01_WORK/2025/NPP/01_CODE/check_0314_Hs.m')"
