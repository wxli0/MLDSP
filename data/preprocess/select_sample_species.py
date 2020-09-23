import csv
import pandas as pd
import os
import random
import shutil
import sys
import os
import gzip
from Bio import SeqIO
import math
from helpers import download_genomes, parse_json_input
import ssl
import platform
import json

sample_factor, sample_size, tax_name, use_factor, cluster_num, cluster_names, lower, upper, use_const_len, const_len, frags_num, alter, id= parse_json_input(sys.argv[1]) # for species, dont use factor

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

base_path = "/Users/wanxinli/Desktop/project/MLDSP-desktop/" # run locally
if platform.platform()[:5] == 'Linux':
    base_path = "/home/w328li/MLDSP-desktop/"
outdir_full = base_path+"samples/"+outdir
ssl._create_default_https_context = ssl._create_unverified_context

cluster_tsv = pd.read_csv(base_path+"data/preprocess/sp_clusters_r89.tsv", sep='\t', header = 0, index_col = None)
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

    outdir_full = base_path+"samples/"+outdir
    cluster_dir_full = outdir_full+'/'+cluster_name
    if not os.path.exists(cluster_dir_full):
        os.makedirs(cluster_dir_full)
    download_genomes(selected_genomes, cluster_dir_full, lower, upper, use_const_len, const_len, frags_num, alter)
