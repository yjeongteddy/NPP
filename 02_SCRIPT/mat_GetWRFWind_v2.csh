#!/bin/csh
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

chmod u+x mat_GetWRFWind.sh
sbatch mat_GetWRFWind.sh
