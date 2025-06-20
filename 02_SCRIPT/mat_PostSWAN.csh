#!/bin/bash
SIM_NAME=${1:-"2211_HINNAMNOR"}
JOB_NAME=${SIM_NAME:0:4}
EXPERIMENT=${2:-"SAEUL"}
DATA_DIR=${3:-"/home/user_006/01_WORK/2025/NPP/05_DATA/processed"}
nNum=${4:-"1"}
INTENSIFIER=${5:-"1.50+10"}
INT_INC=${6:-"29%"}
TGT_SL=${7:-"10exL"}

# Create a temporary SLURM script with the correct output file names.
cat > mat_PostSWAN.sh <<EOF
#!/bin/bash
#SBATCH -J plot${JOB_NAME}_${INTENSIFIER}
#SBATCH -o plot${JOB_NAME}_${INTENSIFIER}.out
#SBATCH -e plot${JOB_NAME}_${INTENSIFIER}.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node${nNum}

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); PostSWAN('${SIM_NAME}', '${EXPERIMENT}', '${INTENSIFIER}', '${TGT_SL}', '${INT_INC}'); exit;"
EOF

# Make the script executable
chmod u+x mat_PostSWAN.sh

# Submit the temporary script.
sbatch mat_PostSWAN.sh

