#!/bin/bash

ver='r202'
base_dir="/mnt/sda/MLDSP-samples-${ver}/"
sample_dir="${base_dir}$1"
dir="data/preprocess"
json_path="non-clade-exclusion-${ver}/$1.json"
outdir="outputs-${ver}"


start_time2="$(date -u +%s)"
prog_output2="outputs-${ver}/test-$1.xlsx"

output2="outputs-${ver}/$1_classify.txt"
matlab -r "run addme;stackedMain('GTDB', '$1', 'rumen_mags/$1');exit"|tee ${output2}
echo "INFO:done stackedMain('GTDB', '$1', 'rumen_mags/$1')"

end_time2="$(date -u +%s)"
elapsed2="$(($end_time2-$start_time2))"
echo "$1 ${elapsed2}" >> "${outdir}/test_time.txt"
