#!/bin/bash

ver="r202"
base_dir=""
outdir="outputs-HGR-${ver}"
testdir="hgr_mags"
base_dir2="/mnt/sda/DeepMicrobes-data/labeled_genome-${ver}/"
split_pruned_dir_full="${base_dir2}$1_split_pruned"
split_pruned_dir="${base_dir}$1_split_pruned"

start_time0="$(date -u +%s)"
# remove s__
if [ -d "${base_dir2}$1/s__" ]; then
    rm -r "${base_dir2}$1/s__"
    echo "INFO: done rm -r ${base_dir2}$1/s__"
else
    echo "skip: done rm -r ${base_dir2}$1/s__"
fi

# remove g__
if [ -d "${base_dir2}$1/g__" ]; then
    rm -r "${base_dir2}$1/g__"
    echo "INFO: done rm -r ${base_dir2}$1/g__"
else
    echo "skip: done rm -r ${base_dir2}$1/g__"
fi


if [ ! -d ${split_pruned_dir_full} ]; then
    python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_dir2}$1
    echo "INFO: done python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_dir2}$1"
else
    echo "INFO: skip python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_dir2}$1"
fi

# if [[ $1 == 'd__Bacteria' ]] || [[ $1 == 'p__Firmicutes_A' ]] || [[ $1 == 'p__Bacteroidota' ]] || \
# [[ $1 == 'c__Clostridia' ]] || [[ $1 == 'o__Bacteroidales' ]] || [[ $1 == 'c__Brachyspirae' ]] \
# || [[ $1 == 'p__Actinobacteriota' ]] || [[ $1 == 'c__Synergistia' ]] || [[ $1 == 'c__Coriobacteriia' ]] \
# || [[ $1 == 'o__Oscillospirales' ]] || [[ $1 == 'o__Coriobacteriales' ]] || [[ $1 == 'f__Bacteroidaceae' ]] \
# || [[ $1 == 'f__Lachnospiraceae' ]] || [[ $1 == 'o__Actinomycetales' ]] || [[ $1 == 'f__Acutalibacteraceae' ]] \
# || [[ $1 == 'g__Ruminococcus_F' ]] || [[ $1 == 'g__F0040' ]] \
# || [[ $1 == 'g__Alistipes' ]]; then
#     python3 samples/prune_large_clusters.py $split_pruned_dir $ver "HGR"
#     echo "INFO: done python3 samples/prune_large_clusters.py $split_pruned_dir $ver HGR"
# else
#     echo "INFO: skip python3 samples/prune_large_clusters.py $split_pruned_dir $ver HGR"
# fi
# end_time0="$(date -u +%s)"
# elapsed0="$(($end_time0-$start_time0))"
# echo "$1 ${elapsed0}" >> "${outdir}/pre_time.txt"

start_time1="$(date -u +%s)"
prog_output1="${outdir}/train-${split_pruned_dir}.xlsx"
if [ ! -f ${prog_output1} ]; then
    output1="${outdir}/$1.txt"
    matlab -r "run addme;stackedMain('HGR', '${split_pruned_dir}');exit"|tee ${output1}
    echo "INFO:done stackedMain('HGR', '${split_pruned_dir}')"
else
    echo "INFO:skip stackedMain('HGR', '${split_pruned_dir}')"
fi
end_time1="$(date -u +%s)"
elapsed1="$(($end_time1-$start_time1))"
echo "$1 ${elapsed1}" >> "${outdir}/train_time.txt"

start_time2="$(date -u +%s)"
prog_output2="${outdir}/test-${split_pruned_dir}.xlsx"
if [ ! -f ${prog_output2} ]; then
    output2="${outdir}/$1_classify.txt"
    matlab -r "run addme;stackedMain('HGR', '${split_pruned_dir}', '${testdir}/$1');exit"|tee ${output2}
    echo "INFO:done stackedMain('HGR', '${split_pruned_dir}', '${testdir}/$1')"
else
    echo "INFO:skip stackedMain('HGR', '${split_pruned_dir}', '${testdir}/$1')"
fi
end_time2="$(date -u +%s)"
elapsed2="$(($end_time2-$start_time2))"
echo "$1 ${elapsed2}" >> "${outdir}/test_time.txt"

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
echo "$1 ${elapsed3}" >> "${outdir}/rej_time.txt"

start_time4="$(date -u +%s)"
output3="${outdir}/$1.xlsx"
rej="rejection-threshold-HGR-${ver}/$1.json"
python3 preprocess_test.py ${output3} ${rej}
echo "INFO:done preprocess_test.py ${output3} ${rej}"

python3 add_HGR_pred.py ${output3}
echo "INFO: done add_HGR_pred.py ${output3}"
end_time4="$(date -u +%s)"
elapsed4="$(($end_time4-$start_time4))"
echo "$1 ${elapsed4}" >> "${outdir}/post_time.txt"