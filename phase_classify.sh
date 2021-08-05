#!/bin/bash

#$1: test_cat
#$1: taxon

ver="r202"
base_dir=""
outdir=""
testdir=""
base_dir=""
split_base="/mnt/sda/DeepMicrobes-data/labeled_genome-${ver}/"
split_pruned_dir_full="${split_base}$2_split_pruned"
split_pruned_dir="${base_dir}$2_split_pruned"
if [ $1 == 'HGR' ]:
    outdir="outputs-HGR-${ver}"
    sample_dir=split_pruned_dir
    test_dir="hgr_mags"
elif [ $1 == 'GTDB' ]:
     outdir="outputs-${ver}"
     sample_dir=$1
     testdir="rumen_mags"
fi

cd ~/MLDSP

start_time2="$(date -u +%s)"
prog_output2="${outdir}/test-${sample_dir}.xlsx"
if [ ! -f ${prog_output2} ]; then
    matlab -r "run addme;stackedMain($1, '${sample_dir}', '${testdir}/$2')"
    echo "INFO:done stackedMain($1, '${sample_dir}', '${testdir}/$2')"
else:
    echo "INFO:skip stackedMain($1, '${sample_dir}', '${testdir}/$2')"
fi

# end_time2="$(date -u +%s)"
# elapsed2="$(($end_time2-$start_time2))"
# # echo "$1 ${elapsed2}" >> "${outdir}/test_time.txt"

# dir="/home/w328li/BlindKameris-new/"
# cd ${dir}
# echo "INFO: done cd ${dir}"

# src2="/home/w328li/MLDSP/${outdir}/test-${split_pruned_dir}.xlsx"
# dest2="/home/w328li/BlindKameris-new/${outdir}/$1.xlsx"
# cp ${src2} ${dest2}
# echo "INFO: done cp ${src2} ${dest2}"

# output3="${outdir}/$1.xlsx"
# python3 postprocess_test_single_child.py ${output3}
# echo "INFO: done python3 postprocess_test_single_child.py ${output3}"

# python3 add_HGR_pred_single_child.py ${output3}
# echo "INFO: done python3 add_HGR_pred_single_child.py ${output3}"
