#!/bin/bash
s_date=$(head -n 1 WIND_NAMES.dat | sed -E 's#.*/([0-9]{4})-([0-9]{2})-([0-9]{2})_([0-9]{2}).dat#\1\2\3.\40000#')
e_date=$(tail -n 1 WIND_NAMES.dat | sed -E 's#.*/([0-9]{4})-([0-9]{2})-([0-9]{2})_([0-9]{2}).dat#\1\2\3.\40000#')
tgt_tc=$(basename $(dirname $(dirname $(dirname "$(pwd)"))))
tc_num=${tgt_tc%%_*}
tgt_case=${1:-"${tc_num}_MPP"}
nNum=${2:-"2"}

cat > run_script_swan.sh <<EOF
#!/bin/bash
export sdate=${s_date}
export edate=${e_date}
export CASE=${tgt_case}
export nNum=${nNum}

csh INPUT.csh
./job_swan.csh
# sbatch job_swan.sh
EOF

chmod u+x run_script_swan.sh

./run_script_swan.sh
