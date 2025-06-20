#!/bin/csh

# Define common paths
set script_base = /home/user_006/01_WORK/2025/NPP/02_SCRIPT
set matlab_base = /appl/MATLAB/R2022a/bin/matlab
set matlib_path = /home/user_006/08_MATLIB
set current_time = "`date`"

cat > job.sh << EOF
#!/bin/bash
#SBATCH -J ${JOB_NAME}          # Job name
#SBATCH -o ${JOB_NAME}.out      # Stdout
#SBATCH -e ${JOB_NAME}.err      # Stderr
#SBATCH -N 1                    # Number of nodes
#SBATCH -n ${NPROCS}            # Number of processors
#SBATCH -w node${nNum}          # Specific node

# Export environment variables
export TC_INFO=${TC_INFO}
export RNDAY=${RNDAY}
export JOB_NAME=${JOB_NAME}
export TC_NUM=${TC_NUM}
export NPROCS=${NPROCS}
export ADCIRC_PATH=${ADCIRC_PATH}
export nNum=${nNum}
export TGT_TC=${TGT_TC}
export TGT_NPP=${TGT_NPP}
export INTENSITY=${INTENSITY}
export TGT_SL=${TGT_SL}
export subdir=${subdir}
export OPATH=${OPATH}

echo "[$current_time] job.sh successfully created" > job.log

# Run ADCIRC preprocessing
echo "Running adcprep" >> job.log
printf "${NPROCS}\\n1\\nfort.14\\n" | ${ADCIRC_PATH}/adcprep
printf "${NPROCS}\\n2\\n" | ${ADCIRC_PATH}/adcprep

# Run ADCIRC
cd ${OPATH}/${TGT_NPP}/${TGT_TC}/12_ADCIRC/$subdir/${INTENSITY}
echo "Running padcirc_BDY" >> job.log
mpiexec.hydra -np ${NPROCS} ${ADCIRC_PATH}/padcirc_BDY

# Post-process results using MATLAB
#echo "Post-processing SSH results" >> job.log
#${matlab_base} -nodesktop -nodisplay -nosplash -r "\
#addpath(genpath('${matlib_path}')); \
#if strcmp('${subdir}', 'MIN'), func = @get_minSSH; else, func = @get_maxSSH; end; \
#func('${TGT_TC}', '${TGT_NPP}', '${INTENSITY}', '${TGT_SL}'); exit;"

# Redefine Sea Level
#echo "Running AddSSH" >> job.log
#${matlab_base} -nodesktop -nodisplay -nosplash -r "\
#addpath(genpath('${matlib_path}')); \
#AddSSH('${TGT_TC}', '${TGT_NPP}', '${INTENSITY}', '${TGT_SL}'); exit;"

# Prep SWAN input
#echo "Prepping SWAN" >> job.log
#cd ${OPATH}/${TGT_NPP}/${TGT_TC}/10_SWAN/$subdir/${INTENSITY}
#source ${script_base}/prep_WRF_SWAN_v2.csh
#${matlab_base} -nodesktop -nodisplay -nosplash -r "\
#addpath(genpath('${matlib_path}')); \
#SaveWRFSetting('${TGT_TC}', '${TGT_NPP}', '${OPATH}', '${INTENSITY}', 'SWAN', '${TGT_SL}'); \
#load(fullfile('${OPATH}', '${TGT_NPP}', '${TGT_TC}', '10_SWAN', '${subdir}', '${INTENSITY}', 'settings.mat')); \
#get_WRF_WIND_robust(setting); exit;"

# Run SWAN model
#echo "Running SWAN" >> job.log
#source ${script_base}/run_script_swan_v2.csh
EOF

chmod u+x job.sh

