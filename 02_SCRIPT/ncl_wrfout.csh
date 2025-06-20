#!/bin/bash
TGT_TC=${1:-"2009_MAYSAK"}
JOB_NAME=${TGT_TC:0:4}
TGT_NPP=${2:-"SAEUL"}
INTENSITY=${3:-"1.70"}
OPATH=${4:-"/home/user_006/01_WORK/2025/NPP/05_DATA/processed"}
adjTS=${5:-"-10"}
nNum=${6:-"6"}

cat > ncl_wrfout.sh <<EOF
#!/bin/bash
export CASE=ncl${INTENSITY}${adjTS}${JOB_NAME}
export NUMN=96
export TDIR=/home/user_006/01_WORK/2025/NPP/05_DATA/processed/${TGT_NPP}/${TGT_TC}/09_WRF/${INTENSITY}${adjTS}/
export nNum=${nNum}
./job_ncl.csh
sbatch job_ncl.sh
EOF

chmod u+x ncl_wrfout.sh 

./ncl_wrfout.sh
