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


sample_factor, sample_size, tax_name, use_factor, cluster_num, cluster_names, lower, upper, dup_time = parse_json_input(sys.argv[1])



# # family
# cluster_names = []
# if tax_name == "family":  # family 8
#     # cluster_names = ['f__Actinomycetaceae', 'f__Bifidobacteriaceae', 'f__Cellulomonadaceae', 'f__Dermatophilaceae', 'f__Micrococcaceae']
#     cluster_names = ['f__Mycobacteriaceae', 'f__Micromonosporaceae', 'f__Pseudonocardiaceae', 'f__Nocardioidaceae', 'f__Propionibacteriaceae']
# if tax_name == "genus": # genus 20
#     # cluster_names = ['g__Pauljensenia']
#     # cluster_names = ['g__Actinomyces', 'g__Pauljensenia', 'g__Bifidobacterium', 'g__Cryobacterium', 'g__Curtobacterium', 'g__Microbacterium', 'g__Rathayibacter', 'g__Glutamicibacter', 'g__Pseudarthrobacter', 'g__Rothia', 'g__Corynebacterium', 'g__Mycobacterium', 'g__Nocardia', 'g__Rhodococcus', 'g__Amycolatopsis', 'g__Pseudonocardia', 'g__Kitasatospora', 'g__Streptomyces', 'g__Bacteroides', 'g__Prevotella']
#     # cluster_names = ['g__Clostridioides', 'g__Paeniclostridium', 'g__Chlamydia', 'g__Chlamydophila']
#     cluster_names = ['g__Pseudonocardia', 'g__Cryobacterium']
# if tax_name == "order":
#     # cluster_names = ['o__Actinomycetales', 'o__Mycobacteriales', 'o__Streptomycetales', 'o__Coriobacteriales', 'o__Bacteroidales', 'o__Chitinophagales', 'o__Flavobacteriales', 'o__Sphingobacteriales', 'o__Balneolales', 'o__Acholeplasmatales', 'o__Bacillales', 'o__Erysipelotrichales', 'o__Lactobacillales', 'o__Mycoplasmatales', 'o__Staphylococcales', 'o__RF39', 'o__RFN20', 'o__Lachnospirales', 'o__Oscillospirales', 'o__Peptostreptococcales', 'o__Tissierellales', 'o__Christensenellales']
#     cluster_names = ['o__Staphylococcales']
# cluster_num = len(cluster_names) 
# cluster_num = 22 # todo: remote this line later

outdir = ""
if use_factor:
    outdir = tax_name+"_"+str(sample_factor)+"_"+str(lower)+"_"+str(upper)+"_"+str(cluster_num)
else:
    outdir = tax_name+"_"+str(sample_size)+"_"+str(lower)+"_"+str(upper)+"_"+str(cluster_num)


random_seq = True
base_path = "/Users/wanxinli/Desktop/project/MLDSP-desktop/" # run locally
if platform.platform() == 'Linux-5.3.0-61-generic-x86_64-with-debian-buster-sid':
    base_path = "/home/w328li/MLDSP-desktop/"
outdir_full = base_path+"samples/"+outdir
ssl._create_default_https_context = ssl._create_unverified_context



indices = {"domain":0, "phylum":1, "class":2, "order":3, "family":4, "genus":5}
next_taxs = {"domain":"phylum", "phylum":"class", "class":"order", "order":"family", "family":"genus", "genus":"species"}
index_names = {"domain": 'd__', 'phylum':'p__','class':'c__','order':'o__',"family":"f__", "genus":"g__"}

index = indices[tax_name]
next_tax_name = next_taxs[tax_name]

cluster_tsv = pd.read_csv(base_path+"data/preprocess/sp_clusters_r89.tsv", sep='\t', header = 0, index_col = None)
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
    outdir_full = base_path+"samples/"+outdir
    if not os.path.exists(outdir_full):
        os.makedirs(outdir_full)
    real_sample_size = sample_size
    if use_factor:
        real_sample_size = int(species_num * sample_factor)
    for next_tax in cluster_tsv_cur.index:
        next_tax_sample_size = math.ceil(real_sample_size * cluster_tsv_cur.loc[next_tax,:]['species_ratio'])
        # print("next_tax_samples_size is:", next_tax_sample_size)
        # print("number of rep genomes is:", len(cluster_tsv_cur.loc[next_tax,:]['Representative_genome_arr']))
        if len(cluster_tsv_cur.loc[next_tax,:]['Representative_genome_arr']) < next_tax_sample_size:
            next_tax_sample_size = len(cluster_tsv_cur.loc[next_tax,:]['Representative_genome_arr'])
        selected_genomes.extend(random.sample(cluster_tsv_cur.loc[next_tax,:]['Representative_genome_arr'], next_tax_sample_size))
    cluster_dir_full = outdir_full+'/'+cluster_name
    if not os.path.exists(cluster_dir_full):
        os.makedirs(cluster_dir_full)
    print(selected_genomes)
    download_genomes(selected_genomes, cluster_dir_full, lower, upper, dup_time = dup_time)
