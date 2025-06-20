#!/bin/bash
#SBATCH -J extWJMA2211
#SBATCH -o extWJMA2211.out
#SBATCH -e extWJMA2211.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node10

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); SaveJMASetting('2211_HINNAMNOR', 'SAEUL', '/home/user_006/01_WORK/2025/NPP/05_DATA/processed'); load(fullfile('/home/user_006/01_WORK/2025/NPP/05_DATA/processed', 'SAEUL', '2211_HINNAMNOR', '11_JMA', 'settings.mat')); get_JMA_WIND_robust(setting); exit;"
