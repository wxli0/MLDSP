#!/bin/bash

prog_output1="outputs/train-$1.xlsx"
if [ ! -f ${prog_output1} ]; then
    output1="outputs/$1.txt"
    matlab -r "run addme;stackedMain('$1');exit"|tee ${output1}
    echo "INFO:done stackedMain('$1')"
else
    echo "INFO:skip stackedMain('$1')"
fi

prog_output2="outputs/test-$1.xlsx"
if [ ! -f ${prog_output2} ]; then
    output2="outputs/$1_classify.txt"
    matlab -r "run addme;stackedMain('$1', 'rumen_mags/$1');exit"|tee ${output2}
    echo "INFO:done stackedMain('$1', 'rumen_mags/$1')"
else
    echo "INFO:skip stackedMain('$1', 'rumen_mags/$1')"
fi

dir="/home/w328li/BlindKameris-new/"
cd ${dir}
src1="/home/w328li/MLDSP/outputs/train-$1.xlsx"
dest1="outputs/$1_train.xlsx"
cp ${src1} ${dest1}
echo "INFO:done cp ${src1} ${dest1}"


python3 preprocess_train_to_pr.py ${dest1}
echo "INFO:done preprocess_train_to_pr.py ${dest1}"
python3 run_precision_recall_b_taxon.py ${dest1}
echo "INFO:done run_precision_recall_b_taxon.py ${dest1}"

src2="/home/w328li/MLDSP/outputs/test-$1.xlsx"
dest2="/home/w328li/BlindKameris-new/outputs/$1.xlsx"
cp ${src2} ${dest2}
echo "INFO:done cp ${src2} ${dest2}"