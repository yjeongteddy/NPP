#!/bin/bash
#SBATCH -J getW1.401215
#SBATCH -o getW1.401215.out
#SBATCH -e getW1.401215.err
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -w node4

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); SaveWRFSetting('1215_BOLAVEN', 'HANBIT', '/home/user_006/01_WORK/2025/NPP/05_DATA/processed', '1.40', 'ADCIRC', '10exL'); load(fullfile('/home/user_006/01_WORK/2025/NPP/05_DATA/processed', 'HANBIT', '1215_BOLAVEN', '12_ADCIRC', 'MIN', '1.40', 'settings.mat')); get_WRF_WIND_robust(setting); exit;"
