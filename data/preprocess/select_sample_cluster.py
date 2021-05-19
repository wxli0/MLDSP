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

sample_factor, sample_size, tax_name, use_factor, cluster_num, \
    cluster_names, lower, upper, use_const_len, const_len, frags_num, \
        alter, id, outdir, rep_time = parse_json_input(sys.argv[1])

print(parse_json_input(sys.argv[1]))
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

base_path = "/Users/wanxinli/Desktop/project/MLDSP-desktop/" # run locally
ver=sys.argv[2]
if platform.platform()[:5] == 'Linux':
    base_path = "/home/w328li/MLDSP/"
download_path = '/mnt/sda/MLDSP-samples-'+ver+'/'
outdir_full = download_path+outdir
ssl._create_default_https_context = ssl._create_unverified_context

indices = {"domain":0, "phylum":1, "class":2, "order":3, "family":4, "genus":5}
next_taxs = {"domain":"phylum", "phylum":"class", "class":"order", "order":"family", "family":"genus", "genus":"species"}
index_names = {"domain": 'd__', 'phylum':'p__','class':'c__','order':'o__',"family":"f__", "genus":"g__"}

index = indices[tax_name]
next_tax_name = next_taxs[tax_name]

cluster_tsv = pd.read_csv(base_path+"data/preprocess/sp_clusters_r202.tsv", sep='\t', header = 0, index_col = None)
cluster_tsv = cluster_tsv[['Representative_genome', 'GTDB_taxonomy', 'GTDB_species']]

def get_target_col(tax_text):
    return tax_text.split(";")[index]

def get_target_next_col(tax_text):
    return tax_text.split(";")[index+1]

cluster_tsv[tax_name] = cluster_tsv['GTDB_taxonomy'].apply(get_target_col)
if tax_name == "genus":
    cluster_tsv.rename(columns = {'GTDB_species':'species'}, inplace = True)
else:
    cluster_tsv[next_tax_name] = cluster_tsv['GTDB_taxonomy'].apply(get_target_next_col)

cluster_tsv = cluster_tsv.drop(['GTDB_taxonomy'], axis=1)
print(cluster_tsv)

for cluster_name in cluster_names:
    cluster_tsv_cur = cluster_tsv.loc[cluster_tsv[tax_name] == cluster_name]
    cluster_tsv_cur = cluster_tsv_cur.drop([tax_name], axis=1)
    cluster_tsv_cur = cluster_tsv_cur.groupby(next_tax_name)['Representative_genome'].apply(list).reset_index().set_index(next_tax_name)
    cluster_tsv_cur.rename(columns = {'Representative_genome':'Representative_genome_arr'}, inplace = True)
    cluster_tsv_cur['species_ratio'] = cluster_tsv_cur['Representative_genome_arr'].apply(len)
    species_num = sum(cluster_tsv_cur['species_ratio'])
    cluster_tsv_cur['species_ratio'] = cluster_tsv_cur['species_ratio']/sum(cluster_tsv_cur['species_ratio'])
    print(cluster_tsv_cur)

    selected_genomes = []
    if not os.path.exists(outdir_full):
        os.makedirs(outdir_full)
    real_sample_size = sample_size
    if use_factor:
        real_sample_size = int(species_num * sample_factor)
    for next_tax in cluster_tsv_cur.index:
        next_tax_sample_size = math.ceil(real_sample_size * cluster_tsv_cur.loc[next_tax,:]['species_ratio'])
        if len(cluster_tsv_cur.loc[next_tax,:]['Representative_genome_arr']) < next_tax_sample_size:
            next_tax_sample_size = len(cluster_tsv_cur.loc[next_tax,:]['Representative_genome_arr'])
        selected_genomes.extend(random.sample(cluster_tsv_cur.loc[next_tax,:]['Representative_genome_arr'], next_tax_sample_size))
    cluster_dir_full = outdir_full+'/'+cluster_name
    if not os.path.exists(cluster_dir_full):
        os.makedirs(cluster_dir_full)
    print(selected_genomes)
    print("before download_genomes")
    download_genomes(selected_genomes, cluster_dir_full, lower, upper, use_const_len, const_len, frags_num, alter, rep_time)
