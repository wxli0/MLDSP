#!/bin/bash

sample_dir="samples/$1"
dir="data/preprocess"
json_path="non_clade_exclusion/$1.json"
if [ ! -d ${sample_dir} ]; then
    python3 run_select_sample.py $1
    echo "INFO:done python3 run_select_sample.py $1"
    cd $dir
    if [[ $1 == g__* ]]; then
        python3 select_sample_species.py $json_path
        echo "INFO:python3 select_sample_species.py $json_path"
    else
        python3 select_sample_cluster.py $json_path
        echo "INFO:python3 select_sample_cluster.py $json_path"
    fi
    cd ../..
else
    echo "INFO:skip python3 run_select_sample.py $1"
fi

final_num=10
python3 samples/delete_small_cluster.py samples/$1 $final_num
echo "INFO:done python3 samples/delete_small_cluster.py samples/$1 $final_num"

final_num=30
python3 samples/delete_extra_files.py samples/$1 $final_num
echo "samples/delete_extra_files.py samples/$1 $final_num"

prog_output2="outputs/test-$1.xlsx"
rm ${prog_output2}
output2="outputs/$1_classify.txt"
matlab -r "run addme;stackedMain('$1', 'rumen_mags/$1');exit"|tee ${output2}
echo "INFO:done stackedMain('$1', 'rumen_mags/$1')"

dir="/home/w328li/BlindKameris-new/"
cd ${dir}
echo "INFO: done cd ${dir}"

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