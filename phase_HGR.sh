#!/bin/bash

sample_dir="samples/$1"
outdir="outputs_HGR"
testdir="hgr_mags"

prog_output1="${outdir}/train-$1.xlsx"
if [ ! -f ${prog_output1} ]; then
    output1="${outdir}/$1.txt"
    matlab -r "run addme;stackedMain('$1');exit"|tee ${output1}
    echo "INFO:done stackedMain('$1')"
else
    echo "INFO:skip stackedMain('$1')"
fi

prog_output2="${outdir}/test-$1.xlsx"
if [ ! -f ${prog_output2} ]; then
    output2="${outdir}/$1_classify.txt"
    matlab -r "run addme;stackedMain('$1', '${testdir}/$1');exit"|tee ${output2}
    echo "INFO:done stackedMain('$1', '${testdir}/$1')"
else
    echo "INFO:skip stackedMain('$1', '${testdir}/$1')"
fi

dir="/home/w328li/BlindKameris-new/"
cd ${dir}
echo "INFO: done cd ${dir}"

src1="/home/w328li/MLDSP/${outdir}/train-$1.xlsx"
dest1="${outdir}/$1_train.xlsx"
cp ${src1} ${dest1}
echo "INFO:done cp ${src1} ${dest1}"


python3 preprocess_train_to_pr.py ${dest1}
echo "INFO:done preprocess_train_to_pr.py ${dest1}"
python3 run_precision_recall_b_taxon.py ${dest1}
echo "INFO:done run_precision_recall_b_taxon.py ${dest1}"

src2="/home/w328li/MLDSP/${outdir}/test-$1.xlsx"
dest2="/home/w328li/BlindKameris-new/${outdir}/$1.xlsx"
cp ${src2} ${dest2}
echo "INFO:done cp ${src2} ${dest2}"

output3="${outdir}/$1.xlsx"
rej="rejection_threshold/$1.json"
python3 preprocess_test.py ${output3} ${rej}
echo "INFO:done preprocess_test.py ${output3} ${rej}"


python3 add_MLDSP_pred.py ${output3}
echo "INFO: done add_MLDSP_pred.py ${output3}"