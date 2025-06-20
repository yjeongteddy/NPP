#!/bin/csh
cat > job.sh << EOF
#!/bin/bash
#SBATCH -J ${JOB_NAME}        # JOB_NAME
#SBATCH -o ${JOB_NAME}.out    # JOB_STDOUT
#SBATCH -e ${JOB_NAME}.err    # JOB_STDOUT
#SBATCH -N 1   		     # NODE
#SBATCH -n ${NPROCS} 	     # PROC[CPU]
#SBATCH -w node${nNum}

printf ${NPROCS}'\n1\nfort.14\n' | ${ADCIRC_PATH}/adcprep
printf ${NPROCS}'\n2\n' | ${ADCIRC_PATH}/adcprep
mpiexec.hydra -np ${NPROCS} ${ADCIRC_PATH}/padcirc_BDY
EOF

chmod u+x job.sh
