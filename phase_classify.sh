#!/bin/bash

#$1: test_cat
#$1: taxon

ver="r202"
base_dir=""
outdir=""
testdir=""
base_dir=""
split_base="/mnt/sda/DeepMicrobes-data/labeled_genome-${ver}/"
split_pruned_dir="${base_dir}$2_split_pruned"

if [ $1 == 'HGR' ]; then
    outdir="outputs-HGR-${ver}"
    sample_dir=${split_pruned_dir}
    testdir="hgr_mags"
elif [ $1 == 'GTDB' ]; then
     outdir="outputs-${ver}"
     sample_dir=$2
     testdir="rumen_mags"
fi

cd ~/MLDSP

start_time2="$(date -u +%s)"
prog_output2="${outdir}/test-${sample_dir}.xlsx"
if [ ! -f ${prog_output2} ]; then
    matlab -r "run addme;stackedMain('$1', '${sample_dir}', '${testdir}/$2');exit"
    echo "INFO:done stackedMain('$1', '${sample_dir}', '${testdir}/$2');exit"
else
    echo "INFO:skip stackedMain('$1', '${sample_dir}', '${testdir}/$2');exit"
fi

end_time2="$(date -u +%s)"
elapsed2="$(($end_time2-$start_time2))"
echo "$1 ${elapsed2}" >> "${outdir}/test_time.txt"

dir="/home/w328li/BlindKameris-new/"
cd ${dir}
echo "INFO: done cd ${dir}"

src2="/home/w328li/MLDSP/${outdir}/test-${sample_dir}.xlsx"
dest2="/home/w328li/BlindKameris-new/${outdir}/$1.xlsx"
cp ${src2} ${dest2}
echo "INFO: done cp ${src2} ${dest2}"

output3="${outdir}/$2.xlsx"
python3 postprocess_test_single_child.py ${output3}
echo "INFO: done python3 postprocess_test_single_child.py ${output3}"

python3 add_pred_single_child.py $1 ${output3}
echo "INFO: done python3 add_pred_single_child.py $1 ${output3}"
