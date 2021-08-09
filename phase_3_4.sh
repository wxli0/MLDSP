#!/bin/bash

ver='r202'
base_dir="/mnt/sda/MLDSP-samples-${ver}/"
sample_dir="${base_dir}$1"
dir="data/preprocess"
json_path="non-clade-exclusion-${ver}/$1.json"
outdir="outputs-${ver}"


start_time0="$(date -u +%s)"
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

# if [ $1 == 'root' ] || [[ $1 == d__* ]] || \
# [[ $1 == 'p__Actinobacteriota' ]] || [[ $1 == 'p__Bacteroidota' ]] ||\
# [[ $1 == 'p__Firmicutes_A' ]] || [ $1 == 'p__Cyanobacteria' ] || 
# [[ $1 == 'p__Firmicutes' ]] || \
# [[ $1 == 'c__Actinomycetia' ]] || [[ $1 == 'c__Bacteroidia' ]] || \
# [[ $1 == 'c__Clostridia' ]] || [[ $1 == 'o__Actinomycetales' ]] || \
# [[ $1 == 'o__Bacteroidales' ]] || [[ $1 == 'o__Lachnospirales' ]] || \
# [[ $1 == 'c__Bacilli' ]] || [[ $1 == 'p__Proteobacteria' ]] || \
# [[ $1 == 'c__Alphaproteobacteria' ]]; then
#     python3 samples/prune_large_clusters.py $1 $ver "GTDB"
#     echo "python3 samples/prune_large_clusters.py $1 $ver GTDB"
# fi
# end_time0="$(date -u +%s)"
# elapsed0="$(($end_time0-$start_time0))"
# echo "$1 ${elapsed0}" >> "${outdir}/pre_time.txt"



dir="/home/w328li/BlindKameris-new/"
cd ${dir}
echo "INFO: done cd ${dir}"


start_time3="$(date -u +%s)"
src1="/home/w328li/MLDSP/outputs-${ver}/train-$1.xlsx"
dest1="outputs-${ver}/$1_train.xlsx"
cp ${src1} ${dest1}
echo "INFO:done cp ${src1} ${dest1}"
python3 preprocess_train_to_pr.py ${dest1}
echo "INFO:done preprocess_train_to_pr.py ${dest1}"


src2="/home/w328li/MLDSP/outputs-${ver}/test-$1.xlsx"
dest2="/home/w328li/BlindKameris-new/outputs-${ver}/$1.xlsx"
cp ${src2} ${dest2}
echo "INFO:done cp ${src2} ${dest2}"

python3 precision_recall_opt.py ${dest1} ${dest2} "GTDB"
echo "INFO:done python3 precision_recall_opt.py ${dest1} ${dest2} GTDB"
end_time3="$(date -u +%s)"
elapsed3="$(($end_time3-$start_time3))"
lockfile -r 0 rej.lock || exit 1
echo "$1 ${elapsed3}" >> "${outdir}/rej_time.txt"
rm -f rej.lock


start_time4="$(date -u +%s)"
output3="outputs-${ver}/$1.xlsx"
rej="rejection-threshold-GTDB-${ver}/$1.json"
python3 preprocess_test.py ${output3} ${rej}
echo "INFO:done preprocess_test.py ${output3} ${rej}"



python3 add_GTDB_pred.py ${output3}
echo "INFO: done add_GTDB_pred.py ${output3}"
end_time4="$(date -u +%s)"
elapsed4="$(($end_time4-$start_time4))"
lockfile -r 0 post.lock || exit 1
echo "$1 ${elapsed4}" >> "${outdir}/post_time.txt"
rm -f post.lock