#!/bin/bash

#SBATCH -J ncl1.70-102009	# JOB_NAME
#SBATCH -o ncl1.70-102009.out  # JOB_STDOUT
#SBATCH -e ncl1.70-102009.err  # JOB_STDERR
#SBATCH -N 1 		# NODE	
#SBATCH -n 96	# PROC[CPU]
#SBATCH -w node6

export HDF5=/usr/local
export PHDF5=/usr/local
export LD_LIBRARY_PATH=/usr/local//lib:/appl/intel/oneapi/mpi/2021.6.0//libfabric/lib:/appl/intel/oneapi/mpi/2021.6.0//lib/release:/appl/intel/oneapi/mpi/2021.6.0//lib:/appl/intel/oneapi/compiler/2022.1.0/linux/lib:/appl/intel/oneapi/compiler/2022.1.0/linux/lib/x64:/appl/intel/oneapi/compiler/2022.1.0/linux/lib/oclfpga/host/linux64/lib:/appl/intel/oneapi/compiler/2022.1.0/linux/compiler/lib/intel64_lin:$LD_LIBRARY_PATH:/usr/local/lib:/appl/intel/oneapi/mpi/2021.6.0/lib:/appl/intel/oneapi/compiler/2022.1.0/linux/compiler/lib/intel64_lin/:/appl/intel/oneapi/mpi/2021.6.0/lib/
export tgt_dir="/home/user_006/01_WORK/2025/NPP/05_DATA/processed/SAEUL/2009_MAYSAK/09_WRF/1.70-10/"
export LD_LIBRARY_PATH=/appl/intel/oneapi/mpi/2021.6.0//libfabric/lib:/appl/intel/oneapi/mpi/2021.6.0//lib/release:/appl/intel/oneapi/mpi/2021.6.0//lib:/appl/intel/oneapi/compiler/2022.1.0/linux/lib:/appl/intel/oneapi/compiler/2022.1.0/linux/lib/x64:/appl/intel/oneapi/compiler/2022.1.0/linux/lib/oclfpga/host/linux64/lib:/appl/intel/oneapi/compiler/2022.1.0/linux/compiler/lib/intel64_lin:$LD_LIBRARY_PATH:/usr/local/lib:/appl/intel/oneapi/mpi/2021.6.0/lib:/appl/intel/oneapi/compiler/2022.1.0/linux/compiler/lib/intel64_lin/:/appl/intel/oneapi/mpi/2021.6.0/lib/

ncl 'tgt_dir="''"' wrfout_ext.ncl
