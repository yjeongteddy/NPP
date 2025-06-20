cat > job_ncl.sh << EOF
#!/bin/bash

#SBATCH -J ${CASE}	# JOB_NAME
#SBATCH -o ${CASE}.out  # JOB_STDOUT
#SBATCH -e ${CASE}.err  # JOB_STDERR
#SBATCH -N 1 		# NODE	
#SBATCH -n ${NUMN}	# PROC[CPU]
#SBATCH -w node${nNum}

export HDF5=/usr/local
export PHDF5=/usr/local
export LD_LIBRARY_PATH=${HDF5}/lib:${LD_LIBRARY_PATH}
export tgt_dir="${TDIR}"
export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed -e 's|:[^:]*06_MODEL[^:]*||g' -e 's|[^:]*06_MODEL[^:]*:||g' -e 's|[^:]*06_MODEL[^:]*||g')

ncl 'tgt_dir="'$tgt_dir'"' wrfout_ext.ncl
EOF

chmod u+x job_ncl.sh

