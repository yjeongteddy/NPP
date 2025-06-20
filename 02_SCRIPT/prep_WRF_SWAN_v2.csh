#!/bin/csh
cat > prep_WRF_SWAN.sh << EOF
#!/bin/bash
tgt_dir="/home/user_006/01_WORK/2025/NPP/05_DATA/processed/${TGT_NPP}/${TGT_TC}/10_SWAN/${subdir}/${INTENSITY}"
if [ -d "\$tgt_dir" ]; then
        cd "\$tgt_dir"
else
        mkdir -p "\$tgt_dir"
        cd "\$tgt_dir"
fi
ln -sf /home/user_006/06_MODEL/swan.exe .
ln -sf /home/user_006/01_WORK/2025/NPP/02_SCRIPT 02_SCRIPT
ln -sf 02_SCRIPT/INPUT.csh .
ln -sf 02_SCRIPT/job_swan.csh .
ln -sf 02_SCRIPT/run_script_swan_v2.csh .
EOF

chmod u+x prep_WRF_SWAN.sh
./prep_WRF_SWAN.sh
