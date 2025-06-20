#!/bin/bash

# User inputs or defaults.
SIM_NAME=${1:-"0314_MAEMI"}
JOB_NAME=${SIM_NAME:0:4}
EXPERIMENT=${2:-"SAEUL"}
DATA_DIR=${3:-"/home/user_006/01_WORK/2025/NPP/05_DATA/processed"}
nNum=${4:-"8"}
INTENSIFIER=${5:-"2.62"}

# Create a temporary SLURM script with the correct output file names.
cat > mat_AdjustTranslationSpeed.sh <<EOF
#!/bin/bash
#SBATCH -J adTSMPH${JOB_NAME}
#SBATCH -o adTSMPH${JOB_NAME}.out
#SBATCH -e adTSMPH${JOB_NAME}.err
#SBATCH -N 1
#SBATCH -n 96
#SBATCH -w node${nNum}

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); AdjustTranslationSpeed('${DATA_DIR}','${EXPERIMENT}','${SIM_NAME}','${INTENSIFIER}'); exit;"
EOF

# Make the script executable
chmod u+x mat_AdjustTranslationSpeed.sh

# Submit the temporary script.
sbatch mat_AdjustTranslationSpeed.sh

