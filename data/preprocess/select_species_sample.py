# argv[1]: sample size
# argv[2]: upper
# argv[3]: lower
# argv[4]: cluster num

import os
import sys
import pandas as pd
import shutil
import random
import gzip
from Bio import SeqIO

sample_size_str = sys.argv[1]
lower_str = sys.argv[2]
upper_str = sys.argv[3]
cluster_num_str = sys.argv[4]
outdir = "species"+"_"+sample_size_str+"_"+lower_str+"_"+upper_str+"_"+cluster_num_str
outdir_full = "/h/wanxinli/MLDSP/data/samples/"+outdir
if os.path.exists(outdir_full):
    shutil.rmtree(outdir_full, ignore_errors=True)
os.mkdir(outdir_full)
concat = True


sample_size = int(sample_size_str)
upper = float(upper_str)
lower = float(lower_str)
cluster_num = int(cluster_num_str)

# randomly select from release89
existing_genomes = os.listdir("/h/wanxinli/MLDSP/data/release89/bacteria")
existing_genomes = [g[:-15] for g in existing_genomes]
sampled_genome_ids = random.sample(existing_genomes, cluster_num)
print(sampled_genome_ids)

species_index = 7
bac120_total = pd.read_csv("/h/wanxinli/MLDSP/data/preprocess/bac120_taxonomy.tsv", sep='\t|;', engine='python', header=None, index_col=0)
for genome_id in sampled_genome_ids:
    cluster_name = bac120_total.loc[genome_id][species_index]
    cluster_dir_full = outdir_full+"/"+cluster_name
    os.mkdir(cluster_dir_full)
    # read data
    f = gzip.open("/h/wanxinli/MLDSP/data/release89/bacteria/"+genome_id+"_genomic.fna.gz", 'r')
    file_content = f.read()
    file_content = file_content.decode('utf-8')
    fna_path = cluster_dir_full+"/"+genome_id+"_genomic.fna"
    f_out = open(fna_path, 'w+')
    f_out.write(file_content)
    f.close()
    f_out.close()
    fasta_sequences = SeqIO.parse(open(fna_path),'fasta')  
    sequence = ""   
    if concat:
        for fasta in fasta_sequences:
            sequence += str(fasta.seq)
        max_seq = ''.join( c for c in sequence if  c in 'ACGT')
        max_len = len(sequence)
        if max_len < lower:
            shutil.rmtree(cluster_dir_full, ignore_errors=True)
            continue
        for i in range(sample_size):
            seq_len = random.randint(lower, min(upper, max_len))
            random_start = random.randint(0, max_len-seq_len)
            cur_seq = max_seq[random_start:(random_start+seq_len)]
            cur_name = genome_id+"_"+str(i)
            cur_file_path = cluster_dir_full+"/"+cur_name+"_genomic.fna"
            out_file= open(cur_file_path,"a+")
            out_file.seek(0)
            out_file.truncate()
            out_file.write(">"+cur_name+"\n")
            out_file.write(cur_seq)
    os.remove(fna_path)







