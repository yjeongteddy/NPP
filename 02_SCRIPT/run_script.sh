#!/bin/sh
#SBATCH -J NARI         # JOB_NAME
#SBATCH -o NARI.out     # JOB_STDOUT
#SBATCH -e NARI.err     # JOB_STDOUT
#SBATCH -N 1                    # NODE
#SBATCH -n 96                   # PROC[CPU]

# COPY METGRID FILE
 #cp ../../../copy_script.sh ./
 #./copy_script.sh

# MAKE DECOMPOSITION SCRIPT
#cp ../../../*.so ./
#cp ../../../*filter*.csh ./
#/appl/MATLAB/R2022a/bin/matlab  -nodesktop -nodisplay -nosplash -r "run('make_filter_script.m')"

# RUN SCRIPT
pattern="run_decomp*.sh"
files=$(find . -maxdepth 1 -type f -name "$pattern")
export HDF5=/usr/local
export PHDF5=/usr/local
export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed -e 's|:[^:]*WRF_TEST[^:]*||g' -e 's|[^:]*WRF_TEST[^:]*:||g' -e 's|[^:]*WRF_TEST[^:]*||g')

chmod +x run_decom*
for file in $files; do
    echo "실행 중: $file"
    bash "$file"
done

