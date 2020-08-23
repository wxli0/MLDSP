import csv
import pandas as pd
import os
import random
import shutil
import sys
import os
import gzip
from Bio import SeqIO


# argv[1]: taxonomy name [2]: sample_num [3]: prune lower [4]: prune upper
# e.g. python3 select_sample.py phylum 400 1e5 2e5
# does not work for domain

tax_name = sys.argv[1]
sample_size = sys.argv[2]
lower_str = sys.argv[3]
upper_str = sys.argv[4]


cluster_num = int(sys.argv[5])

outdir = tax_name+"_"+sample_size+"_"+lower_str+"_"+upper_str+"_"+str(cluster_num)
lower = int(float(lower_str))
upper = int(float(upper_str))
sample_size = int(sample_size)

random_seq = True
base_path = "/home/w328li/MLDSP-desktop/"

outdir_full = base_path+"samples/"+outdir
if not os.path.exists(outdir_full):
    os.mkdir(outdir_full)

indices = {"domain":2, "phylum":3, "class":4, "order":5, "family":6, "genus":7}
next_taxs = {"domain":"phylum", "phylum":"class", "class":"order", "order":"family", "family":"genus", "genus":"species"}
index_names = {"domain": 'd__', 'phylum':'p__','class':'c__','order':'o__',"family":"f__", "genus":"g__"}

index = indices[tax_name]
index_name = index_names[tax_name]
next_tax = next_taxs[tax_name]

# preprocess tsv file
bac120_total = pd.read_csv(base_path+"data/preprocess/bac120_taxonomy.tsv", sep='\t|;', engine='python', header=None, index_col=0)
bac120_total = bac120_total[[index]]

bac120_subset = pd.DataFrame(columns = ['id',tax_name])

existing_genomes = os.listdir("/h/wanxinli/MLDSP/data/release89/bacteria")
i = 0
for eg in existing_genomes:
    genome_name = "_".join(eg.split("_")[:3])
    bac120_subset.loc[i] = [genome_name, bac120_total.loc[genome_name][index]]
    i += 1

bac120_subset = bac120_subset.groupby(tax_name)['id'].apply(lambda x: "%s" % ','.join(x))
# bac120_subset.to_csv("bac120_tmp.csv")

cluster_count = 0
for file_name in os.listdir('/h/wanxinli/MLDSP/data/preprocess'):
    # print("file_name is:", file_name)
    if not file_name.startswith(index_name):
        continue
    cluster_name = file_name[0:-10]
    print("cluster is:", cluster_name)
    cluster_distn = pd.read_csv("/h/wanxinli/MLDSP/data/preprocess/"+file_name, header=0)
    count_sum = cluster_distn[['count']].sum()
    cluster_distn[['count']] = cluster_distn[['count']]/count_sum
    cluster_count += 1
    if cluster_count == cluster_num:
        break

    sampled_seqs = []
    # sampled_seqs_backup = []
    for _, row in cluster_distn.iterrows():
        next_tax_name = row[next_tax]
    
        sample_num = int(sample_size*row['count'])
        # print(sample_num)

        if next_tax_name in bac120_subset.index:
            seq_str = bac120_subset[next_tax_name]
            seqs = seq_str.split(",") if seq_str else []
            if sample_num > len(seqs):
                sample_num = len(seqs)
            print(sample_num)
            print("INFO: sample_num is: "+str(sample_num))
            if sample_num == 0:
                sample_num = 1 # include 1 to increase variablity
            sampled_seqs.extend(random.sample(seqs, sample_num))
            # sampled_seqs_backup.extend(random.sample(seqs, sample_num))
        else:
            print("INFO: "+next_tax_name + " is not present")
    outdir_full = "/h/wanxinli/MLDSP/data/samples/"+outdir+"/"+cluster_name
    os.mkdir(outdir_full)
    for seq in sampled_seqs:
        f = gzip.open("/h/wanxinli/MLDSP/data/release89/bacteria/"+seq+"_genomic.fna.gz", 'r')
        file_content = f.read()
        file_content = file_content.decode('utf-8')
        f_out = open(outdir_full+"/"+seq+"_genomic.fna", 'w+')
        f_out.write(file_content)
        f.close()
        f_out.close()
    # prune
    for file in os.listdir(outdir_full):
        input_file = outdir_full + '/'+file
        # print(input_file)
        fasta_sequences = SeqIO.parse(open(input_file),'fasta')       
        max_len = 0
        max_seq = None
        max_name = None
        for fasta in fasta_sequences:
            name, sequence = fasta.id, str(fasta.seq)
            sequence = ''.join( c for c in sequence if  c in 'ACGT') # prune irrelevant chars
            if len(sequence) > max_len:
                max_len = len(sequence)
                max_seq = sequence
                max_name = name
        if max_len < lower:
            # concate all sequences
            sequence = ""
            fasta_sequences = SeqIO.parse(open(input_file),'fasta')       
            for fasta in fasta_sequences:
                _, cur_sequence = fasta.id, str(fasta.seq)
                sequence += cur_sequence
            sequence = ''.join( c for c in sequence if  c in 'ACGT') # prune irrelevant chars
            max_len = len(sequence)
            max_name += "_combined"
            max_seq = sequence
            if max_len < lower:
                os.remove(input_file)
                print("INFO: len is", max_len)
                print("INFO: "+input_file+" is removed")
                continue
            # max_len >= lower
            if max_len > upper:
                random_start = 0
                if random_seq:
                    random_start = random.randint(0, max_len-upper)
                max_seq = max_seq[random_start:(random_start+upper)]
        out_file= open(input_file,"a+")
        out_file.seek(0)
        out_file.truncate()
        out_file.write(">"+max_name+"\n")
        out_file.write(max_seq)
        os.rename(input_file, outdir_full+"/"+max_name+".fasta")

if cluster_num == float('inf'):
    new_outdir = tax_name+"_"+str(sample_size)+"_"+lower_str+"_"+upper_str+"_"+str(cluster_count)
    new_outdir_full = "/h/wanxinli/MLDSP/data/samples/"+new_outdir
    outdir_full = "/h/wanxinli/MLDSP/data/samples/"+outdir
    if os.path.exists(new_outdir_full):
        shutil.rmtree(new_outdir_full, ignore_errors=True)
    print(outdir_full)
    print(new_outdir_full)
    os.rename(outdir_full, new_outdir_full)

