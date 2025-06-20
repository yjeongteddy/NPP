#!/bin/bash

# User inputs or defaults.
SIM_NAME=${1:-"2009_MAYSAK"}
JOB_NAME=${SIM_NAME:0:4}
EXPERIMENT=${2:-"SAEUL"}
DATA_DIR=${3:-"/home/user_006/01_WORK/2025/NPP/05_DATA/processed"}
nNum=${4:-"4"}
INTENSIFIER=${5:-"1.70"}
INT_INC=${6:-"29%"}
TS_INC=${7:-"0%"}

# Create a temporary SLURM script with the correct output file names.
cat > mat_PostWRF.sh <<EOF
#!/bin/bash
#SBATCH -J plot${JOB_NAME}_${INTENSIFIER}
#SBATCH -o plot${JOB_NAME}_${INTENSIFIER}.out
#SBATCH -e plot${JOB_NAME}_${INTENSIFIER}.err
#SBATCH -N 1
#SBATCH -n 96

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); PostWRF('${SIM_NAME}', '${EXPERIMENT}', '${INTENSIFIER}', '${INT_INC}', '${TS_INC}'); exit;"
EOF

# Make the script executable
chmod u+x mat_PostWRF.sh

# Submit the temporary script.
sbatch mat_PostWRF.sh

