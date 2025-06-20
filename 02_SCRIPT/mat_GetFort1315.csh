#!/bin/bash
TGT_TC=${1:-"0314_MAEMI"}
JOB_NAME=${TGT_TC:0:4}
TGT_NPP=${2:-"SAEUL"}
OPATH=${3:-"/home/user_006/01_WORK/2025/NPP"}
INTENSITY=${4:-"2.03"}
adjTS=${5:-""}
TGT_SL=${6:-"10exH+SLR"}
modelDir=${7:-"12_ADCIRC"}
modelName="${modelDir#*_}"
nNum=${8:-"2"}

case "$TGT_SL" in
    "10exH+SLR")
        subdir="MAX"
        ;;
    "10exL")
        subdir="MIN"
        ;;
    "AHHL")
        subdir=""
        ;;
esac

# Create a temporary SLURM script with the correct output file names.
cat > mat_GetFort1315.sh <<EOF
#!/bin/bash
#SBATCH -J getF${INTENSITY}${adjTS}${JOB_NAME}
#SBATCH -o getF${INTENSITY}${adjTS}${JOB_NAME}.out
#SBATCH -e getF${INTENSITY}${adjTS}${JOB_NAME}.err
#SBATCH -N 1
#SBATCH -n 6
#SBATCH -w node${nNum}

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); get_fort1315('${TGT_TC}', '${TGT_NPP}', '${INTENSITY}'); exit;"
EOF

# Make the script executable
chmod u+x mat_GetFort1315.sh

# Submit the temporary script.
sbatch mat_GetFort1315.sh

