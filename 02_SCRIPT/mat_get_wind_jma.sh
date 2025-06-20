#!/bin/bash
#SBATCH -J getJWIND   	# JOB_NAME
#SBATCH -o getJWIND.out # JOB_STDOUT
#SBATCH -e getJWIND.err # JOB_STDOUT
#SBATCH -N 1          	# NODE
#SBATCH -n 12         	# PROC [CPU]
#SBATCH -w node1        # NODE SPECIFICATION
/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "run('/home/user_006/01_WORK/2025/NPP/01_CODE/get_wind_jma.m')"
