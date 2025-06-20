#!/bin/bash
#SBATCH -J gf1315              # Job name
#SBATCH -o gf1315.out          # Stdout
#SBATCH -e gf1315.err          # Stderr
#SBATCH -N 1                    # Number of nodes
#SBATCH -n 96	                # Number of processors
#SBATCH -w node4          # Specific node

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); get_fort1315('1215_BOLAVEN', 'HANBIT', '1.31', '10exL', '4'); exit;"
