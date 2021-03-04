#!/bin/bash

sample_dir="samples/$1"
dir="data/preprocess"
json_path="non_clade_exclusion/$1.json"
if [ ! -d ${sample_dir} ]; then
    python3 run_select_sample.py $1
    cd $dir
    python3 select_sample_cluster.py $json_path
    cd ../..
    echo "INFO:done python3 run_select_sample.py $1"
else
    echo "INFO:skip python3 run_select_sample.py $1"
fi

final_num=15
python3 samples/delete_files.py $1 $final_num
echo "INFO:done python3 samples/delete_files.py samples/$1 $final_num"

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
echo "INFO: done cd ${dir}"

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

output3="outputs/$1.xlsx"
rej="rejection_threshold/$1.json"
python3 preprocess_test.py ${output3} ${rej}
echo "INFO:done preprocess_test.py ${output3} ${rej}"


python3 add_MLDSP_pred.py ${output3}
echo "INFO: done add_MLDSP_pred.py ${output3}"