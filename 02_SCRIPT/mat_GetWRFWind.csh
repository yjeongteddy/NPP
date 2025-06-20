#!/bin/bash
TGT_TC=${1:-"1215_BOLAVEN"}
JOB_NAME=${TGT_TC:0:4}
TGT_NPP=${2:-"HANBIT"}
OPATH=${3:-"/home/user_006/01_WORK/2025/NPP/05_DATA/processed"}
INTENSITY=${4:-"1.40"}
TGT_SL=${6:-"10exL"}
modelDir=${7:-"12_ADCIRC"}
modelName="${modelDir#*_}"
nNum=${8:-"4"}

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
cat > mat_GetWRFWind.sh <<EOF
#!/bin/bash
#SBATCH -J getW${INTENSITY}${JOB_NAME}
#SBATCH -o getW${INTENSITY}${JOB_NAME}.out
#SBATCH -e getW${INTENSITY}${JOB_NAME}.err
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -w node${nNum}

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); SaveWRFSetting('${TGT_TC}', '${TGT_NPP}', '${OPATH}', '${INTENSITY}', '${modelName}', '${TGT_SL}'); load(fullfile('${OPATH}', '${TGT_NPP}', '${TGT_TC}', '${modelDir}', '${subdir}', '${INTENSITY}', 'settings.mat')); get_WRF_WIND_robust(setting); exit;"
EOF

# Make the script executable
chmod u+x mat_GetWRFWind.sh

# Submit the temporary script.
sbatch mat_GetWRFWind.sh

