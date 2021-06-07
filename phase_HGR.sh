#!/bin/bash

ver="r202"
base_dir=""
outdir="outputs-HGR-${ver}"
testdir="hgr_mags"
split_pruned_dir="${base_dir}$1_split_pruned"

if [ ! -d ${split_pruned_dir} ]; then
    python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_dir}$1
    echo "INFO: done python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_dir}$1"
else
    echo "INFO: skip python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_dir}$1"
fi

prog_output1="${outdir}/train-${split_pruned_dir}.xlsx"
if [ ! -f ${prog_output1} ]; then
    output1="${outdir}/$1.txt"
    matlab -r "run addme;stackedMain('HGR', '${split_pruned_dir}');exit"|tee ${output1}
    echo "INFO:done stackedMain('HGR', '${split_pruned_dir}')"
else
    echo "INFO:skip stackedMain('HGR', '${split_pruned_dir}')"
fi

prog_output2="${outdir}/test-${split_pruned_dir}.xlsx"
if [ ! -f ${prog_output2} ]; then
    output2="${outdir}/$1_classify.txt"
    matlab -r "run addme;stackedMain('HGR', '${split_pruned_dir}', '${testdir}/$1');exit"|tee ${output2}
    echo "INFO:done stackedMain('HGR', '${split_pruned_dir}', '${testdir}/$1')"
else
    echo "INFO:skip stackedMain('HGR', '${split_pruned_dir}', '${testdir}/$1')"
fi

dir="/home/w328li/BlindKameris-new/"
cd ${dir}
echo "INFO: done cd ${dir}"

src1="/home/w328li/MLDSP/${outdir}/train-${split_pruned_dir}.xlsx"
dest1="${outdir}/$1_train.xlsx"
cp ${src1} ${dest1}
echo "INFO:done cp ${src1} ${dest1}"


python3 preprocess_train_to_pr.py ${dest1}
echo "INFO:done preprocess_train_to_pr.py ${dest1}"
python3 precision_recall.py ${dest1} "HGR"
echo "INFO:done precision_recall.py ${dest1} HGR"

src2="/home/w328li/MLDSP/${outdir}/test-${split_pruned_dir}.xlsx"
dest2="/home/w328li/BlindKameris-new/${outdir}/$1.xlsx"
cp ${src2} ${dest2}
echo "INFO:done cp ${src2} ${dest2}"

output3="${outdir}/$1.xlsx"
rej="rejection-threshold-HGR-${ver}/$1.json"
python3 preprocess_test.py ${output3} ${rej}
echo "INFO:done preprocess_test.py ${output3} ${rej}"


python3 add_HGR_pred.py ${output3}
echo "INFO: done add_HGR_pred.py ${output3}"