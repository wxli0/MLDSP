#!/bin/bash

#$1: test_cat
#$1: taxon

ver="r202"
base_dir=""
outdir="outputs-HGR-${ver}"
testdir="hgr_mags"
base_dir2="/mnt/sda/DeepMicrobes-data/labeled_genome-${ver}/"
split_pruned_dir_full="${base_dir2}$1_split_pruned"
split_pruned_dir="${base_dir}$1_split_pruned"

cd ~/MLDSP

start_time2="$(date -u +%s)"
prog_output2="${outdir}/test-${split_pruned_dir}.xlsx"
if [ $1 == 'HGR' ] && [ ! -f ${prog_output2} ]; then
    echo "INFO:skip stackedMain('HGR', '${split_pruned_dir}', '${testdir}/$1')"
fi
end_time2="$(date -u +%s)"
elapsed2="$(($end_time2-$start_time2))"
# echo "$1 ${elapsed2}" >> "${outdir}/test_time.txt"

dir="/home/w328li/BlindKameris-new/"
cd ${dir}
echo "INFO: done cd ${dir}"

src2="/home/w328li/MLDSP/${outdir}/test-${split_pruned_dir}.xlsx"
dest2="/home/w328li/BlindKameris-new/${outdir}/$1.xlsx"
cp ${src2} ${dest2}
echo "INFO: done cp ${src2} ${dest2}"

output3="${outdir}/$1.xlsx"
python3 postprocess_test_single_child.py ${output3}
echo "INFO: done python3 postprocess_test_single_child.py ${output3}"

python3 add_HGR_pred_single_child.py ${output3}
echo "INFO: done python3 add_HGR_pred_single_child.py ${output3}"
