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

if [ -z "${data_type}" ] || [ -z "${base_path}" ] || [ -z "${trunc_sample_file}" ] || [ -z "${test_dir}" ]; then
    echo "Missing arguments"
    usage
fi

sample_file=${trunc_sample_file}
rej_dir="rejection-threshold-${data_type}"
outdir="outputs-${data_type}"
test_dir_sample="${test_dir}/${trunc_sample_file}"
ver="r202"
if [ ${data_type} == 'HGR-r202' ] || [ ${data_type} == 'GTDB-r202' ]; then
    # prepare variables for different tasks
    sample_path=""
    json_dir=""
    json_path=""
    if [ ${data_type} == 'GTDB-r202' ]; then
        json_dir="data/preprocess"
        json_path="non-clade-exclusion-${ver}/${trunc_sample_file}.json"
    elif [ ${data_type} == 'HGR-r202' ]; then
        sample_file="${sample_file}_split_pruned"
    fi
fi
sample_path="${base_path}/${sample_file}"


echo "===== Printing parameter information ======"
echo "data_type = ${data_type}"
echo "base_path = ${base_path}"
echo "trunc_sample_file = ${trunc_sample_file}"
echo "sample_file = ${sample_file}"
echo "test_dir_sample = ${test_dir_sample}"
echo "sample_path = ${sample_path}"


echo "===== Preparing training dataset for GTDB or HGR======"
start_time0="$(date -u +%s)"
if [ ${data_type} == 'GTDB-r202' ]; then
    if [ ! -d ${sample_path} ]; then
        python3 run_select_sample.py ${trunc_sample_file} $ver
        echo "INFO:done python3 run_select_sample.py ${trunc_sample_file} $ver"
        cd $json_dir
        if [[ ${trunc_sample_file} == g__* ]]; then
            python3 select_sample_species.py $json_path $ver
            echo "INFO:python3 select_sample_species.py $json_path $ver"
        else
            python3 select_sample_cluster.py $json_path $ver
            echo "INFO:python3 select_sample_cluster.py $json_path $ver"
        fi
        cd ../..

        final_num=10
        python3 samples/delete_small_cluster.py ${sample_path} $final_num
        echo "INFO:done python3 samples/delete_small_cluster.py ${sample_path} $final_num"

        final_num=30
        if [[ ${trunc_sample_file} == g__* ]] || [[ ${trunc_sample_file} == f__* ]]; then 
            python3 samples/delete_extra_files.py ${sample_path} $final_num
            echo "samples/delete_extra_files.py ${sample_path} $final_num"
        else
            echo "skip samples/delete_extra_files.py ${sample_path} $final_num"
        fi

        if [[ ${trunc_sample_file} == d__* ]] || \
        [[ ${trunc_sample_file} == 'p__Actinobacteriota' ]] || [[ ${trunc_sample_file} == 'p__Bacteroidota' ]] ||\
        [[ ${trunc_sample_file} == 'p__Firmicutes_A' ]] || [ ${trunc_sample_file} == 'p__Cyanobacteria' ] || 
        [[ ${trunc_sample_file} == 'p__Firmicutes' ]] || \
        [[ ${trunc_sample_file} == 'c__Actinomycetia' ]] || [[ ${trunc_sample_file} == 'c__Bacteroidia' ]] || \
        [[ ${trunc_sample_file} == 'c__Clostridia' ]] || [[ ${trunc_sample_file} == 'o__Actinomycetales' ]] || \
        [[ ${trunc_sample_file} == 'o__Bacteroidales' ]] || [[ ${trunc_sample_file} == 'o__Lachnospirales' ]] || \
        [[ ${trunc_sample_file} == 'c__Bacilli' ]] || [[ ${trunc_sample_file} == 'p__Proteobacteria' ]] || \
        [[ ${trunc_sample_file} == 'c__Alphaproteobacteria' ]]; then
            python3 samples/prune_large_clusters.py ${trunc_sample_file} $ver "GTDB"
            echo "python3 samples/prune_large_clusters.py ${trunc_sample_file} $ver GTDB"
        else
            echo "skip samples/prune_large_clusters.py ${trunc_sample_file} $ver GTDB"
        fi

    else
        echo "INFO:skip python3 run_select_sample.py $ $ver"
    fi

elif [ ${data_type} == 'HGR' ]; then

    if [ ! -d ${sample_path} ]; then
        python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_path}/${trunc_sample_file}
        echo "INFO: done python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_path}/${trunc_sample_file}"

        if [[ ${trunc_sample_file} == 'd__Bacteria' ]] || [[ ${trunc_sample_file} == 'p__Firmicutes_A' ]] || [[ ${trunc_sample_file} == 'p__Bacteroidota' ]] || \
        [[ ${trunc_sample_file} == 'c__Clostridia' ]] || [[ ${trunc_sample_file} == 'o__Bacteroidales' ]] || [[ ${trunc_sample_file} == 'c__Brachyspirae' ]] \
        || [[ ${trunc_sample_file} == 'p__Actinobacteriota' ]] || [[ ${trunc_sample_file} == 'c__Synergistia' ]] || [[ ${trunc_sample_file} == 'c__Coriobacteriia' ]] \
        || [[ ${trunc_sample_file} == 'o__Oscillospirales' ]] || [[ ${trunc_sample_file} == 'o__Coriobacteriales' ]] || [[ ${trunc_sample_file} == 'f__Bacteroidaceae' ]] \
        || [[ ${trunc_sample_file} == 'f__Lachnospiraceae' ]] || [[ ${trunc_sample_file} == 'o__Actinomycetales' ]] || [[ ${trunc_sample_file} == 'f__Acutalibacteraceae' ]] \
        || [[ ${trunc_sample_file} == 'g__Ruminococcus_F' ]] || [[ ${trunc_sample_file} == 'g__F0040' ]] \
        || [[ ${trunc_sample_file} == 'g__Alistipes' ]]; then
            python3 samples/prune_large_clusters.py ${sample_file} $ver "HGR"
            echo "INFO: done python3 samples/prune_large_clusters.py ${sample_file} $ver HGR"
        else
            echo "INFO: skip python3 samples/prune_large_clusters.py ${sample_file} $ver HGR"
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

    else
        echo "INFO: skip python3 ~/DeepMicrobes/scripts/split_fasta_5000.py ${base_path}/${trunc_sample_file}"
    fi
fi

end_time0="$(date -u +%s)"
elapsed0="$(($end_time0-$start_time0))"
echo "${trunc_sample_file} ${elapsed0}" >> "${outdir}/pre_time.txt"


echo "===== Checking for single-child taxon ====="
child_num=`ls -l ${sample_path}|wc -l`
child_num=$((child_num-1)) 
echo "INFO: child_num is: ${child_num}"



# echo "===== Training models ====="
# if [ ${child_num} != 1 ]; then
#     start_time1="$(date -u +%s)"
#     prog_output1="${outdir}/train-${sample_file}.xlsx"
#     if [ ! -f ${prog_output1} ]; then
#         output1="${outdir}/${sample_file}.txt"
#         matlab -r "run addme;stackedMain('${data_type}', '${base_path}', '${sample_file}');exit"|tee ${output1}
#         echo "INFO:done stackedMain('${data_type}', '${base_path}', '${sample_file}')"
#     else
#         echo "INFO:skip stackedMain('${data_type}', '${base_path}', '${sample_file}')"
#     fi
#     end_time1="$(date -u +%s)"
#     elapsed1="$(($end_time1-$start_time1))"
#     echo "${trunc_sample_file} ${elapsed1}" >> "${outdir}/train_time.txt"
# fi


echo "===== Classifying test genomes ====="
start_time2="$(date -u +%s)"
prog_output2="${outdir}/test-${sample_file}.xlsx"
if [ ! -f ${prog_output2} ]; then
    output2="${outdir}/${sample_file}_classify.txt"
    matlab -r "run addme;stackedMain('${data_type}', '${base_path}', '${sample_file}', '${test_dir_sample}');exit"|tee ${output2}
    echo "INFO:done stackedMain('${data_type}', '${base_path}', '${sample_file}', '${test_dir_sample}')"
else
    echo "INFO:skip stackedMain('${data_type}', '${base_path}', '${sample_file}', '${test_dir_sample}')"
fi
end_time2="$(date -u +%s)"
elapsed2="$(($end_time2-$start_time2))"
echo "${trunc_sample_file} ${elapsed2}" >> "${outdir}/test_time.txt"


BK_dir="/home/w328li/MT-MAG/"
cd ${BK_dir}
echo "INFO: done cd ${BK_dir}"


# echo "===== Picking rejection thresholds ====="
# start_time3="$(date -u +%s)"

# if [ ${child_num} != 1 ]; then
#     src1="/home/w328li/MLDSP/${outdir}/train-${sample_file}.xlsx"
#     dest1="${outdir}/${trunc_sample_file}_train.xlsx"
#     cp ${src1} ${dest1}
#     echo "INFO:done cp ${src1} ${dest1}"
#     python3 preprocess_train_to_pr.py ${dest1}
#     echo "INFO:done preprocess_train_to_pr.py ${dest1}"
# fi

src2="/home/w328li/MLDSP/${outdir}/test-${sample_file}.xlsx"
dest2="/home/w328li/MT-MAG/${outdir}/${trunc_sample_file}.xlsx"
cp ${src2} ${dest2}
echo "INFO:done cp ${src2} ${dest2}"

# if [ ${child_num} != 1 ]; then
#     python3 precision_recall_opt.py ${dest1} ${dest2} ${data_type}
#     echo "INFO:done python3 precision_recall_opt.py ${dest1} ${dest2} ${data_type}"
# fi

# end_time3="$(date -u +%s)"
# elapsed3="$(($end_time3-$start_time3))"
# echo "${trunc_sample_file} ${elapsed3}" >> "${outdir}/rej_time.txt"


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
echo "${trunc_sample_file} ${elapsed4}" >> "${outdir}/post_time.txt"