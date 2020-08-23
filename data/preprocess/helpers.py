import os
import csv
import pandas as pd
import os
import random
import shutil
import sys
import gzip
from Bio import SeqIO
import math
import requests
from bs4 import BeautifulSoup
import urllib.request

base_url = 'https://ftp.ncbi.nlm.nih.gov/genomes/all/'
dup_time = 1

def list_fd(url, ext=''):
    page = requests.get(url).text
    print(page)
    soup = BeautifulSoup(page, 'html.parser')
    return [url  + node.get('href') for node in soup.find_all('a') if node.get('href').endswith(ext)]

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

def download_genomes(selected_genome_ids, cluster_dir_full, lower, upper):
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
                for i in range(1):
                    seq_len = random.randint(lower, min(upper, max_len))
                    print(seq_len)
                    tmp = first_start_point(max_seq, seq_len)
                    random_start = random.randint(0, tmp)
                    cur_max_seq = prune_seq(max_seq, seq_len, random_start)                    
                    cur_fna_path = cluster_dir_full+"/"+max_name+str(base+i)+".fasta"
                    if i == 0:
                        while os.path.exists(cur_fna_path):
                            base += dup_time
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