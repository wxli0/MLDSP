"""
Downloads GTDB genomes belonging to a taxon to a direcotory.\
    The directory format is 
    taxon
        - child taxon 1
        - child taxon 2
        - ...
    This is used for downloading taxons belong to genus level, as we want not \
        only the representative genomes, but all genomes for child level genomes \
            (species).

:param sys.argv[1]: path to a json file containing the properties of \
    the downloaded genomes
:type sys.argv[1]: str
:param sys.argv[2]: version, e.g r202, r95
:type sys.arg[2]: str
"""

from helpers import download_genomes, parse_json_input
import pandas as pd
import os
import platform
import random
import ssl
import sys

random.seed(0)
sample_factor, sample_size, tax_name, use_factor, cluster_num, \
    cluster_names, lower, upper, use_const_len, const_len, frags_num, \
        alter, id, outdir, rep_time = parse_json_input(sys.argv[1])

if not outdir:
    outdir = tax_name
    if use_const_len:
        outdir += "_const"
    else:
        outdir += "_nonconst"
    if use_factor:
        outdir += "_factor"
    else:
        outdir += "_nonfactor"
    if frags_num >= 2:
        outdir += "_multifrag"
    else:
        outdir += "_singlefrag"
    if id is not None:
        outdir +="_"+id


ver=sys.argv[2]
download_path = '/mnt/sda/MLDSP-samples-'+ver+'/'
outdir_full = download_path+outdir
print("outdir_full is:", outdir_full)
ssl._create_default_https_context = ssl._create_unverified_context

cluster_tsv = pd.read_csv("../data/preprocess/sp_clusters_r202.tsv", sep='\t', header = 0, index_col = None)
cluster_tsv = cluster_tsv[['GTDB_species','Clustered_genomes']].set_index('GTDB_species')

for cluster_name in cluster_names:
    all_genome_ids = cluster_tsv.loc[cluster_name]['Clustered_genomes'].split(',')
    all_genome_size = len(all_genome_ids)
    real_sample_size = sample_size
    if use_factor:
        real_sample_size = int(all_genome_size*sample_factor)
    elif all_genome_size < real_sample_size:
        real_sample_size = all_genome_size

    selected_genomes = random.sample(all_genome_ids, real_sample_size)

    cluster_dir_full = outdir_full+'/'+cluster_name
    print("cluster_dir_full is:", cluster_dir_full)
    if not os.path.exists(cluster_dir_full):
        print("enter here")
        os.makedirs(cluster_dir_full)
    download_genomes(selected_genomes, cluster_dir_full, lower, \
        upper, use_const_len, const_len, frags_num, alter, rep_time=rep_time)

