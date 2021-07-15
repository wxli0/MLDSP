#!/bin/bash

ver="r202"
base_dir=""
outdir="outputs-HGR-${ver}"
testdir="hgr_mags"
base_dir2="/mnt/sda/DeepMicrobes-data/labeled_genome-${ver}/"
split_pruned_dir_full="${base_dir2}$1_split_pruned"
split_pruned_dir="${base_dir}$1_split_pruned"




dir="/home/w328li/BlindKameris-new/"
cd ${dir}
echo "INFO: done cd ${dir}"

start_time3="$(date -u +%s)"
src1="/home/w328li/MLDSP/${outdir}/train-${split_pruned_dir}.xlsx"
dest1="${outdir}/$1_train.xlsx"
cp ${src1} ${dest1}
echo "INFO:done cp ${src1} ${dest1}"
python3 preprocess_train_to_pr.py ${dest1}
echo "INFO:done preprocess_train_to_pr.py ${dest1}"


src2="/home/w328li/MLDSP/${outdir}/test-${split_pruned_dir}.xlsx"
dest2="/home/w328li/BlindKameris-new/${outdir}/$1.xlsx"
cp ${src2} ${dest2}
echo "INFO:done cp ${src2} ${dest2}"

python3 precision_recall_opt.py ${dest1} ${dest2} "HGR"
echo "INFO:done precision_recall_opt.py ${dest1} ${dest2} HGR"
end_time3="$(date -u +%s)"
elapsed3="$(($end_time3-$start_time3))"
lockfile -r 0 rej.lock || exit 1
echo "$1 ${elapsed3}" >> "${outdir}/rej_time.txt"
rm -f rej.lock

start_time4="$(date -u +%s)"
output3="${outdir}/$1.xlsx"
rej="rejection-threshold-HGR-${ver}/$1.json"
python3 preprocess_test.py ${output3} ${rej}
echo "INFO:done preprocess_test.py ${output3} ${rej}"

python3 add_HGR_pred.py ${output3}
echo "INFO: done add_HGR_pred.py ${output3}"
end_time4="$(date -u +%s)"
elapsed4="$(($end_time4-$start_time4))"
lockfile -r 0 post.lock || exit 1
echo "$1 ${elapsed4}" >> "${outdir}/post_time.txt"
rm -f post.lock