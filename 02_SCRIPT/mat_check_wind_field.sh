#!/bin/bash
#SBATCH -J DplMrgNF   	# JOB_NAME
#SBATCH -o DplMrgNF.out # JOB_STDOUT
#SBATCH -e DplMrgNF.err # JOB_STDOUT
#SBATCH -N 1          	# NODE
#SBATCH -n 48         	# PROC [CPU]

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "run('/home/user_006/01_WORK/2025/NPP/01_CODE/check_wind_field.m')"
