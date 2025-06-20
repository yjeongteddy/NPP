#!/bin/bash
TGT_TC=${1:-"2211_HINNAMNOR"}
JOB_NAME=${TGT_TC:0:4}
TGT_NPP=${2:-"SAEUL"}
TGT_SL=${3:-"10exL"}
nNum=${4:-"10"}

# Create a temporary SLURM script with the correct output file names.
cat > mat_PrepWaveSetup.sh <<EOF
#!/bin/bash
#SBATCH -J ${JOB_NAME}prep_WSUP
#SBATCH -o ${JOB_NAME}prep_WSUP.out
#SBATCH -e ${JOB_NAME}prep_WSUP.err
#SBATCH -N 1
#SBATCH -n 12

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); GetDepthSetup('${TGT_TC}', '${TGT_NPP}', '${TGT_SL}'); GetWindSetup('${TGT_TC}', '${TGT_NPP}', '${TGT_SL}'); PrepWaveSetup_v2('${TGT_TC}', '${TGT_NPP}', '${TGT_SL}'); exit;"
EOF

# Make the script executable
chmod u+x mat_PrepWaveSetup.sh

# Submit the temporary script.
sbatch mat_PrepWaveSetup.sh

