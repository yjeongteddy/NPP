#!/bin/bash
TGT_TC=${1:-"1215_BOLAVEN"}
INTENSITY=${2:-"1.31"}
TGT_NPP=${3:-"HANBIT"}
TGT_SL=${4:-"10exL"}
OPATH=${5:-"/home/user_006/01_WORK/2025/NPP/05_DATA/processed"}
nNum=${6:-"4"}

case "$TGT_SL" in
    "10exH+SLR")
        subdir="MAX"
        ;;
    "10exL")
        subdir="MIN"
        ;;
    "AHHL")
        subdir=""
        ;;
esac

cat > prep_WRF_ADCIRC.sh << EOF
#!/bin/bash
tgt_dir="/home/user_006/01_WORK/2025/NPP/05_DATA/processed/${TGT_NPP}/${TGT_TC}/12_ADCIRC/$subdir/${INTENSITY}"
if [ -d "\$tgt_dir" ]; then
        cd "\$tgt_dir"
else
        mkdir -p "\$tgt_dir"
        cd "\$tgt_dir"
fi

[ -L "02_SCRIPT" ] || ln -sf /home/user_006/01_WORK/2025/NPP/02_SCRIPT 02_SCRIPT
[ -L "fort.15.csh" ] || ln -sf 02_SCRIPT/fort.15.csh .
[ -L "spark_adcirc_swan.csh" ] || ln -sf 02_SCRIPT/spark_adcirc_swan.csh .
[ -L "fort.14" ] || ln -sf /home/user_006/01_WORK/2025/NPP/05_DATA/processed/${TGT_NPP}/${TGT_SL}/fort.14 . 
EOF
chmod u+x prep_WRF_ADCIRC.sh
./prep_WRF_ADCIRC.sh

cat > job_prep_01.sh << EOF
#!/bin/bash
#SBATCH -J DthIntp              # Job name
#SBATCH -o DthIntp.out          # Stdout
#SBATCH -e DthIntp.err          # Stderr
#SBATCH -N 1                    # Number of nodes
#SBATCH -n 96            	# Number of processors
#SBATCH -w node${nNum}          # Specific node

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "\
addpath(genpath('/home/user_006/08_MATLIB')); \
SaveWRFSetting('${TGT_TC}', '${TGT_NPP}', '${OPATH}', '${INTENSITY}', 'ADCIRC', '${TGT_SL}'); \
load(fullfile('${OPATH}', '${TGT_NPP}', '${TGT_TC}', '12_ADCIRC', '${subdir}', '${INTENSITY}', 'settings.mat')); \
get_WRF_WIND_robust(setting); exit;"
EOF
chmod u+x job_prep_01.sh

cat > job_prep_02.sh << EOF
#!/bin/bash
#SBATCH -J gf1315              # Job name
#SBATCH -o gf1315.out          # Stdout
#SBATCH -e gf1315.err          # Stderr
#SBATCH -N 1                    # Number of nodes
#SBATCH -n 96	                # Number of processors
#SBATCH -w node${nNum}          # Specific node

/appl/MATLAB/R2022a/bin/matlab -nodesktop -nodisplay -nosplash -r "\
addpath(genpath('/home/user_006/08_MATLIB')); \
get_fort1315('${TGT_TC}', '${TGT_NPP}', '${INTENSITY}', '${TGT_SL}', '${nNum}'); exit;"
EOF
chmod u+x job_prep_02.sh

scripts=(job_prep_01.sh job_prep_02.sh)

for script in "${scripts[@]}"
do
    sbatch "$script"
done

