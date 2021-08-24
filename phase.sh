#!/bin/bash

: '
Script for the entire process of classifying non single-child taxas

parameters:
$1: data_type. Data type of either HGR or GTDB
$2: sample_file. Taxon to classify
'

usage() { echo "Usage: $0 [-d <Mandatory. Name of data type>] 
[-s <Mandatory. File name of the training and testing datasets>]
[-b <Optional for data_type GTDB or HGR. Path to the directory that training datasets are in>]
[-t <Optional for data_type GTDB or HGR. Directory name of testing datasets>]" 1>&2; exit 1; }


while getopts ":d:b:s:t" o; do
    case "${o}" in
        d)
            data_type=${OPTARG}
            ;;
        b)
            base_path=${OPTARG}
            ;;
        s)
            trunc_sample_file=${OPTARG}
            ;;
        t)
            test_dir=${OPTARG}
            ;;
        *)
            echo "Invalid arguments"
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${data_type}" ] || [ -z "${trunc_sample_file}"]; then
    echo "Invalid -data_type or -sample_file"
    usage
fi

sample_file=${trunc_sample_file}
if [ ${data_type} == 'HGR' ] || [ ${data_type} == 'GTDB' ]; then
    # prepare variables for different tasks
    ver="r202"
    base_dir=""
    outdir=""
    sample_path=""
    json_dir=""
    json_path=""
    rej_dir="rejection-threshold-${data_type}-${ver}"
    outdir="outputs-${data_type}-${ver}"

    if [ ${data_type} == 'GTDB' ]; then
        base_path="/mnt/sda/MLDSP-samples-${ver}"
        json_dir="data/preprocess"
        json_path="non-clade-exclusion-${ver}/$1.json"
        test_dir="rumen_mags/${trunc_sample_file}"
    elif [ ${data_type} == 'HGR' ]; then
        base_path="/mnt/sda/DeepMicrobes-data/labeled_genome-${ver}"
        sample_file="${sample_file}_split_pruned"
        test_dir="hgr_mags/${trunc_sample_file}"
    fi
    sample_path="${base_path}/${sample_file}"
fi

echo "===== Printing parameter information ======"
echo "data_type = ${data_type}"
echo "base_path = ${base_path}"
echo "trunc_sample_file = ${trunc_sample_file}"
echo "sample_file = ${sample_file}"
echo "test_dir = ${test_dir}"
echo "sample_path = ${sample_path}"


echo "===== Preparing training dataset for GTDB or HGR======"
start_time0="$(date -u +%s)"
if [ ${data_type} == 'GTDB' ]; then
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

elif [ ${data_type} == 'HGR' ]; then

    if [ ! -d ${sample_path} ]; then
        python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_path}/${trunc_sample_file}
        echo "INFO: done python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_path}/${trunc_sample_file}"
    else
        echo "INFO: skip python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_path}/${trunc_sample_file}"
    fi

    # remove s__
    if [ -d "${sample_path}/s__" ]; then
        rm -r "${sample_path}/s__"
        echo "INFO: done rm -r ${sample_path}/s__"
    else
        echo "skip: done rm -r ${sample_path}/s__"
    fi

    # remove g__
    if [ -d "${sample_path}/g__" ]; then
        rm -r "${sample_path}/g__"
        echo "INFO: done rm -r ${sample_path}/g__"
    else
        echo "skip: done rm -r ${sample_path}/g__"
    fi

    if [[ $1 == 'd__Bacteria' ]] || [[ $1 == 'p__Firmicutes_A' ]] || [[ $1 == 'p__Bacteroidota' ]] || \
    [[ $1 == 'c__Clostridia' ]] || [[ $1 == 'o__Bacteroidales' ]] || [[ $1 == 'c__Brachyspirae' ]] \
    || [[ $1 == 'p__Actinobacteriota' ]] || [[ $1 == 'c__Synergistia' ]] || [[ $1 == 'c__Coriobacteriia' ]] \
    || [[ $1 == 'o__Oscillospirales' ]] || [[ $1 == 'o__Coriobacteriales' ]] || [[ $1 == 'f__Bacteroidaceae' ]] \
    || [[ $1 == 'f__Lachnospiraceae' ]] || [[ $1 == 'o__Actinomycetales' ]] || [[ $1 == 'f__Acutalibacteraceae' ]] \
    || [[ $1 == 'g__Ruminococcus_F' ]] || [[ $1 == 'g__F0040' ]] \
    || [[ $1 == 'g__Alistipes' ]]; then
        python3 samples/prune_large_clusters.py ${sample_file} $ver "HGR"
        echo "INFO: done python3 samples/prune_large_clusters.py ${sample_file} $ver HGR"
    else
        echo "INFO: skip python3 samples/prune_large_clusters.py ${sample_file} $ver HGR"
    fi
fi

end_time0="$(date -u +%s)"
elapsed0="$(($end_time0-$start_time0))"
echo "$1 ${elapsed0}" >> "${outdir}/pre_time.txt"


echo "===== Checking for single-child taxon ====="
single_child=0
child_num=`ls -l ${sample_path}|wc -l`
echo "INFO: child_num is: ${child_num}"
if [ child_num == 1 ]; then
    single_child=1
fi


# echo "===== Training models ====="
# if [ ${single_child} != 1 ]; then
#     start_time1="$(date -u +%s)"
#     prog_output1="${outdir}/train-${sample_file}.xlsx"
#     if [ ! -f ${prog_output1} ]; then
#         output1="${outdir}/${sample_file}.txt"
#         matlab -r "run addme;stackedMain('${data_type}', '${sample_file}');exit"|tee ${output1}
#         echo "INFO:done stackedMain('${data_type}', '${sample_file}')"
#     else
#         echo "INFO:skip stackedMain('${data_type}', '${sample_file}')"
#     fi
#     end_time1="$(date -u +%s)"
#     elapsed1="$(($end_time1-$start_time1))"
#     echo "$1 ${elapsed1}" >> "${outdir}/train_time.txt"
# fi


echo "===== Classifying test genomes ====="
start_time2="$(date -u +%s)"
prog_output2="${outdir}/test-${sample_file}.xlsx"
if [ ! -f ${prog_output2} ]; then
    output2="${outdir}/${sample_file}_classify.txt"
    matlab -r "run addme;stackedMain('${data_type}', '${sample_file}', '${test_dir}');exit"|tee ${output2}
    echo "INFO:done stackedMain('${data_type}', '${sample_file}', '${test_dir}')"
else
    echo "INFO:skip stackedMain('${data_type}', '${sample_file}', '${test_dir}')"
fi
end_time2="$(date -u +%s)"
elapsed2="$(($end_time2-$start_time2))"
echo "$1 ${elapsed2}" >> "${outdir}/test_time.txt"


BK_dir="/home/w328li/MT-MAG/"
cd ${BK_dir}
echo "INFO: done cd ${BK_dir}"


# echo "===== Picking rejection thresholds ====="
# start_time3="$(date -u +%s)"

# if [ single_child == 0 ]; then
#     src1="/home/w328li/MLDSP/${outdir}/train-${sample_file}.xlsx"
#     dest1="${outdir}/${trunc_sample_file}_train.xlsx"
#     cp ${src1} ${dest1}
#     echo "INFO:done cp ${src1} ${dest1}"
#     python3 preprocess_train_to_pr.py ${dest1}
#     echo "INFO:done preprocess_train_to_pr.py ${dest1}"
# fi

# src2="/home/w328li/MLDSP/${outdir}/test-${sample_file}.xlsx"
# dest2="/home/w328li/MT-MAG/${outdir}/${trunc_sample_file}.xlsx"
# cp ${src2} ${dest2}
# echo "INFO:done cp ${src2} ${dest2}"

# if [ single_child == 0 ]; then
#     python3 precision_recall_opt.py ${dest1} ${dest2} ${data_type}
#     echo "INFO:done python3 precision_recall_opt.py ${dest1} ${dest2} ${data_type}"
# fi

# end_time3="$(date -u +%s)"
# elapsed3="$(($end_time3-$start_time3))"
# echo "$1 ${elapsed3}" >> "${outdir}/rej_time.txt"


echo "===== Postprocessing test datasets ====="
start_time4="$(date -u +%s)"
output3="${outdir}/${trunc_sample_file}.xlsx"
rej="${rej_dir}/${trunc_sample_file}.json"
python3 preprocess_test.py ${output3} ${rej}
echo "INFO:done preprocess_test.py ${output3} ${rej}"


echo "===== Adding predictions to the result file ====="
python3 add_pred.py ${output3} ${data_type}
echo "INFO: done add_pred.py ${output3} ${data_type}"
end_time4="$(date -u +%s)"
elapsed4="$(($end_time4-$start_time4))"
echo "$1 ${elapsed4}" >> "${outdir}/post_time.txt"