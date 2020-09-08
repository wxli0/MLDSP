import sys
from helpers import download_const_genome, base_url, list_fd
import os
import csv
import pandas as pd
import os
import random
import shutil
import gzip
from Bio import SeqIO
import math
import requests
from bs4 import BeautifulSoup
import urllib.request
import json
import numpy as np
import platform

# argv[1]: genome_id
# argv[2]: outdir
# argv[3]: cluster
# e.g. python3 select_one_file.py RS_GCF_000520495.1.fasta class_const_factor_multifrag_1 c__Halobacteria 

cmd_arg = sys.argv[1].split('/')
outdir = cmd_arg[0] # outdir
cluster_name = cmd_arg[1] # cluster
genome_id = cmd_arg[2] # genome_id


base_path = "/Users/wanxinli/Desktop/project/MLDSP-desktop/" # run locally
if platform.platform()[:5] == 'Linux':
    base_path = "/home/w328li/MLDSP-desktop/"
outdir_full = base_path+"samples/"+outdir

def select_one_file(genome_id, cluster_name, const_len=100000, frags_num=3):
    cluster_dir_full = outdir_full+'/'+cluster_name
   
    block1 = genome_id[3:6]
    block2= genome_id[7:10]
    block3 = genome_id[10:13]
    block4 = genome_id[13:16]
    print(block1, block2,block3, block4)
    partial_url = base_url+block1+'/'+block2+'/'+block3+'/'+block4 +'/'
    try:
        partial_url_dirs =  list_fd(partial_url)
        block5 = partial_url_dirs[1]
        last_index = block5.split("/", 9)[-1][:-1]
        download_url = block5+last_index+'_genomic.fna.gz'
        dest = cluster_dir_full+'/'+last_index+'_genomic.fna.gz'
        urllib.request.urlretrieve(download_url, dest)
        f = gzip.open(dest, 'r')
        file_content = f.read()
        file_content = file_content.decode('utf-8')
        fna_path = cluster_dir_full+'/'+last_index+"_alter"+"_genomic.fna"
        f_out = open(cluster_dir_full+'/'+last_index+"_alter"+"_genomic.fna", 'w+')
        f_out.write(file_content)
        f.close()
        f_out.close()
        os.remove(dest)

        fasta_sequences = SeqIO.parse(open(fna_path),'fasta') 
        max_len = 0
        max_seq = ''
        max_name = genome_id[:-6]
        ######## tmp fix for now ############
        for fasta in fasta_sequences:
            _, sequence = fasta.id, str(fasta.seq)
            sequence_real = ''.join( c for c in sequence if  c in 'ACGT') # prune irrelevant chars
            # if len(sequence_real) > max_len:
            #     max_len = len(sequence_real)
            #     max_seq = sequence # max_seq should contain 'X'
            #     max_name = name
            print("max_len is:", max_len)
            print("sequence_real len is:", len(sequence_real))
            # if len(sequence_real) > max_len:
            #     max_name = name
            if sequence is None:
                continue
            max_len += len(sequence_real)
            max_seq += ('O'+ sequence)
    
        if max_len < (frags_num*const_len):
            os.remove(fna_path)
            print("INFO: len is", max_len)
            print("INFO: "+fna_path+" is removed")
        else:
            print("before download_const_genome")
            download_const_genome(max_len, max_seq, max_name, frags_num, const_len, cluster_dir_full, fna_path, alter=True)

    except Exception as e:
        print("ERROR:", "an error has occurred")
        print(e)
        pass

select_one_file(genome_id, cluster_name)
