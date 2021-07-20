#!/bin/bash

ver="r202"
base_dir=""
outdir="outputs-HGR-${ver}"
testdir="hgr_mags"
base_dir2="/mnt/sda/DeepMicrobes-data/labeled_genome-${ver}/"
split_pruned_dir_full="${base_dir2}$1_split_pruned"
split_pruned_dir="${base_dir}$1_split_pruned"

start_time2="$(date -u +%s)"
prog_output2="${outdir}/test-${split_pruned_dir}.xlsx"
output2="${outdir}/$1_classify.txt"
matlab -r "run addme;stackedMain('HGR', '${split_pruned_dir}', '${testdir}/$1');exit"|tee ${output2}
echo "INFO:done stackedMain('HGR', '${split_pruned_dir}', '${testdir}/$1')"
end_time2="$(date -u +%s)"
elapsed2="$(($end_time2-$start_time2))"
echo "$1 ${elapsed2}" >> "${outdir}/test_time.txt"


