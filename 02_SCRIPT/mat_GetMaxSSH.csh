#!/bin/bash

# User inputs or defaults.
TGT_TC=${1:-"0314_MAEMI"}
TC_SID=${SIM_NAME:0:4}
TGT_NPP=${2:-"SAEUL"}
RPATH=${3:-"/home/user_006/01_WORK/2025/NPP/05_DATA/processed"}
nNum=${4:-"2"}
INTENSITY=${5:-"2.03"}
TGT_SL=${7:-"10exH+SLR"}

# Create a temporary SLURM script with the correct output file names.
cat > mat_GetMaxSSH.sh <<EOF
#!/bin/bash
#SBATCH -J getMSSH${TC_SID}_${INTENSITY}
#SBATCH -o getMSSH${TC_SID}_${INTENSITY}.out
#SBATCH -e getMSSH${TC_SID}_${INTENSITY}.err
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -w node${nNum}

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); get_maxSSH('${TGT_TC}', '${TGT_NPP}', '${INTENSITY}', '${TGT_SL}'); exit;"
EOF

# Make the script executable
chmod u+x mat_GetMaxSSH.sh

# Submit the temporary script.
sbatch mat_GetMaxSSH.sh

