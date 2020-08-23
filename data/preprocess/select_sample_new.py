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
from helpers import download_genomes
import ssl



# argv[1]: taxonomy name [2]: sample_num [3]: prune lower [4]: prune upper
# e.g. python3 select_sample_new.py family 50 1e5 2e5
# does not work for domain

tax_name = sys.argv[1]
sample_size = sys.argv[2]
lower_str = sys.argv[3]
upper_str = sys.argv[4]

# family
cluster_names = []
if tax_name == "family":
    cluster_names = ['f__Actinomycetaceae', 'f__Bifidobacteriaceae', 'f__Cellulomonadaceae', 'f__Dermatophilaceae', 'f__Micrococcaceae']

cluster_num = len(cluster_names)

outdir = tax_name+"_"+sample_size+"_"+lower_str+"_"+upper_str+"_"+str(cluster_num)
lower = int(float(lower_str))
upper = int(float(upper_str))
sample_size = int(sample_size)


random_seq = True
base_path = "/home/w328li/MLDSP-desktop/"
# base_path = "/Users/wanxinli/Desktop/project/MLDSP-desktop/"
outdir_full = base_path+"samples/"+outdir
ssl._create_default_https_context = ssl._create_unverified_context



indices = {"domain":0, "phylum":1, "class":2, "order":3, "family":4, "genus":5}
next_taxs = {"domain":"phylum", "phylum":"class", "class":"order", "order":"family", "family":"genus", "genus":"species"}
index_names = {"domain": 'd__', 'phylum':'p__','class':'c__','order':'o__',"family":"f__", "genus":"g__"}

index = indices[tax_name]
next_tax_name = next_taxs[tax_name]

cluster_tsv = pd.read_csv(base_path+"data/preprocess/sp_clusters_r89.tsv", sep='\t', header = 0, index_col = None)
cluster_tsv = cluster_tsv[['Representative_genome', 'GTDB_taxonomy']]

def get_target_col(tax_text):
    return tax_text.split(";")[index]

def get_target_next_col(tax_text):
    return tax_text.split(";")[index+1]


cluster_tsv[tax_name] = cluster_tsv['GTDB_taxonomy'].apply(get_target_col)
cluster_tsv[next_tax_name] = cluster_tsv['GTDB_taxonomy'].apply(get_target_next_col)

cluster_tsv = cluster_tsv.drop(['GTDB_taxonomy'], axis=1)

for cluster_name in cluster_names:
    cluster_name = "f__Enterobacteriaceae" # todo: make this into a loop
    cluster_tsv_cur = cluster_tsv.loc[cluster_tsv[tax_name] == cluster_name]

    cluster_tsv_cur = cluster_tsv_cur.drop([tax_name], axis=1)

    cluster_tsv_cur = cluster_tsv_cur.groupby(next_tax_name)['Representative_genome'].apply(list).reset_index().set_index(next_tax_name)
    cluster_tsv_cur.rename(columns = {'Representative_genome':'Representative_genome_arr'}, inplace = True)
    cluster_tsv_cur['species_ratio'] = cluster_tsv_cur['Representative_genome_arr'].apply(len)
    cluster_tsv_cur['species_ratio'] = cluster_tsv_cur['species_ratio']/sum(cluster_tsv_cur['species_ratio'])
    print(cluster_tsv_cur)

    selected_genomes = []
    outdir_full = base_path+"samples/"+outdir
    if not os.path.exists(outdir_full):
        os.makedirs(outdir_full)
    for next_tax in cluster_tsv_cur.index:
        next_tax_sample_size = int(sample_size * cluster_tsv_cur.loc[next_tax,:]['species_ratio'])
        selected_genomes.extend(random.sample(cluster_tsv_cur.loc[next_tax,:]['Representative_genome_arr'], next_tax_sample_size))
    cluster_dir_full = outdir_full+'/'+cluster_name
    if not os.path.exists(cluster_dir_full):
        os.makedirs(cluster_dir_full)
    print(selected_genomes)
    download_genomes(selected_genomes, cluster_dir_full, lower, upper)
