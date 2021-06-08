#!/bin/bash

ver='r202'
base_dir="/mnt/sda/MLDSP-samples-${ver}/"
sample_dir="${base_dir}$1"
dir="data/preprocess"
json_path="non-clade-exclusion-${ver}/$1.json"
if [ ! -d ${sample_dir} ]; then
    python3 run_select_sample.py $1 $ver
    echo "INFO:done python3 run_select_sample.py $1 $ver"
    cd $dir
    if [[ $1 == g__* ]]; then
        python3 select_sample_species.py $json_path $ver
        echo "INFO:python3 select_sample_species.py $json_pat $ver"
    else
        python3 select_sample_cluster.py $json_path $ver
        echo "INFO:python3 select_sample_cluster.py $json_path $ver"
    fi
    cd ../..
else
    echo "INFO:skip python3 run_select_sample.py $1 $ver"
fi

final_num=10
python3 samples/delete_small_cluster.py ${sample_dir} $final_num
echo "INFO:done python3 samples/delete_small_cluster.py ${sample_dir} $final_num"

final_num=30
if [[ $1 == g__* ]] || [[ $1 == f__* ]]; then 
    python3 samples/delete_extra_files.py ${sample_dir} $final_num
    echo "samples/delete_extra_files.py ${sample_dir} $final_num"
fi

if [ $1 == 'root' ] || [[ $1 == d__* ]] || \
[[ $1 == 'p__Actinobacteriota' ]] || [[ $1 == 'p__Bacteroidota' ]] ||\
[[ $1 == 'p__Firmicutes_A' ]] || [ $1 == 'p__Cyanobacteria' ] || 
[[ $1 == 'p__Firmicutes' ]] || \
[[ $1 == 'c__Actinomycetia' ]] || [[ $1 == 'c__Bacteroidia' ]] || \
[[ $1 == 'c__Clostridia' ]] || [[ $1 == 'o__Actinomycetales' ]] || \
[[ $1 == 'o__Bacteroidales' ]] || [[ $1 == 'o__Lachnospirales' ]] || \
[[ $1 == 'c__Bacilli' ]] || [[ $1 == 'p__Proteobacteria' ]] || \
[[ $1 == 'c__Alphaproteobacteria' ]]; then
    python3 samples/prune_large_clusters.py $1 $ver "GTDB"
    echo "python3 samples/prune_large_clusters.py $1 $ver GTDB"
fi

prog_output1="outputs-${ver}/train-$1.xlsx"
if [ ! -f ${prog_output1} ]; then
    output1="outputs-${ver}/$1.txt"
    matlab -r "run addme;stackedMain('GTDB', '$1');exit"|tee ${output1}
    echo "INFO:done stackedMain('GTDB', '$1')"
else
    echo "INFO:skip stackedMain('GTDB', '$1')"
fi

prog_output2="outputs-${ver}/test-$1.xlsx"
if [ ! -f ${prog_output2} ]; then
    output2="outputs-${ver}/$1_classify.txt"
    matlab -r "run addme;stackedMain('GTDB', '$1', 'rumen_mags/$1');exit"|tee ${output2}
    echo "INFO:done stackedMain('GTDB', '$1', 'rumen_mags/$1')"
else
    echo "INFO:skip stackedMain('GTDB', '$1', 'rumen_mags/$1')"
fi

dir="/home/w328li/BlindKameris-new/"
cd ${dir}
echo "INFO: done cd ${dir}"

src1="/home/w328li/MLDSP/outputs-${ver}/train-$1.xlsx"
dest1="outputs-${ver}/$1_train.xlsx"
cp ${src1} ${dest1}
echo "INFO:done cp ${src1} ${dest1}"


python3 preprocess_train_to_pr.py ${dest1}
echo "INFO:done preprocess_train_to_pr.py ${dest1}"
python3 precision_recall.py ${dest1} "GTDB"
echo "INFO:done python3 precision_recall.py ${dest1} GTDB"

src2="/home/w328li/MLDSP/outputs-${ver}/test-$1.xlsx"
dest2="/home/w328li/BlindKameris-new/outputs-${ver}/$1.xlsx"
cp ${src2} ${dest2}
echo "INFO:done cp ${src2} ${dest2}"

output3="outputs-${ver}/$1.xlsx"
rej="rejection-threshold-${ver}/$1.json"
python3 preprocess_test.py ${output3} ${rej}
echo "INFO:done preprocess_test.py ${output3} ${rej}"


python3 add_MLDSP_pred.py ${output3}
echo "INFO: done add_MLDSP_pred.py ${output3}"