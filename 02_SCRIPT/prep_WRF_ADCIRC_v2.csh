#!/bin/csh
cat > prep_WRF_ADCIRC.sh << EOF
#!/bin/bash
tgt_dir="/home/user_006/01_WORK/2025/NPP/05_DATA/processed/${TGT_NPP}/${TGT_TC}/12_ADCIRC/$subdir/${INTENSITY}"
if [ -d "\$tgt_dir" ]; then
        cd "\$tgt_dir"
else
        mkdir -p "\$tgt_dir"
        cd "\$tgt_dir"
fi
ln -sf /home/user_006/01_WORK/2025/NPP/02_SCRIPT 02_SCRIPT
ln -sf 02_SCRIPT/fort.15.csh .
ln -sf 02_SCRIPT/job_adcirc_swan.csh .
ln -sf /home/user_006/01_WORK/2025/NPP/05_DATA/processed/${TGT_NPP}/${TGT_SL}/fort.14 . 
EOF
chmod u+x prep_WRF_ADCIRC.sh
./prep_WRF_ADCIRC.sh
