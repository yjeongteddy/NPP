#!/bin/bash
TC_NAME=${1:-"2211_HINNAMNOR"}
JOB_NAME=${TC_NAME:0:4}
nNum=${2:-"1"}

cat > duplicate_merged_ncFiles_${JOB_NAME}.sh <<EOF
#!/bin/bash
#SBATCH -J DplMrgNF_${JOB_NAME}      # JOB_NAME
#SBATCH -o DplMrgNF_${JOB_NAME}.out  # JOB_STDOUT
#SBATCH -e DplMrgNF_${JOB_NAME}.err  # JOB_STDOUT
#SBATCH -N 1          		     # NODE
#SBATCH -n 96         		     # PROC [CPU]
#SBATCH -w node${nNum}

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "addpath('/home/user_006/08_MATLIB'); DuplicateMergedNcFile('${TC_NAME}'); "
EOF

# Make the script executable
chmod u+x duplicate_merged_ncFiles_${JOB_NAME}.sh

# Submit the temporary script.
sbatch duplicate_merged_ncFiles_${JOB_NAME}.sh

