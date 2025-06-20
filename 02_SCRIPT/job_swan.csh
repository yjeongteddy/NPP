#!/bin/csh
cat > job_swan.sh << EOF
#!/bin/bash
#SBATCH -J ${CASE}        # JOB_NAME
#SBATCH -o ${CASE}.out    # JOB_STDOUT
#SBATCH -e ${CASE}.err    # JOB_STDOUT
#SBATCH -N 1   		  # NODE
#SBATCH -n 96  		  # PROC[CPU]
#SBATCH -w node7

export OMP_NUM_THREADS=96
./swan.exe

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath(genpath('/home/user_006/08_MATLIB')); create_wave_ds_robust('.'); exit;"
EOF

chmod u+x job_swan.sh
