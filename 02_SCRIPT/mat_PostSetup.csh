#!/bin/bash
TGT_TC=${1:-"2211_HINNAMNOR"}
TC_SID=${TGT_TC:0:4} 
TGT_NPP=${2:-"SAEUL"}
INTENSITY=${3:-"1.50+10"}
INT_INC=${4:-"29%"}
RPATH=${3:-"/home/user_006/01_WORK/2025/NPP"}
nNum=${4:-"8"}

# Create a temporary SLURM script with the correct output file names.
cat > mat_PostSetup.sh <<EOF
#!/bin/bash
#SBATCH -J plot${TC_SID}
#SBATCH -o plot${TC_SID}.out
#SBATCH -e plot${TC_SID}.err
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -w node${nNum}

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); PostSetup('${TGT_TC}', '${TGT_NPP}', '${INTENSITY}', '${INT_INC}', '${RPATH}'); exit;"
EOF

# Make the script executable
chmod u+x mat_PostSetup.sh

# Submit the temporary script.
sbatch mat_PostSetup.sh

