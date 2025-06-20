#!/bin/bash
TGT_TC=${1:-"0314_MAEMI"}
STRENGTHEN=${2:-"2.03"}
TGT_NPP=${3:-"SAEUL"}
AdjTS=${4:-"-10"}

cat > prep_run_WRF.sh << EOF
#!/bin/bash
tgt_dir="/home/user_006/01_WORK/2025/NPP/05_DATA/processed/${TGT_NPP}/${TGT_TC}/09_WRF/${STRENGTHEN}${AdjTS}"
if [ -d "\$tgt_dir" ]; then
        cd "\$tgt_dir"
else
        mkdir -p "\$tgt_dir"
	cd "\$tgt_dir"
fi
ln -sf /home/user_006/04_CODE/library/BASE_WRF BASE_WRF
ln -sf BASE_WRF/* .
[ -e namelist.input ] && rm -f namelist.input
[ -e job.sh ] && rm -f job.sh
[ -e longitude.dat ] && rm -f longitude.dat
[ -e latitude.dat ] && rm -f latitude.dat

ln -sf ../../08_BOGUS/${STRENGTHEN}${AdjTS} ${STRENGTHEN}${AdjTS}
ln -sf ${STRENGTHEN}${AdjTS}/merge*.nc .
EOF

chmod u+x prep_run_WRF.sh

./prep_run_WRF.sh
