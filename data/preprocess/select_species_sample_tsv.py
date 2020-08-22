import os
import sys
import pandas as pd
import shutil
import random
import gzip
from Bio import SeqIO
import urllib.request
import wget
import re
import glob
from bs4 import BeautifulSoup
import requests
import ssl
# from pandas import query

# tax_name = sys.argv[1]
sample_size = "50"
cluster_num = "21"
lower_str = "1e5"
upper_str =  "2e5"
random_seq = True

# cluster_num = float('inf')
# if len(sys.argv) == 6:
#     cluster_num = int(sys.argv[5])

outdir = "species"+"_"+sample_size+"_"+lower_str+"_"+upper_str+"_"+cluster_num
lower = int(float(lower_str))
upper = int(float(upper_str))
sample_size = int(sample_size)

base_path = "/Users/wanxinli/Desktop/project/MLDSP-desktop/data/"
outdir_full = base_path+"samples/"+outdir
# if os.path.exists(outdir_full):
#     shutil.rmtree(outdir_full, ignore_errors=True)
if not os.path.exists(outdir_full):
    os.makedirs(outdir_full)

cluster_tsv = pd.read_csv(base_path+"preprocess/sp_clusters_r89.tsv", sep='\t', header = 0, index_col = 1)
# entire_species = []
# existing_species = ['s__CAG-791 sp003447895','s__Simonsiella muelleri', 's__Campylobacter_A pinnipediorum','s__Streptococcus sp001587175', 's__CG1-02-40-82 sp001819495','s__Thalassotalea sp001913705','s__Fibrobacter sp900313675','s__UBA1304 sp002307295','s__HTCC2207 sp002685715','s__UBA3465 sp002730875']
# thres = 30
# for index, row in cluster_tsv.iterrows():
#     if len(row['Clustered_genomes'].split(',')) > thres and index not in existing_species:
#         entire_species.append(index)

def first_start_point(entire_seq, seq_len):
    entire_seq_len = len(entire_seq)
    count = 0
    for i in reversed(range(entire_seq_len)):
        if entire_seq[i] in 'ACGT':
            count += 1
        if count == seq_len:
            break
    return i

def prune_seq(entire_seq, seq_len, start_point):
    entire_seq_len = len(entire_seq)
    count = 0
    for i in range(start_point, entire_seq_len):
        if entire_seq[i] in 'ACGT':
            count += 1
        if count == seq_len:
            break
    print(start_point)
    print(i)
    return entire_seq[start_point:(i+1)]

def list_fd(url, ext=''):
    page = requests.get(url).text
    print(page)
    soup = BeautifulSoup(page, 'html.parser')
    return [url  + node.get('href') for node in soup.find_all('a') if node.get('href').endswith(ext)]



# auto select for now
# species_clusters = random.sample(entire_species, cluster_num)
# species_clusters = ['s__Bacteroides caccae', 's__Helicobacter pylori_BU']
sample_size = 20
# species_clusters = ['s__Helicobacter pylori_C', 's__Campylobacter_D jejuni', 's__Campylobacter_D coli', 's__Bacillus altitudinis', 's__Bacillus paralicheniformis', 's__Bacillus velezensis', 's__Bacillus_A anthracis', 's__Bacillus_A cereus', 's__Bacillus_A pseudomycoides']
species_clusters = ['s__Bacteroides caccae', 's__Bacteroides fragilis', 's__Bacteroides thetaiotaomicron', 's__Bacteroides uniformis', 's__Bacteroides xylanisolvens', 's__Burkholderia cepacia', 's__Burkholderia cenocepacia', 's__Burkholderia mallei', 's__Burkholderia multivorans', 's__Burkholderia stagnalis', 's__Burkholderia vietnamiensis']
# base_url = 'ftp://ftp.ncbi.nlm.nih.gov/genomes/all/'
ssl._create_default_https_context = ssl._create_unverified_context
base_url = 'https://ftp.ncbi.nlm.nih.gov/genomes/all/'
dup_try = 5
for cluster in species_clusters:
    print("cluster is:", cluster)
    all_genome_ids = cluster_tsv.loc[cluster]['Clustered_genomes'].split(',')
    cur_sample_size = sample_size
    if sample_size > len(all_genome_ids):
        cur_sample_size = len(all_genome_ids)
        print("INFO:", "reduce sample size for", cluster)
    print("sample size is:", cur_sample_size)
    selected_genome_ids = random.sample(all_genome_ids, cur_sample_size)
    cluster_dir_full = outdir_full+'/'+cluster
    if not os.path.exists(cluster_dir_full):
        os.makedirs(cluster_dir_full)
    print(selected_genome_ids)
    for id in selected_genome_ids:
        block1 = id[3:6]
        block2= id[7:10]
        block3 = id[10:13]
        block4 = id[13:16]
        print(block1, block2,block3, block4)
        partial_url = base_url+block1+'/'+block2+'/'+block3+'/'+block4 +'/'
        try:
            partial_url_dirs =  list_fd(partial_url)
            print("partial_url_dirs are:", partial_url_dirs)
            block5 = partial_url_dirs[1]

            last_index = block5.split("/", 9)[-1][:-1]
            download_url = block5+last_index+'_genomic.fna.gz'

            dest = cluster_dir_full+'/'+last_index+'_genomic.fna.gz'
            print("dest is:", dest)
            print("download_url is:", download_url)
            urllib.request.urlretrieve(download_url, dest)
            f = gzip.open(dest, 'r')
            file_content = f.read()
            file_content = file_content.decode('utf-8')
            fna_path = cluster_dir_full+'/'+last_index+"_genomic.fna"
            f_out = open(cluster_dir_full+'/'+last_index+"_genomic.fna", 'w+')
            f_out.write(file_content)
            f.close()
            f_out.close()
            os.remove(dest)

            fasta_sequences = SeqIO.parse(open(fna_path),'fasta') 
            max_len = 0
            max_seq = None
            max_name = None
            for fasta in fasta_sequences:
                name, sequence = fasta.id, str(fasta.seq)
                sequence_real = ''.join( c for c in sequence if  c in 'ACGT') # prune irrelevant chars
                if len(sequence_real) > max_len:
                    max_len = len(sequence_real)
                    max_seq = sequence # max_seq should contain 'X'
                    max_name = name
            if max_len < lower:
                os.remove(fna_path)
                print("INFO: len is", max_len)
                print("INFO: "+fna_path+" is removed")
                continue
            base = 0
            for i in range(dup_try):
                seq_len = random.randint(lower, min(upper, max_len))
                print(seq_len)
                tmp = first_start_point(max_seq, seq_len)
                random_start = random.randint(0, tmp)
                cur_max_seq = prune_seq(max_seq, seq_len, random_start)                    
                cur_fna_path = cluster_dir_full+"/"+max_name+str(base+i)+".fasta"
                if i == 0:
                    while os.path.exists(cur_fna_path):
                        base += dup_try
                        cur_fna_path = cluster_dir_full+"/"+max_name+str(base+i)+".fasta"
                out_file= open(cur_fna_path,"a+")
                out_file.seek(0)
                out_file.truncate()
                out_file.write(">"+max_name+str(i)+"\n")
                out_file.write(cur_max_seq)
            os.remove(fna_path)
        except Exception as e:
            print("ERROR:", "an error has occurred")
            print(e)
            pass

for file in glob.glob("tmp*"):
    os.remove(file)