#!/bin/bash

# User inputs or defaults.
SIM_NAME=${1:-"2009_MAYSAK"}
JOB_NAME=${SIM_NAME:0:4}
EXPERIMENT=${2:-"SAEUL"}
DATA_DIR=${3:-"/home/user_006/01_WORK/2025/NPP/05_DATA/"}
nNum=${4:-"7"}

# Create a temporary SLURM script with the correct output file names.
cat > mat_mergeGSMData.sh <<EOF
#!/bin/bash
#SBATCH -J mrgeGMSM_${JOB_NAME}
#SBATCH -o mrgeGMSM_${JOB_NAME}.out
#SBATCH -e mrgeGMSM_${JOB_NAME}.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node${nNum}

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); mergeGSMData('${SIM_NAME}','${EXPERIMENT}','${DATA_DIR}'); exit;"
EOF

# Make the script executable
chmod u+x mat_mergeGSMData.sh

# Submit the temporary script.
sbatch mat_mergeGSMData.sh

