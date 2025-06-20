#!/bin/bash
TGT_TC=${1:-"2211_HINNAMNOR"}
STRENGTHEN=${2:-"1.50+10"}
TGT_NPP=${3:-"SAEUL"}
TGT_SL=${4:-"10exH+SLR"}

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

cat > prep_WRF_SWAN_SETUP.sh << EOF
#!/bin/bash
tgt_dir="/home/user_006/01_WORK/2025/NPP/05_DATA/processed/${TGT_NPP}/${TGT_TC}/13_SETUP/$subdir/${STRENGTHEN}"
if [ -d "\$tgt_dir" ]; then
        cd "\$tgt_dir"
else
        mkdir -p "\$tgt_dir"
	cd "\$tgt_dir"
fi
ln -sf /home/user_006/06_MODEL/swan.exe .
ln -sf /home/user_006/01_WORK/2025/NPP/02_SCRIPT 02_SCRIPT
ln -sf 02_SCRIPT/INPUT_TEST.csh .
ln -sf 02_SCRIPT/job_swan.csh .
ln -sf 02_SCRIPT/run_script_swan.csh .
ln -sf /home/user_006/01_WORK/2025/NPP/05_DATA/processed/${TGT_NPP}/${TGT_TC}/10_SWAN/$subdir/${STRENGTHEN} ${STRENGTHEN}
ln -sf ${STRENGTHEN}/*.dat . 
EOF

chmod u+x prep_WRF_SWAN_SETUP.sh

./prep_WRF_SWAN_SETUP.sh
