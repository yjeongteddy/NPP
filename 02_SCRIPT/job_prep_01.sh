#!/bin/bash
#SBATCH -J DthIntp              # Job name
#SBATCH -o DthIntp.out          # Stdout
#SBATCH -e DthIntp.err          # Stderr
#SBATCH -N 1                    # Number of nodes
#SBATCH -n 96            	# Number of processors
#SBATCH -w node4          # Specific node

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); SaveWRFSetting('1215_BOLAVEN', 'HANBIT', '/home/user_006/01_WORK/2025/NPP/05_DATA/processed', '1.31', 'ADCIRC', '10exL'); load(fullfile('/home/user_006/01_WORK/2025/NPP/05_DATA/processed', 'HANBIT', '1215_BOLAVEN', '12_ADCIRC', 'MIN', '1.31', 'settings.mat')); get_WRF_WIND_robust(setting); exit;"
