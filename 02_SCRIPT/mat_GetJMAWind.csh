#!/bin/bash

# User inputs or defaults.
TGT_TC=${1:-"2211_HINNAMNOR"}
JOB_NAME=${TGT_TC:0:4}
TGT_NPP=${2:-"SAEUL"}
OPATH=${3:-"/home/user_006/01_WORK/2025/NPP/05_DATA/processed"}
nNum=${5:-"10"}

# Create a temporary SLURM script with the correct output file names.
cat > mat_GetJMAWind.sh <<EOF
#!/bin/bash
#SBATCH -J extWJMA${JOB_NAME}
#SBATCH -o extWJMA${JOB_NAME}.out
#SBATCH -e extWJMA${JOB_NAME}.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node${nNum}

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); SaveJMASetting('${TGT_TC}', '${TGT_NPP}', '${OPATH}'); load(fullfile('${OPATH}', '${TGT_NPP}', '${TGT_TC}', '11_JMA', 'settings.mat')); get_JMA_WIND_robust(setting); exit;"
EOF

# Make the script executable
chmod u+x mat_GetJMAWind.sh

# Submit the temporary script.
sbatch mat_GetJMAWind.sh

