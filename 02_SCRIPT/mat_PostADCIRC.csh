#!/bin/bash

# User inputs or defaults.
SIM_NAME=${1:-"0314_MAEMI"}
JOB_NAME=${SIM_NAME:0:4}
EXPERIMENT=${2:-"SAEUL"}
DATA_DIR=${3:-"/home/user_006/01_WORK/2025/NPP/05_DATA/processed"}
nNum=${4:-"10"}
INTENSIFIER=${5:-"2.03-10"}
INT_INC=${6:-"0%"}
TGT_SL=${7:-"10exH+SLR"}

# Create a temporary SLURM script with the correct output file names.
cat > mat_PostADCIRC.sh <<EOF
#!/bin/bash
#SBATCH -J plot${JOB_NAME}_${INTENSIFIER}
#SBATCH -o plot${JOB_NAME}_${INTENSIFIER}.out
#SBATCH -e plot${JOB_NAME}_${INTENSIFIER}.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node${nNum}

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); PostADCIRC('${SIM_NAME}', '${EXPERIMENT}', '${INTENSIFIER}', '${TGT_SL}', '${INT_INC}'); exit;"
EOF

# Make the script executable
chmod u+x mat_PostADCIRC.sh

# Submit the temporary script.
sbatch mat_PostADCIRC.sh

