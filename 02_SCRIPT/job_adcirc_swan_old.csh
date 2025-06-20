#!/bin/csh
cat > job.sh << EOF
#!/bin/bash
#SBATCH -J ${JOB_NAME}        # JOB_NAME
#SBATCH -o ${JOB_NAME}.out    # JOB_STDOUT
#SBATCH -e ${JOB_NAME}.err    # JOB_STDOUT
#SBATCH -N 1   		     # NODE
#SBATCH -n ${NPROCS} 	     # PROC[CPU]
#SBATCH -w node${nNum}

# Run ADCIRC
printf ${NPROCS}'\n1\nfort.14\n' | ${ADCIRC_PATH}/adcprep
printf ${NPROCS}'\n2\n' | ${ADCIRC_PATH}/adcprep
mpiexec.hydra -np ${NPROCS} ${ADCIRC_PATH}/padcirc_BDY

# Post-process
/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "\
addpath(genpath('/home/user_006/08_MATLIB')); \
func = '${subdir}' == 'MIN' ? @get_minSSH : @get_maxSSH; \
func('${TGT_TC}', '${TGT_NPP}', '${INTENSITY}', '${TGT_SL}');"

# Redefine Sea Level
/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); AddSSH('${TGT_TC}', '${TGT_NPP}', '${INTENSITY}', '${TGT_SL}');"

# Prep running SWAN
source ./home/user_006/01_WORK/2025/NPP/02_SCRIPT/prep_WRF_SWAN_v2.csh
set modelDir = '10_SWAN'
set modelName = 'SWAN'
source ./home/user_006/01_WORK/2025/NPP/02_SCRIPT/mat_GetWRFWind_v2.csh 

# Run SWAN
set tgt_case = '{JOB_NAME}_MPP'
source ./home/user_006/01_WORK/2025/NPP/02_SCRIPT/run_script_swan_v2.csh
EOF

chmod u+x job.sh
