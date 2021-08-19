#!/bin/bash

ver='r202'
base_path="/mnt/sda/MLDSP-samples-${ver}/"
sample_file="$1"
sample_path="${base_path}${sample_file}"
json_dir="data/preprocess/"
json_path="non-clade-exclusion-${ver}/$1.json"
outdir="outputs-${ver}/"
data_type=$2
trunc_sample_file=$1
test_dir="rumen_mags/${trunc_sample_file}"
rej_dir="rejection-threshold-${data_type}-${ver}/"


start_time0="$(date -u +%s)"
if [ ! -d ${sample_path} ]; then
    python3 run_select_sample.py $1 $ver
    echo "INFO:done python3 run_select_sample.py $1 $ver"
    cd $json_dir
    if [[ $1 == g__* ]]; then
        python3 select_sample_species.py $json_path $ver
        echo "INFO:python3 select_sample_species.py $json_path $ver"
    else
        python3 select_sample_cluster.py $json_path $ver
        echo "INFO:python3 select_sample_cluster.py $json_path $ver"
    fi
    cd ../..
else
    echo "INFO:skip python3 run_select_sample.py $1 $ver"
fi

final_num=10
python3 samples/delete_small_cluster.py ${sample_path} $final_num
echo "INFO:done python3 samples/delete_small_cluster.py ${sample_path} $final_num"

final_num=30
if [[ $1 == g__* ]] || [[ $1 == f__* ]]; then 
    python3 samples/delete_extra_files.py ${sample_path} $final_num
    echo "samples/delete_extra_files.py ${sample_path} $final_num"
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


start_time1="$(date -u +%s)"
prog_output1="${outdir}train-${sample_file}.xlsx"
if [ ! -f ${prog_output1} ]; then
    output1="${outdir}${sample_file}.txt"
    matlab -r "run addme;stackedMain('${data_type}', '${sample_file}');exit"|tee ${output1}
    echo "INFO:done stackedMain('${data_type}', '${sample_file}')"
else
    echo "INFO:skip stackedMain('${data_type}', '${sample_file}')"
fi
end_time1="$(date -u +%s)"
elapsed1="$(($end_time1-$start_time1))"
echo "$1 ${elapsed1}" >> "${outdir}train_time.txt"


start_time2="$(date -u +%s)"
prog_output2="${outdir}test-${sample_file}.xlsx"
if [ ! -f ${prog_output2} ]; then
    output2="${outdir}${sample_file}_classify.txt"
    matlab -r "run addme;stackedMain('${data_type}', '${sample_file}', '${test_dir}');exit"|tee ${output2}
    echo "INFO:done stackedMain('${data_type}', '${sample_file}', '${test_dir}')"
else
    echo "INFO:skip stackedMain('${data_type}', '${sample_file}', '${test_dir}')"
fi
end_time2="$(date -u +%s)"
elapsed2="$(($end_time2-$start_time2))"
echo "$1 ${elapsed2}" >> "${outdir}/test_time.txt"


BK_dir="/home/w328li/BlindKameris-new/"
cd ${BK_dir}
echo "INFO: done cd ${BK_dir}"


start_time3="$(date -u +%s)"
src1="/home/w328li/MLDSP/${outdir}train-${sample_file}.xlsx"
dest1="${outdir}${trunc_sample_file}_train.xlsx"
cp ${src1} ${dest1}
echo "INFO:done cp ${src1} ${dest1}"
python3 preprocess_train_to_pr.py ${dest1}
echo "INFO:done preprocess_train_to_pr.py ${dest1}"


src2="/home/w328li/MLDSP/${outdir}test-${sample_file}.xlsx"
dest2="/home/w328li/BlindKameris-new/${outdir}${trunc_sample_file}.xlsx"
cp ${src2} ${dest2}
echo "INFO:done cp ${src2} ${dest2}"

python3 precision_recall_opt.py ${dest1} ${dest2} ${data_type}
echo "INFO:done python3 precision_recall_opt.py ${dest1} ${dest2} ${data_type}"
end_time3="$(date -u +%s)"
elapsed3="$(($end_time3-$start_time3))"
echo "$1 ${elapsed3}" >> "${outdir}/rej_time.txt"


start_time4="$(date -u +%s)"
output3="${outdir}${trunc_sample_file}.xlsx"
rej="${rej_dir}${trunc_sample_file}.json"
python3 preprocess_test.py ${output3} ${rej}
echo "INFO:done preprocess_test.py ${output3} ${rej}"



python3 add_pred.py ${output3} ${data_type}
echo "INFO: done add_pred.py ${output3} ${data_type}"
end_time4="$(date -u +%s)"
elapsed4="$(($end_time4-$start_time4))"
echo "$1 ${elapsed4}" >> "${outdir}/post_time.txt"