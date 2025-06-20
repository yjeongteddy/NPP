#!/bin/bash
#SBATCH -J 2211prep_WSUP
#SBATCH -o 2211prep_WSUP.out
#SBATCH -e 2211prep_WSUP.err
#SBATCH -N 1
#SBATCH -n 12

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); GetDepthSetup('2211_HINNAMNOR', 'SAEUL', '10exL'); GetWindSetup('2211_HINNAMNOR', 'SAEUL', '10exL'); PrepWaveSetup_v2('2211_HINNAMNOR', 'SAEUL', '10exL'); exit;"
