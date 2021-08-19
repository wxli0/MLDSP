#!/bin/bash

: '
Script for the entire process of classifying single-child taxas

parameters:
$1: data_type. Data type of either HGR or GTDB
$2: sample_file. Taxon to classify
'


ver="r202"
base_dir=""
outdir=""
testdir=""
base_dir=""
data_type=$2
sample_file=$1
split_base="/mnt/sda/DeepMicrobes-data/labeled_genome-${ver}/"
split_pruned_dir="${base_dir}${sample_file}_split_pruned"

if [ ${data_type} == 'HGR' ]; then
    outdir="outputs-HGR-${ver}"
    sample_dir=${split_pruned_dir}
    testdir="hgr_mags"
elif [ ${data_type} == 'GTDB' ]; then
     outdir="outputs-${ver}"
     sample_dir=${sample_file}
     testdir="rumen_mags"
fi

cd ~/MLDSP

start_time2="$(date -u +%s)"
prog_output2="${outdir}/test-${sample_dir}.xlsx"
if [ ! -f ${prog_output2} ]; then
    matlab -r "run addme;stackedMain('${data_type}', '${sample_dir}', '${testdir}/${sample_file}');exit"
    echo "INFO:done stackedMain('${data_type}', '${sample_dir}', '${testdir}/${sample_file}');exit"
else
    echo "INFO:skip stackedMain('${data_type}', '${sample_dir}', '${testdir}/${sample_file}');exit"
fi

end_time2="$(date -u +%s)"
elapsed2="$(($end_time2-$start_time2))"
echo "${data_type} ${elapsed2}" >> "${outdir}/test_time.txt"

dir="/home/w328li/BlindKameris-new/"
cd ${dir}
echo "INFO: done cd ${dir}"

src2="/home/w328li/MLDSP/${outdir}/test-${sample_dir}.xlsx"
dest2="/home/w328li/BlindKameris-new/${outdir}/${sample_file}.xlsx"
cp ${src2} ${dest2}
echo "INFO: done cp ${src2} ${dest2}"
output3="${outdir}/${sample_file}.xlsx"
python3 postprocess_test_single_child.py ${output3}
echo "INFO: done python3 postprocess_test_single_child.py ${output3}"

python3 add_pred_single_child.py ${data_type} ${output3}
echo "INFO: done python3 add_pred_single_child.py ${data_type} ${output3}"
